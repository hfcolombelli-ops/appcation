<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Certificate;
use Barryvdh\DomPDF\Facade\Pdf;
use Endroid\QrCode\Builder\Builder;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

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
