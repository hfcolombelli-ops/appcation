<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Certificate;
use App\Models\Enrollment;
use App\Models\SecurityAuditLog;
use App\Models\Training;
use Barryvdh\DomPDF\Facade\Pdf;
use Endroid\QrCode\Builder\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CertificateController extends Controller
{
    public function index(Request $request)
    {
        $rows = Certificate::query()
            ->where('user_id', $request->user()->id)
            ->with(['training' => fn ($q) => $q->with('institution:id,name')])
            ->latest('issued_at')
            ->limit(80)
            ->get();

        return response()->json($rows);
    }

    public function show(Request $request, string $id)
    {
        $c = Certificate::query()
            ->whereKey($id)
            ->where('user_id', $request->user()->id)
            ->with(['training' => fn ($q) => $q->with('institution:id,name')])
            ->firstOrFail();

        return response()->json($c);
    }

    public function downloadPdf(Request $request, string $id): Response
    {
        $certificate = Certificate::query()
            ->whereKey($id)
            ->where('user_id', $request->user()->id)
            ->with([
                'user',
                'training' => fn ($q) => $q->with('institution:id,name'),
            ])
            ->firstOrFail();

        return $this->pdfDownloadResponse($certificate);
    }

    /**
     * Certificado emitido para um participante — apenas o instrutor dono do treino.
     */
    public function instructorDownloadPdf(Request $request, string $trainingId, string $certificateId): Response
    {
        $training = Training::query()->findOrFail($trainingId);

        if ((int) $training->instructor_id !== (int) $request->user()->id) {
            return response()->json(['message' => 'Acesso negado.'], 403);
        }

        $certificate = Certificate::query()
            ->whereKey($certificateId)
            ->where('training_id', $training->id)
            ->with([
                'user',
                'training' => fn ($q) => $q->with('institution:id,name'),
            ])
            ->firstOrFail();

        return $this->pdfDownloadResponse($certificate);
    }

    /**
     * Listagem por treino: inscrições e certificados emitidos (instrutor dono do treino — auditoria).
     */
    public function exportTrainingCertificatesCsv(Request $request, string $trainingId): Response|JsonResponse
    {
        $training = Training::query()->with('institution:id,name')->findOrFail($trainingId);

        if ((int) $training->instructor_id !== (int) $request->user()->id) {
            return response()->json(['message' => 'Acesso negado.'], 403);
        }

        SecurityAuditLog::record($request, 'instructor.training_certificates_export_csv', Training::class, (int) $training->id, [
            'format' => 'csv',
        ]);

        $enrollments = Enrollment::query()
            ->where('training_id', $training->id)
            ->with('user:id,name,email')
            ->orderBy('joined_at')
            ->get();

        $certsByEnrollment = Certificate::query()
            ->whereIn('enrollment_id', $enrollments->pluck('id'))
            ->get()
            ->keyBy('enrollment_id');

        $filename = 'appcation-treino-'.$training->id.'-'.now()->format('Y-m-d-His').'.csv';

        $out = fopen('php://temp', 'r+');
        if ($out === false) {
            return response()->json(['message' => 'Não foi possível gerar o CSV.'], 500);
        }

        fwrite($out, "\xEF\xBB\xBF");

        fputcsv($out, ['Relatório App²cation — certificados por treino (uso instrutor / auditoria).'], ';');
        fputcsv($out, ['Gerado em (UTC)', now()->timezone('UTC')->toIso8601String()], ';');
        fputcsv($out, [], ';');
        fputcsv($out, ['Treino (id)', (string) $training->id], ';');
        fputcsv($out, ['Título', (string) $training->title], ';');
        fputcsv($out, ['Instituição', (string) ($training->institution?->name ?? '')], ';');
        fputcsv($out, ['Estado do treino', (string) $training->status], ';');
        fputcsv($out, ['Limiar aprovação (%)', (string) ($training->passing_score_percent ?? 70)], ';');
        fputcsv($out, [], ';');

        fputcsv($out, [
            'Participante',
            'Email',
            'Estado inscrição',
            'Nota final (0–10)',
            'Código certificado',
            'Emitido em (UTC)',
            'Válido até (UTC)',
        ], ';');

        foreach ($enrollments as $e) {
            $u = $e->user;
            $cert = $certsByEnrollment->get($e->id);
            fputcsv($out, [
                (string) ($u?->name ?? ''),
                (string) ($u?->email ?? ''),
                (string) $e->status,
                $e->score !== null ? (string) $e->score : '',
                $cert !== null ? (string) $cert->certificate_code : '',
                $cert?->issued_at?->timezone('UTC')->toIso8601String() ?? '',
                $cert?->expires_at?->timezone('UTC')->toIso8601String() ?? '',
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

    protected function pdfDownloadResponse(Certificate $certificate): Response
    {
        $base = rtrim((string) config('app.certificate_verify_base_url'), '/');
        $verifyUrl = $base.'/certificates/verify/'.rawurlencode($certificate->certificate_code);

        $qrResult = (new Builder)->build(
            data: $verifyUrl,
            size: 160,
            margin: 8,
        );
        $qrDataUri = $qrResult->getDataUri();

        $pdf = Pdf::loadView('certificates.pdf', [
            'certificate' => $certificate,
            'qrDataUri' => $qrDataUri,
            'verifyUrl' => $verifyUrl,
        ])->setPaper('a4', 'portrait');

        $safe = preg_replace('/[^A-Za-z0-9_.-]+/', '-', $certificate->certificate_code) ?: 'certificado';

        return $pdf->download('certificado-'.$safe.'.pdf');
    }
}
