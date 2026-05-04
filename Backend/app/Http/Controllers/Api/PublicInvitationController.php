<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\InstitutionInstructor;
use App\Models\Invitation;
use App\Models\ManufacturerInstructor;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rules\Password;

class PublicInvitationController extends Controller
{
    public function show(string $token)
    {
        $inv = $this->findByPlainToken($token);
        if ($inv === null) {
            return response()->json(['message' => 'Convite inválido.'], 404);
        }

        $inv->load('institution:id,name');

        return response()->json([
            'status' => $this->publicStatus($inv),
            'invited_email' => $inv->invited_email,
            'invited_name' => $inv->invited_name,
            'role' => $inv->role,
            'institution_name' => $inv->institution?->name,
            'requires_cpf' => $inv->invited_cpf !== null && $inv->invited_cpf !== '',
        ]);
    }

    public function accept(Request $request, string $token)
    {
        $inv = $this->findByPlainToken($token);
        if ($inv === null) {
            return response()->json(['message' => 'Convite inválido.'], 404);
        }

        if (! $inv->isPending()) {
            return response()->json(['message' => 'Este convite já não está disponível.'], 410);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'password' => ['required', 'confirmed', Password::min(8)],
            'cpf' => ['nullable', 'string', 'max:18'],
        ]);

        $email = strtolower(trim($inv->invited_email));

        if (User::query()->where('email', $email)->exists()) {
            return response()->json(['message' => 'Já existe conta com este e-mail. Inicie sessão.'], 409);
        }

        if ($inv->invited_cpf !== null && $inv->invited_cpf !== '') {
            $got = preg_replace('/\D+/', '', (string) ($data['cpf'] ?? ''));
            if ($got === '' || $got !== $inv->invited_cpf) {
                return response()->json([
                    'message' => 'O CPF não coincide com o convite.',
                    'errors' => ['cpf' => ['Confirme o CPF indicado no convite.']],
                ], 422);
            }
        }

        $user = DB::transaction(function () use ($inv, $data, $email) {
            $cpf = null;
            if ($inv->invited_cpf !== null && $inv->invited_cpf !== '') {
                $cpf = $inv->invited_cpf;
            } elseif (! empty($data['cpf'])) {
                $d = preg_replace('/\D+/', '', (string) $data['cpf']);
                $cpf = $d !== '' ? $d : null;
            }

            $user = User::create([
                'name' => trim($data['name']),
                'email' => $email,
                'password' => $data['password'],
                'role' => $inv->role,
                'manufacturer_id' => $inv->role === 'instructor' ? $inv->manufacturer_id : null,
                'institution_id' => $inv->role === 'institution_admin' ? $inv->institution_id : null,
                'google_sub' => null,
                'google_triage_completed_at' => now(),
                'cpf' => $cpf,
            ]);

            if ($inv->role === 'instructor') {
                ManufacturerInstructor::query()->updateOrCreate(
                    [
                        'manufacturer_id' => $inv->manufacturer_id,
                        'instructor_id' => $user->id,
                    ],
                    ['status' => 'approved'],
                );
                InstitutionInstructor::query()->updateOrCreate(
                    [
                        'institution_id' => $inv->institution_id,
                        'instructor_id' => $user->id,
                    ],
                    ['status' => 'approved'],
                );
            }

            $inv->update(['accepted_at' => now()]);

            return $user->fresh();
        });

        return response()->json([
            'token' => $user->createToken('web')->plainTextToken,
            'user' => $user->toApiArray(),
        ], 201);
    }

    private function findByPlainToken(string $token): ?Invitation
    {
        $t = trim($token);
        if ($t === '') {
            return null;
        }

        $hash = Invitation::hashToken($t);

        return Invitation::query()->where('token_hash', $hash)->first();
    }

    private function publicStatus(Invitation $inv): string
    {
        if ($inv->accepted_at !== null) {
            return 'accepted';
        }
        if ($inv->revoked_at !== null) {
            return 'revoked';
        }
        if ($inv->expires_at !== null && $inv->expires_at->isPast()) {
            return 'expired';
        }

        return 'pending';
    }
}
