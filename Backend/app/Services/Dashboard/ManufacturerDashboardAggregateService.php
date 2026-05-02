<?php

namespace App\Services\Dashboard;

use Illuminate\Support\Facades\DB;

class ManufacturerDashboardAggregateService
{
    /**
     * @return array<string, mixed>
     */
    public function aggregate(int $manufacturerId): array
    {
        $trainingsCount = (int) DB::table('trainings')
            ->where('manufacturer_id', $manufacturerId)
            ->count();

        $finishedTrainingsCount = (int) DB::table('trainings')
            ->where('manufacturer_id', $manufacturerId)
            ->where('status', 'finished')
            ->count();

        $totals = DB::table('enrollments as e')
            ->join('trainings as t', 't.id', '=', 'e.training_id')
            ->where('t.manufacturer_id', $manufacturerId)
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

        $avgScoreRow = DB::table('enrollments as e')
            ->join('trainings as t', 't.id', '=', 'e.training_id')
            ->where('t.manufacturer_id', $manufacturerId)
            ->where('e.status', 'completed')
            ->whereNotNull('e.score')
            ->selectRaw('ROUND(AVG(e.score), 2) as avg_score')
            ->first();
        $avgScoreCompleted = $avgScoreRow !== null && $avgScoreRow->avg_score !== null
            ? (float) $avgScoreRow->avg_score
            : null;

        $byInstitutionRows = DB::table('enrollments as e')
            ->join('trainings as t', 't.id', '=', 'e.training_id')
            ->leftJoin('institutions as i', 'i.id', '=', 't.institution_id')
            ->where('t.manufacturer_id', $manufacturerId)
            ->groupBy('t.institution_id')
            ->selectRaw("
                t.institution_id,
                MIN(i.name) as institution_name,
                COUNT(DISTINCT t.id) as trainings_count,
                COUNT(*) as total_enrollments,
                SUM(CASE WHEN e.status = 'completed' THEN 1 ELSE 0 END) as completed_count,
                ROUND(AVG(CASE WHEN e.status = 'completed' AND e.score IS NOT NULL THEN e.score END), 2) as avg_score
            ")
            ->orderByRaw('t.institution_id IS NULL, institution_name')
            ->get();

        $aggregatedByInstitution = $byInstitutionRows->map(function ($row) {
            $total = (int) $row->total_enrollments;
            $done = (int) $row->completed_count;
            $name = $row->institution_name;
            $label = ($row->institution_id === null || $name === null || $name === '')
                ? 'Sem instituição'
                : (string) $name;

            return [
                'institution_id' => $row->institution_id !== null ? (int) $row->institution_id : null,
                'label' => $label,
                'trainings_count' => (int) $row->trainings_count,
                'total_enrollments' => $total,
                'completed_count' => $done,
                'completion_rate_percent' => $total > 0 ? round(100 * $done / $total, 1) : null,
                'avg_score' => $row->avg_score !== null ? (float) $row->avg_score : null,
            ];
        })->values();

        $byEquipmentRows = DB::table('enrollments as e')
            ->join('trainings as t', 't.id', '=', 'e.training_id')
            ->leftJoin('equipment as eq', 'eq.id', '=', 't.equipment_id')
            ->where('t.manufacturer_id', $manufacturerId)
            ->groupBy('t.equipment_id')
            ->selectRaw("
                t.equipment_id,
                MIN(eq.name) as equipment_name,
                MIN(eq.model) as equipment_model,
                COUNT(DISTINCT t.id) as trainings_count,
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

            if ($label === '' && $eid !== null) {
                $label = 'Equipamento #'.$eid;
            }

            return [
                'equipment_id' => $eid !== null ? (int) $eid : null,
                'label' => $label,
                'trainings_count' => (int) $row->trainings_count,
                'total_enrollments' => $total,
                'completed_count' => $done,
                'completion_rate_percent' => $total > 0 ? round(100 * $done / $total, 1) : null,
                'avg_score' => $row->avg_score !== null ? (float) $row->avg_score : null,
            ];
        })->values();

        return [
            'trainings_count' => $trainingsCount,
            'finished_trainings_count' => $finishedTrainingsCount,
            'completion_summary' => [
                'total_enrollments' => $totalEnrollments,
                'completed_count' => $completedCount,
                'completion_rate_percent' => $completionRate,
            ],
            'avg_score_completed' => $avgScoreCompleted,
            'aggregated_by_institution' => $aggregatedByInstitution,
            'aggregated_by_equipment' => $aggregatedByEquipment,
        ];
    }
}
