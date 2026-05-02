<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Enrollment;
use App\Models\TraineeProfile;
use App\Models\UserConsent;
use Illuminate\Http\Request;

class TraineeStateController extends Controller
{
    public function show(Request $request)
    {
        if ($request->user()->role !== 'trainee') {
            return response()->json(['message' => 'Estado disponível apenas para treinandos.'], 403);
        }

        $userId = $request->user()->id;

        $profile = TraineeProfile::query()
            ->where('user_id', $userId)
            ->with('institution:id,name')
            ->first();

        $enrollment = Enrollment::query()
            ->where('user_id', $userId)
            ->whereIn('status', ['waiting', 'active'])
            ->with(['training' => function ($q) {
                $q->with('institution:id,name');
            }])
            ->latest('updated_at')
            ->first();

        if ($enrollment === null) {
            $enrollment = Enrollment::query()
                ->where('user_id', $userId)
                ->with(['training' => function ($q) {
                    $q->with('institution:id,name');
                }])
                ->latest('updated_at')
                ->first();
        }

        $needsLgpdConsent = ! UserConsent::hasActive($request->user(), 'lgpd_trainee');

        return response()->json([
            'profile' => $profile,
            'enrollment' => $enrollment,
            'needs_lgpd_consent' => $needsLgpdConsent,
            'privacy_policy_version' => config('lgpd.privacy_policy_version'),
        ]);
    }
}
