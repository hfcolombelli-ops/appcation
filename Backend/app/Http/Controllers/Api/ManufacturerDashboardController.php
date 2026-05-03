<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\RequiresManufacturerApproved;
use App\Http\Controllers\Controller;
use App\Models\Manufacturer;
use App\Models\SecurityAuditLog;
use App\Services\Dashboard\ManufacturerDashboardAggregateService;
use Barryvdh\DomPDF\Facade\Pdf;
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

        return response()->json($this->manufacturerDashboard->aggregate((int) $user->manufacturer_id));
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
        $data = $this->manufacturerDashboard->aggregate($mid);

        SecurityAuditLog::record($request, 'manufacturer.dashboard_export_csv', Manufacturer::class, $mid, [
            'format' => 'csv',
        ]);

        $filename = 'appcation-fabricante-'.now()->format('Y-m-d-His').'.csv';

        $out = fopen('php://temp', 'r+');
        if ($out === false) {
            return response()->json(['message' => 'Não foi possível gerar o CSV.'], 500);
        }

        fwrite($out, "\xEF\xBB\xBF");

        fputcsv($out, ['Relatório agregado App²cation (fabricante) — sem identificação de participantes.'], ';');
        fputcsv($out, ['Gerado em (UTC)', now()->toIso8601String()], ';');
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
        $data = $this->manufacturerDashboard->aggregate($mid);

        SecurityAuditLog::record($request, 'manufacturer.dashboard_export_pdf', Manufacturer::class, $mid, [
            'format' => 'pdf',
        ]);

        $pdf = Pdf::loadView('reports.manufacturer_dashboard', [
            'manufacturerName' => $manufacturer->name,
            'data' => $data,
            'generatedAt' => now(),
        ])->setPaper('a4', 'portrait');

        $safe = preg_replace('/[^A-Za-z0-9_.-]+/', '-', (string) $manufacturer->name) ?: 'fabricante';

        return $pdf->download('appcation-fabricante-'.$safe.'-'.now()->format('Y-m-d-His').'.pdf');
    }
}
