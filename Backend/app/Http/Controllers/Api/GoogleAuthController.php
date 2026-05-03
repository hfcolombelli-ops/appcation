<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Manufacturer;
use App\Models\User;
use App\Services\GoogleIdTokenVerifier;
use App\Services\ManufacturerReviewerNotifier;
use App\Support\ManufacturerRegistrationSupport;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use InvalidArgumentException;

class GoogleAuthController extends Controller
{
    /**
     * Login ou registo via Google ID token (Flutter Web / mobile).
     * Configure GOOGLE_CLIENT_ID igual ao OAuth Client ID (tipo Web) usado no cliente.
     */
    public function callback(Request $request, GoogleIdTokenVerifier $verifier)
    {
        $data = $request->validate([
            'id_token' => ['required', 'string'],
            // Opcional: omitir para criar conta só com Google e completar perfil na triagem (PATCH /api/me/role).
            'role' => ['nullable', 'in:trainee,instructor,manufacturer_admin'],
            'manufacturer_name' => ['nullable', 'string', 'max:180'],
            'manufacturer_cnpj' => ['nullable', 'string', 'max:20'],
        ]);

        $expectedAud = config('services.google.client_id') ?? env('GOOGLE_CLIENT_ID');
        if (! is_string($expectedAud) || $expectedAud === '') {
            return response()->json(['message' => 'Login Google não configurado no servidor (GOOGLE_CLIENT_ID).'], 503);
        }

        try {
            /** @var array<string, mixed> $payload */
            $payload = $verifier->verify($data['id_token'], $expectedAud);
        } catch (InvalidArgumentException $e) {
            return response()->json(['message' => $e->getMessage()], 401);
        }

        $email = strtolower(trim((string) ($payload['email'] ?? '')));
        $sub = (string) ($payload['sub'] ?? '');
        if ($email === '' || $sub === '') {
            return response()->json(['message' => 'Token Google sem e-mail ou identificador.'], 422);
        }

        $role = $data['role'] ?? null;

        $user = User::query()->where('google_sub', $sub)->first();

        if ($user === null) {
            $existing = User::query()->where('email', $email)->first();
            if ($existing !== null && $existing->google_sub === null) {
                return response()->json([
                    'message' => 'Já existe conta com este e-mail. Use e-mail e senha ou contacte o suporte para vincular Google.',
                    'code' => 'email_password_account_exists',
                ], 409);
            }

            $manufacturerId = null;
            if ($role === 'manufacturer_admin') {
                $domain = ManufacturerRegistrationSupport::domainFromEmail($email);
                if ($domain === null) {
                    return response()->json(['message' => 'E-mail inválido para registo de fabricante.'], 422);
                }

                $existingByDomain = Manufacturer::query()->where('registration_email_domain', $domain)->first();
                if ($existingByDomain !== null) {
                    $manufacturerId = $existingByDomain->id;
                } else {
                    $nameInput = trim((string) ($data['manufacturer_name'] ?? ''));
                    $displayName = $nameInput !== '' ? $nameInput : 'Fabricante — '.$domain;

                    $cnpjRaw = $data['manufacturer_cnpj'] ?? null;
                    $cnpjDigits = is_string($cnpjRaw) && $cnpjRaw !== ''
                        ? preg_replace('/\D+/', '', $cnpjRaw)
                        : null;

                    $manufacturer = Manufacturer::create([
                        'name' => $displayName,
                        'slug' => Str::slug($displayName).'-'.Str::lower(Str::random(8)),
                        'cnpj' => ($cnpjDigits !== null && $cnpjDigits !== '') ? $cnpjDigits : null,
                        'support_email' => $email,
                        'registration_email_domain' => $domain,
                        'validation_status' => 'pending_info',
                    ]);
                    $manufacturerId = $manufacturer->id;
                    ManufacturerReviewerNotifier::notifyNewRegistrationIfConfigured($manufacturer);
                }
            }

            $user = User::create([
                'name' => (string) ($payload['name'] ?? $email),
                'email' => $email,
                'google_sub' => $sub,
                'password' => Hash::make(Str::password(32)),
                'role' => $role,
                'institution_id' => null,
                'manufacturer_id' => $manufacturerId,
                'avatar_url' => isset($payload['picture']) ? Str::limit((string) $payload['picture'], 500) : null,
            ]);

            // Alguns motores ainda aplicam DEFAULT «trainee» ao INSERT; força NULL para a triagem na app.
            if ($role === null) {
                User::query()->whereKey($user->id)->update(['role' => null]);
                $user->refresh();
            }
        } else {
            $user->forceFill([
                'name' => (string) ($payload['name'] ?? $user->name),
                'avatar_url' => isset($payload['picture']) ? Str::limit((string) $payload['picture'], 500) : $user->avatar_url,
            ])->save();
        }

        return response()->json([
            'token' => $user->createToken('google-web')->plainTextToken,
            'user' => $user->fresh()->toApiArray(),
        ]);
    }
}
