<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Manufacturer;
use App\Models\User;
use App\Services\ManufacturerReviewerNotifier;
use App\Support\ManufacturerRegistrationSupport;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    /** @var list<string> */
    private const APP_MAPPED_ROLES = ['trainee', 'instructor', 'institution_admin', 'manufacturer_admin'];

    public function register(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:190', 'unique:users,email'],
            'password' => ['required', Password::min(8)],
            'role' => ['required', 'in:trainee,instructor,manufacturer_admin'],
            'phone' => ['nullable', 'string', 'max:25'],
            'manufacturer_name' => ['nullable', 'string', 'max:180'],
            'manufacturer_cnpj' => ['nullable', 'string', 'max:20'],
        ]);

        $manufacturerId = null;

        if ($data['role'] === 'manufacturer_admin') {
            $domain = ManufacturerRegistrationSupport::domainFromEmail($data['email']);
            if ($domain === null) {
                return response()->json(['message' => 'E-mail inválido para registo de fabricante.'], 422);
            }

            $existingByDomain = Manufacturer::query()->where('registration_email_domain', $domain)->first();
            if ($existingByDomain !== null) {
                $manufacturerId = $existingByDomain->id;
            } else {
                $mfgName = trim((string) ($data['manufacturer_name'] ?? ''));
                if ($mfgName === '') {
                    return response()->json([
                        'message' => 'Informe o nome da empresa para o primeiro registo deste domínio.',
                        'errors' => ['manufacturer_name' => ['O campo nome da empresa é obrigatório quando ainda não existe fabricante para este domínio.']],
                    ], 422);
                }

                $cnpjRaw = $data['manufacturer_cnpj'] ?? null;
                $cnpjDigits = is_string($cnpjRaw) && $cnpjRaw !== ''
                    ? preg_replace('/\D+/', '', $cnpjRaw)
                    : null;

                $createdManufacturerHere = false;
                $manufacturer = null;
                try {
                    $manufacturer = Manufacturer::create([
                        'name' => $mfgName,
                        'slug' => $this->newUniqueManufacturerSlug($mfgName),
                        'cnpj' => ($cnpjDigits !== null && $cnpjDigits !== '') ? $cnpjDigits : null,
                        'support_email' => $data['email'],
                        'registration_email_domain' => $domain,
                        'status' => 'active',
                        'validation_status' => 'pending_info',
                    ]);
                    $createdManufacturerHere = true;
                } catch (QueryException $e) {
                    if (! $this->isIntegrityConstraintViolation($e)) {
                        Log::error('auth.register.manufacturer_create', [
                            'domain' => $domain,
                            'message' => $e->getMessage(),
                        ]);
                        throw $e;
                    }
                    $manufacturer = Manufacturer::query()->where('registration_email_domain', $domain)->first();
                }

                if ($manufacturer === null) {
                    Log::error('auth.register.manufacturer_missing_after_race', ['domain' => $domain]);

                    return response()->json([
                        'message' => 'Não foi possível concluir o registo do fabricante. Recarregue e tente de novo.',
                    ], 500);
                }

                $manufacturerId = $manufacturer->id;
                if ($createdManufacturerHere) {
                    ManufacturerReviewerNotifier::notifyNewRegistrationIfConfigured($manufacturer);
                }
            }
        }

        unset($data['manufacturer_name'], $data['manufacturer_cnpj']);

        try {
            $user = User::create(array_merge($data, [
                'manufacturer_id' => $manufacturerId,
                'google_triage_completed_at' => now(),
            ]));
        } catch (QueryException $e) {
            if ($this->isIntegrityConstraintViolation($e)) {
                return response()->json([
                    'message' => 'Este e-mail já está registado. Use «Entrar» ou recuperação de senha.',
                    'errors' => ['email' => ['Este e-mail já está em uso.']],
                ], 422);
            }
            Log::error('auth.register.user_create', ['message' => $e->getMessage()]);
            throw $e;
        }

        try {
            $token = $user->createToken('web')->plainTextToken;
        } catch (\Throwable $e) {
            Log::error('auth.register.token_create', ['message' => $e->getMessage(), 'user_id' => $user->id]);

            return response()->json([
                'message' => 'Conta criada, mas falhou a emissão do token de sessão. Verifique Sanctum (tabela personal_access_tokens) no servidor.',
            ], 503);
        }

        return response()->json([
            'token' => $token,
            'user' => $user->fresh()->toApiArray(),
        ], 201);
    }

    private function newUniqueManufacturerSlug(string $mfgName): string
    {
        $base = Str::slug($mfgName);
        if ($base === '') {
            $base = 'fabricante';
        }

        for ($i = 0; $i < 16; $i++) {
            $slug = $base.'-'.Str::lower(Str::random(10));
            if (! Manufacturer::query()->where('slug', $slug)->exists()) {
                return $slug;
            }
        }

        return $base.'-'.Str::lower(Str::random(16));
    }

    private function isIntegrityConstraintViolation(QueryException $e): bool
    {
        $sqlState = (string) ($e->errorInfo[0] ?? '');
        if ($sqlState === '23505') {
            return true;
        }

        $driverCode = (int) ($e->errorInfo[1] ?? 0);
        if ($driverCode === 1062) {
            return true;
        }

        $msg = strtolower($e->getMessage());

        return str_contains($msg, 'duplicate')
            || str_contains($msg, 'unique constraint')
            || str_contains($msg, 'integrity constraint');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            // Compatível com clientes antigos (`email`) e fluxo tipo URS (`identifier`).
            'email' => ['required_without:identifier', 'nullable', 'email', 'max:190'],
            'identifier' => ['required_without:email', 'nullable', 'string', 'max:190'],
            'password' => ['required', 'string'],
        ]);

        $raw = $credentials['email'] ?? $credentials['identifier'] ?? '';
        $trimmed = strtolower(trim((string) $raw));
        $password = $credentials['password'];

        $user = null;

        if ($trimmed !== '' && filter_var($trimmed, FILTER_VALIDATE_EMAIL)) {
            $user = User::query()->where('email', $trimmed)->first();
        } else {
            $cnpjDigits = preg_replace('/\D+/', '', (string) $raw);
            if (strlen($cnpjDigits) === 14) {
                $manufacturer = Manufacturer::query()->where('cnpj', $cnpjDigits)->first();
                if ($manufacturer !== null) {
                    $candidates = User::query()
                        ->where('manufacturer_id', $manufacturer->id)
                        ->where('role', 'manufacturer_admin')
                        ->whereNotNull('password')
                        ->get();
                    foreach ($candidates as $candidate) {
                        if (Hash::check($password, $candidate->password)) {
                            $user = $candidate;
                            break;
                        }
                    }
                }
            }
        }

        if ($user === null || $user->password === null || ! Hash::check($password, $user->password)) {
            return response()->json(['message' => 'Credenciais inválidas.'], 422);
        }

        return response()->json([
            'token' => $user->createToken('web')->plainTextToken,
            'user' => $user->toApiArray(),
        ]);
    }

    public function me(Request $request)
    {
        return response()->json($request->user()->toApiArray());
    }

    /** Preferências de notificação (digesto semanal de resumo agregado). */
    public function updateNotificationPreferences(Request $request)
    {
        $data = $request->validate([
            'weekly_dashboard_digest' => ['required', 'boolean'],
        ]);

        $request->user()->update([
            'weekly_dashboard_digest' => $data['weekly_dashboard_digest'],
        ]);

        return response()->json($request->user()->fresh()->toApiArray());
    }

    /**
     * Utilizador sem `role` mapeável na app (vazio, nulo ou valor desconhecido) pode escolher
     * traine/instructor/fabricante uma vez — mesmo contrato que o registo inicial.
     */
    public function updateMyRole(Request $request)
    {
        $user = $request->user();

        $data = $request->validate([
            'role' => ['required', 'in:trainee,instructor,manufacturer_admin'],
            'manufacturer_name' => ['nullable', 'string', 'max:180'],
            'manufacturer_cnpj' => ['nullable', 'string', 'max:20'],
        ]);

        // Perfil já fechado no servidor: reconfirmar o mesmo role (ex.: triagem UI desfasada) deve ser 200, não 403.
        if (! $user->needsProfileGateForApi() && $this->roleIsMappedForApp($user->role)) {
            $requested = trim((string) $data['role']);
            $current = trim((string) ($user->role ?? ''));
            if ($requested !== '' && $current !== '' && strcasecmp($requested, $current) === 0) {
                return response()->json($user->fresh()->toApiArray());
            }

            return response()->json([
                'message' => 'O perfil já está definido. Use «Actualizar sessão» ou contacte o suporte para alterações.',
            ], 403);
        }

        $manufacturerId = null;

        if ($data['role'] === 'manufacturer_admin') {
            $email = (string) $user->email;
            $domain = ManufacturerRegistrationSupport::domainFromEmail($email);
            if ($domain === null) {
                return response()->json(['message' => 'E-mail inválido para registo de fabricante.'], 422);
            }

            $existingByDomain = Manufacturer::query()->where('registration_email_domain', $domain)->first();
            if ($existingByDomain !== null) {
                $manufacturerId = $existingByDomain->id;
            } else {
                $mfgName = trim((string) ($data['manufacturer_name'] ?? ''));
                if ($mfgName === '') {
                    return response()->json([
                        'message' => 'Informe o nome da empresa para o primeiro registo deste domínio.',
                        'errors' => ['manufacturer_name' => ['O campo nome da empresa é obrigatório quando ainda não existe fabricante para este domínio.']],
                    ], 422);
                }

                $cnpjRaw = $data['manufacturer_cnpj'] ?? null;
                $cnpjDigits = is_string($cnpjRaw) && $cnpjRaw !== ''
                    ? preg_replace('/\D+/', '', $cnpjRaw)
                    : null;

                $manufacturer = Manufacturer::create([
                    'name' => $mfgName,
                    'slug' => Str::slug($mfgName).'-'.Str::lower(Str::random(8)),
                    'cnpj' => ($cnpjDigits !== null && $cnpjDigits !== '') ? $cnpjDigits : null,
                    'support_email' => $email,
                    'registration_email_domain' => $domain,
                    'status' => 'active',
                    'validation_status' => 'pending_info',
                ]);
                $manufacturerId = $manufacturer->id;
                ManufacturerReviewerNotifier::notifyNewRegistrationIfConfigured($manufacturer);
            }
        }

        $payload = ['role' => $data['role'], 'google_triage_completed_at' => now()];
        if ($data['role'] === 'manufacturer_admin') {
            $payload['manufacturer_id'] = $manufacturerId;
        } else {
            $payload['manufacturer_id'] = null;
        }

        $user->update($payload);

        return response()->json($user->fresh()->toApiArray());
    }

    private function roleIsMappedForApp(?string $role): bool
    {
        if ($role === null) {
            return false;
        }

        $r = trim($role);

        return $r !== '' && in_array($r, self::APP_MAPPED_ROLES, true);
    }

    /** Gestor: define ou altera a instituição do perfil (Fase 1 roadmap). */
    public function updateMyInstitution(Request $request)
    {
        if ($request->user()->role !== 'institution_admin') {
            return response()->json(['message' => 'Apenas gestores de instituição podem vincular instituição.'], 403);
        }

        $data = $request->validate([
            'institution_id' => ['required', 'integer', 'exists:institutions,id'],
        ]);

        $request->user()->update(['institution_id' => $data['institution_id']]);

        return response()->json($request->user()->fresh()->toApiArray());
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json(['message' => 'Sessão encerrada com sucesso.']);
    }
}
