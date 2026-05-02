<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class HealthController
{
    public function __invoke(): JsonResponse
    {
        $dbOk = false;
        $dbLatencyMs = null;

        $started = microtime(true);
        try {
            DB::select('select 1');
            $dbOk = true;
            $dbLatencyMs = round((microtime(true) - $started) * 1000, 2);
        } catch (\Throwable $e) {
            Log::error('health.database_check_failed', [
                'exception' => $e->getMessage(),
            ]);
        }

        $googleClientId = config('services.google.client_id');
        $googleOauthConfigured = is_string($googleClientId) && trim($googleClientId) !== '';

        $checks = [
            'database' => [
                'ok' => $dbOk,
                'latency_ms' => $dbLatencyMs,
            ],
            'google_oauth' => [
                'configured' => $googleOauthConfigured,
            ],
        ];

        $status = $dbOk ? 'ok' : 'degraded';

        $payload = [
            'status' => $status,
            'app' => config('app.name'),
            'version' => config('app.version'),
            'environment' => config('app.env'),
            'time' => now()->toIso8601String(),
            'checks' => $checks,
        ];

        $code = $dbOk ? 200 : 503;

        return response()->json($payload, $code);
    }
}
