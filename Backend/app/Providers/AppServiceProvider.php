<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RateLimiter::for('auth-login', function (Request $request) {
            // Evita partilha injusta do limite quando vários clientes vêm do mesmo IP (proxy/CDN)
            // ou quando o IP visto pelo Laravel é sempre o do edge. Limites por e-mail + tecto por IP.
            // Prefixo v2: ignora entradas antigas do limitador «8/15min» ainda em cache.
            $raw = strtolower(trim((string) ($request->input('identifier') ?? $request->input('email') ?? '')));
            $emailKey = $raw !== '' ? sha1($raw) : 'empty';

            return [
                Limit::perMinute(40)->by('v2:login:email:'.$emailKey),
                Limit::perMinute(200)->by('v2:login:ip:'.$request->ip()),
            ];
        });

        RateLimiter::for('auth-register', function (Request $request) {
            $raw = strtolower(trim((string) ($request->input('email') ?? '')));
            $emailKey = $raw !== '' ? sha1($raw) : 'empty';

            return [
                Limit::perMinute(15)->by('v2:reg:email:'.$emailKey),
                Limit::perMinute(40)->by('v2:reg:ip:'.$request->ip()),
            ];
        });

        RateLimiter::for('auth-google', function (Request $request) {
            return Limit::perMinutes(60, 15)->by($request->ip());
        });

        RateLimiter::for('public-read', function (Request $request) {
            return Limit::perMinute(60)->by($request->ip());
        });

        RateLimiter::for('api-user', function (Request $request) {
            return Limit::perMinute(180)->by((string) $request->user()->id);
        });

        RateLimiter::for('sensitive', function (Request $request) {
            return Limit::perMinute(40)->by((string) $request->user()->id);
        });

        RateLimiter::for('gdpr-heavy', function (Request $request) {
            return Limit::perHour(6)->by((string) $request->user()->id);
        });

        RateLimiter::for('realtime-command', function (Request $request) {
            return Limit::perMinute(90)->by((string) $request->user()->id);
        });
    }
}
