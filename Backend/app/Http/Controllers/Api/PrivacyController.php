<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Answer;
use App\Models\Enrollment;
use App\Models\SecurityAuditLog;
use App\Models\TraineeProfile;
use App\Models\UserConsent;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class PrivacyController extends Controller
{
    public function policyMeta(Request $request)
    {
        return response()->json([
            'privacy_policy_version' => config('lgpd.privacy_policy_version'),
            'trainee_consent_summary' => config('lgpd.trainee_consent_summary'),
            'dpo_email' => config('lgpd.dpo_email'),
        ]);
    }

    /**
     * Consentimento explícito — checkbox obrigatório no cliente (não pré-marcado).
     */
    public function storeConsent(Request $request)
    {
        $data = $request->validate([
            'consent_type' => ['nullable', 'string', 'max:64'],
            'accepted' => ['required', 'accepted'],
        ]);

        $type = $data['consent_type'] ?? 'lgpd_trainee';

        if ($request->user()->role === 'trainee' && $type !== 'lgpd_trainee') {
            return response()->json(['message' => 'Tipo de consentimento inválido para este perfil.'], 422);
        }

        $consent = UserConsent::query()->create([
            'user_id' => $request->user()->id,
            'consent_type' => $type,
            'policy_version' => config('lgpd.privacy_policy_version'),
            'ip_address' => $request->ip(),
            'user_agent' => substr((string) $request->userAgent(), 0, 2000),
            'given_at' => now(),
        ]);

        SecurityAuditLog::record($request, 'privacy.consent_store', UserConsent::class, (int) $consent->id, [
            'consent_type' => $type,
            'policy_version' => config('lgpd.privacy_policy_version'),
        ]);

        return response()->json(['message' => 'Consentimento registrado.', 'policy_version' => config('lgpd.privacy_policy_version')]);
    }

    /**
     * Portabilidade / acesso (Art. 18 LGPD) — JSON com dados do titular.
     */
    public function exportPersonalData(Request $request)
    {
        $user = $request->user();

        $payload = [
            'exported_at' => now()->toIso8601String(),
            'privacy_policy_version' => config('lgpd.privacy_policy_version'),
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'role' => $user->role,
                'avatar_url' => $user->avatar_url,
                'created_at' => $user->created_at?->toIso8601String(),
            ],
            'consents' => UserConsent::query()
                ->where('user_id', $user->id)
                ->orderByDesc('given_at')
                ->get(['consent_type', 'policy_version', 'given_at', 'revoked_at']),
        ];

        if ($user->role === 'trainee') {
            $profile = TraineeProfile::query()->where('user_id', $user->id)->with('institution:id,name,cnpj')->first();
            $payload['trainee_profile'] = $profile;

            $payload['enrollments'] = Enrollment::query()
                ->where('user_id', $user->id)
                ->with(['training:id,title,status,starts_at'])
                ->orderByDesc('updated_at')
                ->get()
                ->map(function (Enrollment $e) {
                    return [
                        'enrollment_id' => $e->id,
                        'status' => $e->status,
                        'score' => $e->score,
                        'joined_at' => $e->joined_at?->toIso8601String(),
                        'completed_at' => $e->completed_at?->toIso8601String(),
                        'training' => $e->training,
                    ];
                });

            $enrollmentIds = Enrollment::query()->where('user_id', $user->id)->pluck('id');

            $payload['answers_summary'] = Answer::query()
                ->whereIn('enrollment_id', $enrollmentIds)
                ->get(['id', 'enrollment_id', 'question_id', 'is_correct', 'score', 'created_at']);
        }

        SecurityAuditLog::record($request, 'privacy.export_personal_data', null, (int) $user->id, [
            'role' => $user->role,
        ]);

        return response()->json($payload);
    }

    /**
     * Eliminação / anonimização da conta (Art. 16–18 LGPD).
     * Retenções fiscais futuras: estender com fiscal_retention quando houver CPF de instrutor em NF.
     */
    public function requestAccountDeletion(Request $request)
    {
        $user = $request->user();

        $rules = [
            'confirm_text' => ['required', 'string', 'in:EXCLUIR'],
        ];

        if ($user->google_sub !== null) {
            $rules['id_token'] = ['required', 'string'];
        } else {
            $rules['password'] = ['required', 'string'];
        }

        $data = $request->validate($rules);

        if ($user->google_sub !== null) {
            $tokenResponse = Http::timeout(10)->get('https://oauth2.googleapis.com/tokeninfo', [
                'id_token' => $data['id_token'],
            ]);
            if (! $tokenResponse->successful()) {
                return response()->json(['message' => 'Token Google inválido.'], 401);
            }
            $payload = $tokenResponse->json();
            if (($payload['sub'] ?? null) !== $user->google_sub) {
                return response()->json(['message' => 'Token Google não corresponde a esta conta.'], 403);
            }
            if (($payload['aud'] ?? null) !== config('services.google.client_id')) {
                return response()->json(['message' => 'Audiência do token inválida.'], 401);
            }
        } elseif (! Hash::check($data['password'], $user->password)) {
            return response()->json(['message' => 'Senha incorreta.'], 422);
        }

        $userId = (int) $user->id;

        DB::transaction(function () use ($user) {
            $user->tokens()->delete();

            TraineeProfile::query()->where('user_id', $user->id)->delete();

            UserConsent::query()->where('user_id', $user->id)->delete();

            $anonEmail = 'anon_'.$user->id.'_'.time().'@removed.appcation.invalid';

            $user->forceFill([
                'name' => 'Titular removido',
                'email' => $anonEmail,
                'password' => Hash::make(Str::password(32)),
                'phone' => null,
                'avatar_url' => null,
                'google_sub' => null,
            ])->save();
        });

        SecurityAuditLog::record($request, 'privacy.account_deletion', null, $userId, [
            'anonymized' => true,
        ]);

        return response()->json([
            'message' => 'Conta anonimizada. Encerre a sessão neste dispositivo.',
        ]);
    }
}
