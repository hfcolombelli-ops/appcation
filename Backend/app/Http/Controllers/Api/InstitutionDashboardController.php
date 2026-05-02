<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Institution;
use App\Models\SecurityAuditLog;
use App\Services\Dashboard\InstitutionDashboardAggregateService;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class InstitutionDashboardController extends Controller
{
    public function __construct(
        private readonly InstitutionDashboardAggregateService $institutionDashboard,
    ) {}

    /**
     * Indicadores agregados por setor (LGPD — sem identificar indivíduos).
     */
    public function show(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'institution_admin' || $user->institution_id === null) {
            return response()->json(['message' => 'Disponível para gestores com instituição vinculada ao perfil.'], 403);
        }

        return response()->json($this->institutionDashboard->aggregate((int) $user->institution_id));
    }

    /**
     * Exporta os mesmos agregados do dashboard em CSV (planilhas, arquivo).
     */
    public function exportCsv(Request $request): Response|JsonResponse
    {
        $user = $request->user();
        if ($user->role !== 'institution_admin' || $user->institution_id === null) {
            return response()->json(['message' => 'Disponível para gestores com instituição vinculada ao perfil.'], 403);
        }

        $iid = (int) $user->institution_id;
        $data = $this->institutionDashboard->aggregate($iid);

        SecurityAuditLog::record($request, 'institution.dashboard_export_csv', Institution::class, $iid, [
            'format' => 'csv',
        ]);

        $filename = 'appcation-instituicao-'.now()->format('Y-m-d-His').'.csv';

        $out = fopen('php://temp', 'r+');
        if ($out === false) {
            return response()->json(['message' => 'Não foi possível gerar o CSV.'], 500);
        }

        fwrite($out, "\xEF\xBB\xBF");

        fputcsv($out, ['Relatório agregado App²cation — dados sem identificação individual (LGPD).'], ';');
        fputcsv($out, ['Gerado em (UTC)', now()->toIso8601String()], ';');
        fputcsv($out, [], ';');

        $cs = $data['completion_summary'] ?? [];
        fputcsv($out, ['Resumo'], ';');
        fputcsv($out, ['Treinos (instituição)', (string) ($data['trainings_count'] ?? '')], ';');
        fputcsv($out, ['Pedidos de treino pendentes', (string) ($data['pending_training_requests'] ?? '')], ';');
        fputcsv($out, ['Total inscrições', (string) ($cs['total_enrollments'] ?? '')], ';');
        fputcsv($out, ['Inscrições concluídas', (string) ($cs['completed_count'] ?? '')], ';');
        fputcsv($out, ['Taxa conclusão (%)', $cs['completion_rate_percent'] !== null ? (string) $cs['completion_rate_percent'] : ''], ';');
        fputcsv($out, ['Média notas (concluídos)', $data['avg_score_completed'] !== null ? (string) $data['avg_score_completed'] : ''], ';');
        fputcsv($out, [], ';');

        fputcsv($out, ['Por setor'], ';');
        fputcsv($out, ['Setor', 'Média notas', 'Conclusões'], ';');
        foreach ($data['aggregated_by_sector'] as $row) {
            $r = (array) $row;
            fputcsv($out, [
                (string) ($r['sector'] ?? ''),
                isset($r['avg_score']) ? (string) $r['avg_score'] : '',
                isset($r['completions']) ? (string) $r['completions'] : '',
            ], ';');
        }
        fputcsv($out, [], ';');

        fputcsv($out, ['Por equipamento'], ';');
        fputcsv($out, ['Equipamento', 'Inscrições', 'Concluídas', 'Taxa conclusão (%)', 'Média notas (concluídos)'], ';');
        foreach ($data['aggregated_by_equipment'] as $row) {
            $r = is_array($row) ? $row : (array) $row;
            fputcsv($out, [
                (string) ($r['label'] ?? ''),
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
        if ($user->role !== 'institution_admin' || $user->institution_id === null) {
            return response()->json(['message' => 'Disponível para gestores com instituição vinculada ao perfil.'], 403);
        }

        $iid = (int) $user->institution_id;
        $institution = Institution::query()->findOrFail($iid);
        $data = $this->institutionDashboard->aggregate($iid);

        SecurityAuditLog::record($request, 'institution.dashboard_export_pdf', Institution::class, $iid, [
            'format' => 'pdf',
        ]);

        $pdf = Pdf::loadView('reports.institution_dashboard', [
            'institutionName' => $institution->name,
            'data' => $data,
            'generatedAt' => now(),
        ])->setPaper('a4', 'portrait');

        $safe = preg_replace('/[^A-Za-z0-9_.-]+/', '-', (string) $institution->name) ?: 'instituicao';

        return $pdf->download('appcation-instituicao-'.$safe.'-'.now()->format('Y-m-d-His').'.pdf');
    }
}
