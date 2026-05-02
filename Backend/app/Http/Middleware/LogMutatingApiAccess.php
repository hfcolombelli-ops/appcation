<?php

namespace App\Http\Middleware;

use App\Models\AccessLog;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Registra chamadas mutáveis à API (sem corpo) — retenção 90 dias via comando agendado.
 */
class LogMutatingApiAccess
{
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        if (! in_array($request->method(), ['POST', 'PUT', 'PATCH', 'DELETE'], true)) {
            return $response;
        }

        $path = '/'.$request->path();

        if (str_starts_with($path, '/api/health') || str_starts_with($path, '/up')) {
            return $response;
        }

        AccessLog::query()->create([
            'request_id' => $request->attributes->get('request_id'),
            'user_id' => $request->user()?->id,
            'ip_address' => $request->ip(),
            'user_agent' => substr((string) $request->userAgent(), 0, 2000),
            'endpoint' => substr($path, 0, 512),
            'http_method' => $request->method(),
            'response_status' => $response->getStatusCode(),
            'created_at' => now(),
        ]);

        return $response;
    }
}
