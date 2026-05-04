<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Mail\InvitationMail;
use App\Models\Institution;
use App\Models\Invitation;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;

class ManufacturerInvitationController extends Controller
{
    public function index(Request $request)
    {
        $user = $this->requireManufacturerAdmin($request);
        if ($user instanceof JsonResponse) {
            return $user;
        }

        $rows = Invitation::query()
            ->where('manufacturer_id', $user->manufacturer_id)
            ->with('institution:id,name')
            ->latest()
            ->limit(100)
            ->get()
            ->map(fn (Invitation $i) => $this->toApi($i));

        return response()->json($rows->values()->all());
    }

    public function store(Request $request)
    {
        $user = $this->requireManufacturerAdmin($request);
        if ($user instanceof JsonResponse) {
            return $user;
        }

        $data = $request->validate([
            'invited_email' => ['required', 'email', 'max:190'],
            'invited_name' => ['nullable', 'string', 'max:120'],
            'invited_cpf' => ['nullable', 'string', 'max:18'],
            'role' => ['required', 'in:institution_admin,instructor'],
            'institution_id' => ['required', 'integer', 'exists:institutions,id'],
        ]);

        $email = strtolower(trim($data['invited_email']));

        if (User::query()->where('email', $email)->exists()) {
            return response()->json([
                'message' => 'Já existe uma conta com este e-mail. Inicie sessão ou contacte o suporte.',
            ], 422);
        }

        $institution = Institution::query()->findOrFail((int) $data['institution_id']);
        if ((int) $institution->manufacturer_id !== (int) $user->manufacturer_id) {
            return response()->json(['message' => 'A instituição não pertence a este fabricante.'], 403);
        }

        if ($this->hasPendingInvite($user->manufacturer_id, $email)) {
            return response()->json(['message' => 'Já existe um convite pendente para este e-mail.'], 422);
        }

        $cpfDigits = null;
        if (! empty($data['invited_cpf'])) {
            $cpfDigits = preg_replace('/\D+/', '', (string) $data['invited_cpf']);
            $cpfDigits = $cpfDigits !== '' ? $cpfDigits : null;
        }

        $plain = Str::random(48);
        $hash = Invitation::hashToken($plain);

        $invitation = Invitation::create([
            'manufacturer_id' => $user->manufacturer_id,
            'institution_id' => $institution->id,
            'created_by_user_id' => $user->id,
            'invited_email' => $email,
            'invited_name' => isset($data['invited_name']) ? trim((string) $data['invited_name']) : null,
            'invited_cpf' => $cpfDigits,
            'role' => $data['role'],
            'token_hash' => $hash,
            'expires_at' => now()->addDays(14),
        ]);

        $acceptUrl = rtrim((string) config('app.url'), '/').'/invite?token='.urlencode($plain);
        $roleLabel = $data['role'] === 'instructor' ? 'instrutor' : 'gestor de instituição';

        Mail::to($email)->send(new InvitationMail(
            acceptUrl: $acceptUrl,
            invitedName: (string) ($invitation->invited_name ?? ''),
            roleLabel: $roleLabel,
        ));

        $invitation->load('institution:id,name');

        return response()->json($this->toApi($invitation), 201);
    }

    public function destroy(Request $request, Invitation $invitation)
    {
        $user = $this->requireManufacturerAdmin($request);
        if ($user instanceof JsonResponse) {
            return $user;
        }

        if ((int) $invitation->manufacturer_id !== (int) $user->manufacturer_id) {
            return response()->json(['message' => 'Convite não encontrado.'], 404);
        }

        if ($invitation->accepted_at !== null) {
            return response()->json(['message' => 'Convite já foi aceite.'], 422);
        }

        if ($invitation->revoked_at !== null) {
            return response()->json(['message' => 'Convite já revogado.'], 422);
        }

        $invitation->update(['revoked_at' => now()]);

        return response()->json(['ok' => true]);
    }

    private function requireManufacturerAdmin(Request $request): User|JsonResponse
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Apenas administrador de fabricante.'], 403);
        }

        return $user;
    }

    private function hasPendingInvite(int $manufacturerId, string $email): bool
    {
        return Invitation::query()
            ->where('manufacturer_id', $manufacturerId)
            ->where('invited_email', $email)
            ->whereNull('accepted_at')
            ->whereNull('revoked_at')
            ->where('expires_at', '>', now())
            ->exists();
    }

    /**
     * @return array<string, mixed>
     */
    private function toApi(Invitation $i): array
    {
        return [
            'id' => $i->id,
            'invited_email' => $i->invited_email,
            'invited_name' => $i->invited_name,
            'invited_cpf' => $i->invited_cpf,
            'role' => $i->role,
            'institution_id' => $i->institution_id,
            'institution' => $i->relationLoaded('institution') && $i->institution
                ? ['id' => $i->institution->id, 'name' => $i->institution->name]
                : null,
            'expires_at' => $i->expires_at?->toIso8601String(),
            'accepted_at' => $i->accepted_at?->toIso8601String(),
            'revoked_at' => $i->revoked_at?->toIso8601String(),
            'status' => $this->statusLabel($i),
        ];
    }

    private function statusLabel(Invitation $i): string
    {
        if ($i->accepted_at !== null) {
            return 'accepted';
        }
        if ($i->revoked_at !== null) {
            return 'revoked';
        }
        if ($i->expires_at !== null && $i->expires_at->isPast()) {
            return 'expired';
        }

        return 'pending';
    }
}
