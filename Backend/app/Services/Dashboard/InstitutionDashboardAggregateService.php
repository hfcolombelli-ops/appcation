<?php

namespace App\Services\Dashboard;

use App\Models\TrainingRequest;
use Illuminate\Support\Facades\DB;

class InstitutionDashboardAggregateService
{
    /**
     * @return array<string, mixed>
     */
    public function aggregate(int $institutionId): array
    {
        $bySector = DB::table('enrollments as e')
            ->join('users as u', 'u.id', '=', 'e.user_id')
            ->join('trainee_profiles as tp', 'tp.user_id', '=', 'u.id')
            ->where('tp.institution_id', $institutionId)
            ->where('e.status', 'completed')
            ->whereNotNull('e.score')
            ->groupBy('tp.sector')
            ->selectRaw('tp.sector, ROUND(AVG(e.score), 2) as avg_score, COUNT(*) as completions')
            ->orderBy('tp.sector')
            ->get();

        $pendingRequests = TrainingRequest::query()
            ->where('institution_id', $institutionId)
            ->where('status', 'pending')
            ->count();

        $totals = DB::table('enrollments as e')
            ->join('trainings as t', 't.id', '=', 'e.training_id')
            ->where('t.institution_id', $institutionId)
            ->selectRaw("
                COUNT(*) as total_enrollments,
                SUM(CASE WHEN e.status = 'completed' THEN 1 ELSE 0 END) as completed_count
            ")
            ->first();

        $totalEnrollments = (int) ($totals->total_enrollments ?? 0);
        $completedCount = (int) ($totals->completed_count ?? 0);
        $completionRate = $totalEnrollments > 0
            ? round(100 * $completedCount / $totalEnrollments, 1)
            : null;

        $trainingsCount = (int) DB::table('trainings')
            ->where('institution_id', $institutionId)
            ->count();

        $avgScoreRow = DB::table('enrollments as e')
            ->join('trainings as t', 't.id', '=', 'e.training_id')
            ->where('t.institution_id', $institutionId)
            ->where('e.status', 'completed')
            ->whereNotNull('e.score')
            ->selectRaw('ROUND(AVG(e.score), 2) as avg_score')
            ->first();
        $avgScoreCompleted = $avgScoreRow !== null && $avgScoreRow->avg_score !== null
            ? (float) $avgScoreRow->avg_score
            : null;

        $byEquipmentRows = DB::table('enrollments as e')
            ->join('trainings as t', 't.id', '=', 'e.training_id')
            ->leftJoin('equipment as eq', 'eq.id', '=', 't.equipment_id')
            ->where('t.institution_id', $institutionId)
            ->groupBy('t.equipment_id')
            ->selectRaw("
                t.equipment_id,
                MIN(eq.name) as equipment_name,
                MIN(eq.model) as equipment_model,
                COUNT(*) as total_enrollments,
                SUM(CASE WHEN e.status = 'completed' THEN 1 ELSE 0 END) as completed_count,
                ROUND(AVG(CASE WHEN e.status = 'completed' AND e.score IS NOT NULL THEN e.score END), 2) as avg_score
            ")
            ->orderByRaw('t.equipment_id IS NULL, t.equipment_id')
            ->get();

        $aggregatedByEquipment = $byEquipmentRows->map(function ($row) {
            $total = (int) $row->total_enrollments;
            $done = (int) $row->completed_count;
            $eid = $row->equipment_id;

            $label = $eid === null
                ? 'Sem equipamento associado'
                : trim(((string) ($row->equipment_name ?? '')).' '.((string) ($row->equipment_model ?? '')));

            if ($label === '') {
                $label = 'Equipamento #'.$eid;
            }

            return [
                'equipment_id' => $eid !== null ? (int) $eid : null,
                'label' => $label,
                'total_enrollments' => $total,
                'completed_count' => $done,
                'completion_rate_percent' => $total > 0 ? round(100 * $done / $total, 1) : null,
                'avg_score' => $row->avg_score !== null ? (float) $row->avg_score : null,
            ];
        })->values();

        return [
            'aggregated_by_sector' => $bySector,
            'pending_training_requests' => $pendingRequests,
            'completion_summary' => [
                'total_enrollments' => $totalEnrollments,
                'completed_count' => $completedCount,
                'completion_rate_percent' => $completionRate,
            ],
            'avg_score_completed' => $avgScoreCompleted,
            'trainings_count' => $trainingsCount,
            'aggregated_by_equipment' => $aggregatedByEquipment,
        ];
    }
}
