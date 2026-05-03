<?php

namespace App\Services;

use Firebase\JWT\ExpiredException;
use Firebase\JWT\JWK;
use Firebase\JWT\JWT;
use Firebase\JWT\SignatureInvalidException;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use InvalidArgumentException;
use Throwable;

/**
 * Verifica ID tokens do Google com JWKS (substitui oauth2.googleapis.com/tokeninfo, pouco fiável em produção).
 */
class GoogleIdTokenVerifier
{
    private const JWKS_URI = 'https://www.googleapis.com/oauth2/v3/certs';

    /**
     * @return array<string, mixed>
     */
    public function verify(string $idToken, string $expectedClientId): array
    {
        $expectedClientId = trim($expectedClientId);
        if ($expectedClientId === '') {
            throw new InvalidArgumentException('Client ID vazio.');
        }

        $idToken = trim($idToken);
        if ($idToken === '') {
            throw new InvalidArgumentException('Token vazio.');
        }

        $jwksBody = Cache::remember('google:id_token:jwks:v3', 43200, function (): string {
            $res = Http::timeout(15)->get(self::JWKS_URI);
            if (! $res->successful()) {
                throw new InvalidArgumentException('Chaves públicas Google indisponíveis.');
            }

            return $res->body();
        });

        /** @var array<string, mixed> $jwks */
        $jwks = json_decode($jwksBody, true, 512, JSON_THROW_ON_ERROR);
        $keys = JWK::parseKeySet($jwks);

        JWT::$leeway = 120;

        try {
            $decoded = JWT::decode($idToken, $keys);
        } catch (SignatureInvalidException $e) {
            throw new InvalidArgumentException('Assinatura do token inválida.', 0, $e);
        } catch (ExpiredException $e) {
            throw new InvalidArgumentException('Token Google expirado.', 0, $e);
        } catch (Throwable $e) {
            throw new InvalidArgumentException('Token Google inválido.', 0, $e);
        }

        /** @var array<string, mixed> $payload */
        $payload = json_decode(json_encode($decoded, JSON_THROW_ON_ERROR), true);

        $iss = (string) ($payload['iss'] ?? '');
        if ($iss !== 'https://accounts.google.com' && $iss !== 'accounts.google.com') {
            throw new InvalidArgumentException('Emissor do token inválido.');
        }

        $aud = $payload['aud'] ?? null;
        $audOk = $aud === $expectedClientId;
        if (! $audOk && is_array($aud)) {
            $audOk = in_array($expectedClientId, $aud, true);
        }
        if (! $audOk) {
            throw new InvalidArgumentException('Audiência do token não confere com este aplicativo.');
        }

        if (isset($payload['email_verified'])
            && $payload['email_verified'] !== true
            && $payload['email_verified'] !== 'true') {
            throw new InvalidArgumentException('E-mail Google não verificado.');
        }

        return $payload;
    }
}
