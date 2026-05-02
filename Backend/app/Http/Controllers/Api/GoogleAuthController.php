<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Manufacturer;
use App\Models\User;
use App\Services\ManufacturerReviewerNotifier;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class GoogleAuthController extends Controller
{
    /**
     * Login ou registo via Google ID token (Flutter Web / mobile).
     * Configure GOOGLE_CLIENT_ID igual ao OAuth Client ID (tipo Web) usado no cliente.
     */
    public function callback(Request $request)
    {
        $data = $request->validate([
            'id_token' => ['required', 'string'],
            'role' => ['nullable', 'in:trainee,instructor,manufacturer_admin'],
            'manufacturer_name' => ['required_if:role,manufacturer_admin', 'string', 'max:180'],
            'manufacturer_cnpj' => ['nullable', 'string', 'max:20'],
        ]);

        $expectedAud = config('services.google.client_id') ?? env('GOOGLE_CLIENT_ID');
        if (! is_string($expectedAud) || $expectedAud === '') {
            return response()->json(['message' => 'Login Google não configurado no servidor (GOOGLE_CLIENT_ID).'], 503);
        }

        $tokenResponse = Http::timeout(10)->get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $data['id_token'],
        ]);

        if (! $tokenResponse->successful()) {
            return response()->json(['message' => 'Token Google inválido ou expirado.'], 401);
        }

        /** @var array<string, mixed> $payload */
        $payload = $tokenResponse->json();

        if (($payload['aud'] ?? null) !== $expectedAud) {
            return response()->json(['message' => 'Audiência do token não confere com este aplicativo.'], 401);
        }

        $email = strtolower(trim((string) ($payload['email'] ?? '')));
        $sub = (string) ($payload['sub'] ?? '');
        if ($email === '' || $sub === '') {
            return response()->json(['message' => 'Token Google sem e-mail ou identificador.'], 422);
        }

        $role = $data['role'] ?? 'trainee';

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
                $manufacturer = Manufacturer::create([
                    'name' => $data['manufacturer_name'],
                    'slug' => Str::slug($data['manufacturer_name']).'-'.Str::lower(Str::random(8)),
                    'cnpj' => $data['manufacturer_cnpj'] ?? null,
                    'support_email' => $email,
                    'validation_status' => 'pending_info',
                ]);
                $manufacturerId = $manufacturer->id;
                ManufacturerReviewerNotifier::notifyNewRegistrationIfConfigured($manufacturer);
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
