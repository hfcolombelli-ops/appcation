<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\RequiresManufacturerApproved;
use App\Http\Controllers\Controller;
use App\Models\Equipment;
use App\Models\Manufacturer;
use App\Models\SecurityAuditLog;
use App\Services\Dashboard\ManufacturerDashboardAggregateService;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class ManufacturerDashboardController extends Controller
{
    use RequiresManufacturerApproved;

    public function __construct(
        private readonly ManufacturerDashboardAggregateService $manufacturerDashboard,
    ) {}

    /**
     * Indicadores agregados de treinos ligados ao fabricante (sem identificar participantes).
     */
    public function show(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Disponível apenas para administrador de fabricante.'], 403);
        }

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $mid = (int) $user->manufacturer_id;
        $filters = $this->resolveDashboardFilters($request, $mid);

        return response()->json($this->manufacturerDashboard->aggregate($mid, $filters));
    }

    /**
     * Exporta os mesmos agregados em CSV.
     */
    public function exportCsv(Request $request): Response|JsonResponse
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Disponível apenas para administrador de fabricante.'], 403);
        }

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $mid = (int) $user->manufacturer_id;
        $filters = $this->resolveDashboardFilters($request, $mid);
        $data = $this->manufacturerDashboard->aggregate($mid, $filters);

        SecurityAuditLog::record($request, 'manufacturer.dashboard_export_csv', Manufacturer::class, $mid, [
            'format' => 'csv',
            'filters' => $filters,
        ]);

        $filename = 'appcation-fabricante-'.now()->format('Y-m-d-His').'.csv';

        $out = fopen('php://temp', 'r+');
        if ($out === false) {
            return response()->json(['message' => 'Não foi possível gerar o CSV.'], 500);
        }

        fwrite($out, "\xEF\xBB\xBF");

        fputcsv($out, ['Relatório agregado App²cation (fabricante) — sem identificação de participantes.'], ';');
        fputcsv($out, ['Gerado em (UTC)', now()->toIso8601String()], ';');
        $caption = $this->manufacturerFilterCaption($filters);
        if ($caption !== null) {
            fputcsv($out, ['Filtros aplicados', $caption], ';');
        }
        fputcsv($out, [], ';');

        $cs = $data['completion_summary'] ?? [];
        fputcsv($out, ['Resumo'], ';');
        fputcsv($out, ['Treinos (total)', (string) ($data['trainings_count'] ?? '')], ';');
        fputcsv($out, ['Treinos encerrados', (string) ($data['finished_trainings_count'] ?? '')], ';');
        fputcsv($out, ['Total inscrições', (string) ($cs['total_enrollments'] ?? '')], ';');
        fputcsv($out, ['Inscrições concluídas', (string) ($cs['completed_count'] ?? '')], ';');
        fputcsv($out, ['Taxa conclusão (%)', $cs['completion_rate_percent'] !== null ? (string) $cs['completion_rate_percent'] : ''], ';');
        fputcsv($out, ['Média notas (concluídos)', $data['avg_score_completed'] !== null ? (string) $data['avg_score_completed'] : ''], ';');
        fputcsv($out, [], ';');

        fputcsv($out, ['Por instituição'], ';');
        fputcsv($out, ['Instituição', 'Treinos', 'Inscrições', 'Concluídas', 'Taxa conclusão (%)', 'Média notas (concluídos)'], ';');
        foreach ($data['aggregated_by_institution'] as $row) {
            $r = is_array($row) ? $row : (array) $row;
            fputcsv($out, [
                (string) ($r['label'] ?? ''),
                (string) ($r['trainings_count'] ?? ''),
                (string) ($r['total_enrollments'] ?? ''),
                (string) ($r['completed_count'] ?? ''),
                $r['completion_rate_percent'] !== null ? (string) $r['completion_rate_percent'] : '',
                $r['avg_score'] !== null ? (string) $r['avg_score'] : '',
            ], ';');
        }
        fputcsv($out, [], ';');

        fputcsv($out, ['Por equipamento (modelo no treino)'], ';');
        fputcsv($out, ['Equipamento', 'Treinos', 'Inscrições', 'Concluídas', 'Taxa conclusão (%)', 'Média notas (concluídos)'], ';');
        foreach ($data['aggregated_by_equipment'] as $row) {
            $r = is_array($row) ? $row : (array) $row;
            fputcsv($out, [
                (string) ($r['label'] ?? ''),
                (string) ($r['trainings_count'] ?? ''),
                (string) ($r['total_enrollments'] ?? ''),
                (string) ($r['completed_count'] ?? ''),
                $r['completion_rate_percent'] !== null ? (string) $r['completion_rate_percent'] : '',
                $r['avg_score'] !== null ? (string) $r['avg_score'] : '',
            ], ';');
        }
        fputcsv($out, [], ';');

        fputcsv($out, ['Tendência mensal combinada (UTC)'], ';');
        fputcsv($out, ['Mês (AAAA-MM)', 'Inscrições (COALESCE(joined_at, created_at))', 'Conclusões (completed_at)'], ';');
        foreach ($data['monthly_trend'] ?? [] as $row) {
            $r = is_array($row) ? $row : (array) $row;
            fputcsv($out, [
                (string) ($r['period'] ?? ''),
                (string) ($r['enrollment_count'] ?? ''),
                (string) ($r['completed_count'] ?? ''),
            ], ';');
        }

        rewind($out);
        $body = stream_get_contents($out);
        fclose($out);

        return response($body, 200, [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="'.$filename.'"',
        ]);
    }

    /**
     * Exporta os mesmos agregados em PDF.
     */
    public function exportPdf(Request $request): Response|JsonResponse
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Disponível apenas para administrador de fabricante.'], 403);
        }

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $mid = (int) $user->manufacturer_id;
        $manufacturer = Manufacturer::query()->findOrFail($mid);
        $filters = $this->resolveDashboardFilters($request, $mid);
        $data = $this->manufacturerDashboard->aggregate($mid, $filters);

        SecurityAuditLog::record($request, 'manufacturer.dashboard_export_pdf', Manufacturer::class, $mid, [
            'format' => 'pdf',
            'filters' => $filters,
        ]);

        $pdf = Pdf::loadView('reports.manufacturer_dashboard', [
            'manufacturerName' => $manufacturer->name,
            'data' => $data,
            'generatedAt' => now(),
            'filterCaption' => $this->manufacturerFilterCaption($filters),
        ])->setPaper('a4', 'portrait');

        $safe = preg_replace('/[^A-Za-z0-9_.-]+/', '-', (string) $manufacturer->name) ?: 'fabricante';

        return $pdf->download('appcation-fabricante-'.$safe.'-'.now()->format('Y-m-d-His').'.pdf');
    }

    /**
     * @return array<string, mixed>
     */
    private function resolveDashboardFilters(Request $request, int $manufacturerId): array
    {
        $filters = [];
        if ($request->filled('institution_id')) {
            $filters['institution_id'] = (int) $request->query('institution_id');
        }
        if ($request->filled('equipment_id')) {
            $eid = (int) $request->query('equipment_id');
            if (! Equipment::query()->whereKey($eid)->where('manufacturer_id', $manufacturerId)->exists()) {
                throw new HttpResponseException(response()->json(['message' => 'Equipamento inválido ou não pertence a este fabricante.'], 422));
            }
            $filters['equipment_id'] = $eid;
        }
        foreach (['training_created_from', 'training_created_to'] as $key) {
            if (! $request->filled($key)) {
                continue;
            }
            $raw = (string) $request->query($key);
            if (! preg_match('/^\d{4}-\d{2}-\d{2}$/', $raw)) {
                throw new HttpResponseException(response()->json(['message' => 'Formato de data inválido (use AAAA-MM-DD).'], 422));
            }
            try {
                Carbon::createFromFormat('Y-m-d', $raw, 'UTC');
            } catch (\Throwable) {
                throw new HttpResponseException(response()->json(['message' => 'Data inválida.'], 422));
            }
            $filters[$key] = $raw;
        }
        if (isset($filters['training_created_from'], $filters['training_created_to'])
            && $filters['training_created_from'] > $filters['training_created_to']) {
            throw new HttpResponseException(response()->json(['message' => 'Intervalo de datas inválido (início maior que fim).'], 422));
        }

        return $filters;
    }

    /**
     * @param  array<string, mixed>  $filters
     */
    private function manufacturerFilterCaption(array $filters): ?string
    {
        if ($filters === []) {
            return null;
        }
        $parts = [];
        if (isset($filters['institution_id'])) {
            $parts[] = 'instituição ID '.$filters['institution_id'];
        }
        if (isset($filters['equipment_id'])) {
            $parts[] = 'equipamento ID '.$filters['equipment_id'];
        }
        if (isset($filters['training_created_from'])) {
            $parts[] = 'treinos criados desde '.$filters['training_created_from'];
        }
        if (isset($filters['training_created_to'])) {
            $parts[] = 'treinos criados até '.$filters['training_created_to'];
        }

        return implode('; ', $parts);
    }
}
