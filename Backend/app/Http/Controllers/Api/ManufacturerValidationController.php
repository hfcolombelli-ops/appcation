<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Manufacturer;
use App\Models\SecurityAuditLog;
use App\Services\ManufacturerReviewerNotifier;
use Illuminate\Http\Request;

class ManufacturerValidationController extends Controller
{
    /**
     * Fila de fabricantes em análise (revisores Fluxxo).
     */
    public function reviewQueue(Request $request)
    {
        if (! $this->userIsReviewer($request)) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $rows = Manufacturer::query()
            ->where('validation_status', 'pending_validation')
            ->orderBy('updated_at')
            ->limit(100)
            ->get(['id', 'name', 'slug', 'cnpj', 'support_email', 'validation_status', 'updated_at']);

        return response()->json($rows);
    }

    /**
     * Fabricante: pede validação Fluxxo (documento Roberto / ArtMed).
     */
    public function requestValidation(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Disponível para administrador de fabricante.'], 403);
        }

        $m = Manufacturer::query()->findOrFail($user->manufacturer_id);

        if (! in_array($m->validation_status, ['pending_info', 'rejected'], true)) {
            return response()->json([
                'message' => 'Só é possível submeter quando o estado é «informações pendentes» ou «recusado».',
            ], 422);
        }

        $m->update(['validation_status' => 'pending_validation']);

        $fresh = $m->fresh();
        ManufacturerReviewerNotifier::notifyValidationRequested($fresh);

        SecurityAuditLog::record($request, 'manufacturer.validation_request', Manufacturer::class, (int) $fresh->id, [
            'validation_status' => $fresh->validation_status,
        ]);

        return response()->json(['manufacturer' => $fresh]);
    }

    /**
     * Revisor Fluxxo: define resultado da validação (e-mails em MANUFACTURER_REVIEWER_EMAILS).
     */
    public function review(Request $request, Manufacturer $manufacturer)
    {
        if (! $this->userIsReviewer($request)) {
            return response()->json(['message' => 'Sem permissão para rever fabricantes.'], 403);
        }

        if ($manufacturer->validation_status !== 'pending_validation') {
            return response()->json([
                'message' => 'Só é possível rever fabricantes em estado «em análise».',
            ], 422);
        }

        $data = $request->validate([
            'validation_status' => ['required', 'in:active,rejected,pending_info'],
        ]);

        $manufacturer->update(['validation_status' => $data['validation_status']]);

        SecurityAuditLog::record($request, 'manufacturer.validation_review', Manufacturer::class, (int) $manufacturer->id, [
            'validation_status' => $data['validation_status'],
        ]);

        return response()->json(['manufacturer' => $manufacturer->fresh()]);
    }

    protected function userIsReviewer(Request $request): bool
    {
        $email = strtolower(trim((string) $request->user()->email));
        $allowed = config('manufacturer.reviewer_emails', []);

        return $email !== '' && in_array($email, $allowed, true);
    }
}
