<?php

namespace App\Services\Dashboard;

use Illuminate\Database\Query\Builder;
use Illuminate\Support\Facades\DB;

class ManufacturerDashboardAggregateService
{
    /**
     * @param  array<string, mixed>  $filters
     * @return array<string, mixed>
     */
    public function aggregate(int $manufacturerId, array $filters = []): array
    {
        $trainingsCount = (int) $this->trainingTableQuery($manufacturerId, $filters)->count();

        $finishedTrainingsCount = (int) $this->trainingTableQuery($manufacturerId, $filters)
            ->where('t.status', 'finished')
            ->count();

        $totals = $this->enrollmentTrainingJoin($manufacturerId, $filters)
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

        $avgScoreRow = $this->enrollmentTrainingJoin($manufacturerId, $filters)
            ->where('e.status', 'completed')
            ->whereNotNull('e.score')
            ->selectRaw('ROUND(AVG(e.score), 2) as avg_score')
            ->first();
        $avgScoreCompleted = $avgScoreRow !== null && $avgScoreRow->avg_score !== null
            ? (float) $avgScoreRow->avg_score
            : null;

        $byInstitutionRows = $this->enrollmentTrainingJoin($manufacturerId, $filters)
            ->leftJoin('institutions as i', 'i.id', '=', 't.institution_id')
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

        $byEquipmentRows = $this->enrollmentTrainingJoin($manufacturerId, $filters)
            ->leftJoin('equipment as eq', 'eq.id', '=', 't.equipment_id')
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

        $periodExpr = $this->monthPeriodSql('e.completed_at');
        $completedByMonthRows = $this->enrollmentTrainingJoin($manufacturerId, $filters)
            ->where('e.status', 'completed')
            ->whereNotNull('e.completed_at')
            ->groupBy(DB::raw($periodExpr))
            ->selectRaw("{$periodExpr} as period, COUNT(*) as completed_count")
            ->orderBy('period')
            ->get();

        $completedByMonth = $completedByMonthRows->map(function ($row) {
            return [
                'period' => (string) $row->period,
                'completed_count' => (int) $row->completed_count,
            ];
        })->values();

        $joinedOrCreated = 'COALESCE(e.joined_at, e.created_at)';
        $enrollPeriodExpr = $this->monthPeriodSqlForExpression($joinedOrCreated);
        $enrollmentsByMonthRows = $this->enrollmentTrainingJoin($manufacturerId, $filters)
            ->groupBy(DB::raw($enrollPeriodExpr))
            ->selectRaw("{$enrollPeriodExpr} as period, COUNT(*) as enrollment_count")
            ->orderBy('period')
            ->get();

        $enrollmentsByMonth = $enrollmentsByMonthRows->map(function ($row) {
            return [
                'period' => (string) $row->period,
                'enrollment_count' => (int) $row->enrollment_count,
            ];
        })->values();

        $enrollByPeriod = $enrollmentsByMonth->keyBy('period');
        $completedByPeriod = $completedByMonth->keyBy('period');
        $allPeriods = $enrollByPeriod->keys()
            ->merge($completedByPeriod->keys())
            ->unique()
            ->sort()
            ->values();

        $monthlyTrend = $allPeriods->map(function (string $period) use ($enrollByPeriod, $completedByPeriod) {
            $eRow = $enrollByPeriod->get($period);
            $cRow = $completedByPeriod->get($period);

            return [
                'period' => $period,
                'enrollment_count' => (int) (is_array($eRow) ? ($eRow['enrollment_count'] ?? 0) : 0),
                'completed_count' => (int) (is_array($cRow) ? ($cRow['completed_count'] ?? 0) : 0),
            ];
        })->values()->all();

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
            'completed_by_month' => $completedByMonth,
            'enrollments_by_month' => $enrollmentsByMonth,
            'monthly_trend' => $monthlyTrend,
        ];
    }

    /**
     * Expressão SQL para agrupar por mês civil (AAAA-MM), compatível com sqlite / mysql / pgsql.
     */
    private function monthPeriodSql(string $column): string
    {
        return match (DB::connection()->getDriverName()) {
            'mysql', 'mariadb' => "DATE_FORMAT({$column}, '%Y-%m')",
            'pgsql' => "to_char(({$column}) at time zone 'UTC', 'YYYY-MM')",
            default => "strftime('%Y-%m', {$column})",
        };
    }

    /**
     * Mês civil (AAAA-MM) a partir de uma expressão SQL já qualificada (ex.: COALESCE(e.joined_at, e.created_at)).
     */
    private function monthPeriodSqlForExpression(string $sqlExpression): string
    {
        return match (DB::connection()->getDriverName()) {
            'mysql', 'mariadb' => "DATE_FORMAT({$sqlExpression}, '%Y-%m')",
            'pgsql' => "to_char(({$sqlExpression}) at time zone 'UTC', 'YYYY-MM')",
            default => "strftime('%Y-%m', {$sqlExpression})",
        };
    }

    /**
     * @param  array<string, mixed>  $filters
     */
    private function enrollmentTrainingJoin(int $manufacturerId, array $filters): Builder
    {
        $q = DB::table('enrollments as e')
            ->join('trainings as t', 't.id', '=', 'e.training_id')
            ->where('t.manufacturer_id', $manufacturerId);
        $this->applyTrainingFilters($q, $filters);

        return $q;
    }

    /**
     * @param  array<string, mixed>  $filters
     */
    private function trainingTableQuery(int $manufacturerId, array $filters): Builder
    {
        $q = DB::table('trainings as t')
            ->where('t.manufacturer_id', $manufacturerId);
        $this->applyTrainingFilters($q, $filters);

        return $q;
    }

    /**
     * @param  array<string, mixed>  $filters
     */
    private function applyTrainingFilters(Builder $query, array $filters): void
    {
        if (! empty($filters['institution_id'])) {
            $query->where('t.institution_id', (int) $filters['institution_id']);
        }
        if (! empty($filters['equipment_id'])) {
            $query->where('t.equipment_id', (int) $filters['equipment_id']);
        }
        if (! empty($filters['training_created_from'])) {
            $query->whereDate('t.created_at', '>=', (string) $filters['training_created_from']);
        }
        if (! empty($filters['training_created_to'])) {
            $query->whereDate('t.created_at', '<=', (string) $filters['training_created_to']);
        }
    }
}
