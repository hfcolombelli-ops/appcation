<?php

namespace App\Http\Controllers;

use App\Models\Certificate;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CertificateVerificationController extends Controller
{
    public function show(Request $request, string $code): Response
    {
        $decoded = rawurldecode($code);

        $certificate = Certificate::query()
            ->where('certificate_code', $decoded)
            ->with([
                'user:id,name',
                'training' => fn ($q) => $q->with('institution:id,name'),
            ])
            ->first();

        if ($certificate === null) {
            if ($request->wantsJson()) {
                return response()->json([
                    'valid' => false,
                    'message' => 'Código não encontrado.',
                ], 404);
            }

            return response()
                ->view('certificates.verify', ['valid' => false, 'certificate' => null], 404);
        }

        $expired = $certificate->expires_at !== null && $certificate->expires_at->isPast();

        $json = [
            'valid' => true,
            'expired' => $expired,
            'certificate_code' => $certificate->certificate_code,
            'issued_at' => $certificate->issued_at?->toIso8601String(),
            'expires_at' => $certificate->expires_at?->toIso8601String(),
            'trainee_name' => $certificate->user->name,
            'training_title' => $certificate->training->title,
            'institution_name' => $certificate->training->institution?->name,
            'score' => $certificate->score,
        ];

        if ($request->wantsJson()) {
            return response()->json($json);
        }

        return response()->view('certificates.verify', [
            'valid' => true,
            'certificate' => $certificate,
        ]);
    }
}
