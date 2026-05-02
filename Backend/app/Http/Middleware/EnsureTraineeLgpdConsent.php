<?php

namespace App\Http\Middleware;

use App\Models\UserConsent;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureTraineeLgpdConsent
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user === null || $user->role !== 'trainee') {
            return $next($request);
        }

        if (! UserConsent::hasActive($user, 'lgpd_trainee')) {
            return response()->json([
                'message' => 'É necessário aceitar o consentimento LGPD antes de continuar.',
                'code' => 'lgpd_consent_required',
            ], 428);
        }

        return $next($request);
    }
}
