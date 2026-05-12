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
            // Antes: 8/15min por IP — demasiado agressivo (429 na Web, mesmo utilizador a corrigir senha).
            return Limit::perMinute(45)->by($request->ip());
        });

        RateLimiter::for('auth-register', function (Request $request) {
            return Limit::perMinute(20)->by($request->ip());
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
