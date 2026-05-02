<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Enrollment;
use App\Models\Training;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class InstructorDashboardController extends Controller
{
    public function show(Request $request)
    {
        $userId = $request->user()->id;

        if (! in_array($request->user()->role, ['instructor', 'institution_admin', 'manufacturer_admin'], true)) {
            return response()->json(['message' => 'Disponível apenas para instrutores e gestores.'], 403);
        }

        $trainingIds = Training::query()->where('instructor_id', $userId)->pluck('id');

        $trainingCount = $trainingIds->count();

        $participantCount = $trainingIds->isEmpty()
            ? 0
            : (int) DB::table('enrollments')
                ->whereIn('training_id', $trainingIds->all())
                ->selectRaw('count(distinct user_id) as c')
                ->value('c');

        $avgScore = $trainingIds->isEmpty()
            ? null
            : Enrollment::query()
                ->whereIn('training_id', $trainingIds)
                ->where('status', 'completed')
                ->whereNotNull('score')
                ->avg('score');

        $finishedTrainingsCount = Training::query()
            ->where('instructor_id', $userId)
            ->where('status', 'finished')
            ->count();

        $approvalStats = $trainingIds->isEmpty()
            ? null
            : DB::table('enrollments')
                ->join('trainings', 'trainings.id', '=', 'enrollments.training_id')
                ->where('trainings.instructor_id', $userId)
                ->where('enrollments.status', 'completed')
                ->whereNotNull('enrollments.score')
                ->selectRaw(
                    'SUM(CASE WHEN enrollments.score >= (COALESCE(trainings.passing_score_percent, 70) / 10.0) THEN 1 ELSE 0 END) as passed,
                     COUNT(*) as total'
                )
                ->first();

        $approvalRatePercent = null;
        if ($approvalStats !== null && (int) $approvalStats->total > 0) {
            $approvalRatePercent = round(100.0 * ((int) $approvalStats->passed) / (int) $approvalStats->total, 1);
        }

        $recent = Training::query()
            ->where('instructor_id', $userId)
            ->with('institution:id,name')
            ->latest()
            ->limit(8)
            ->get();

        return response()->json([
            'training_count' => $trainingCount,
            'finished_trainings_count' => $finishedTrainingsCount,
            'participant_count' => $participantCount,
            'average_score' => $avgScore !== null ? round((float) $avgScore, 2) : null,
            'approval_rate_percent' => $approvalRatePercent,
            'recent_trainings' => $recent,
        ]);
    }
}
