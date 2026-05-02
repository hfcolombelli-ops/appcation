<?php

namespace App\Services;

use App\Models\LeaderboardEntry;
use App\Models\Season;
use Illuminate\Support\Facades\DB;

class SeasonLeaderboardService
{
    public function recompute(Season $season): void
    {
        $start = $season->starts_at->copy()->startOfDay();
        $end = $season->ends_at->copy()->endOfDay();

        $rows = DB::table('trainings')
            ->where('manufacturer_id', $season->manufacturer_id)
            ->where('status', 'finished')
            ->whereBetween('updated_at', [$start, $end])
            ->selectRaw('instructor_id, COUNT(*) as c')
            ->groupBy('instructor_id')
            ->orderByDesc('c')
            ->orderBy('instructor_id')
            ->get();

        DB::transaction(function () use ($season, $rows): void {
            LeaderboardEntry::query()->where('season_id', $season->id)->delete();

            $prevPoints = null;
            $rank = 0;
            $position = 0;

            foreach ($rows as $row) {
                $points = (int) $row->c;
                $position++;
                if ($prevPoints === null || $points !== $prevPoints) {
                    $rank = $position;
                }
                $prevPoints = $points;

                LeaderboardEntry::query()->create([
                    'season_id' => $season->id,
                    'instructor_id' => (int) $row->instructor_id,
                    'points' => $points,
                    'rank' => $rank,
                    'last_computed_at' => now(),
                ]);
            }
        });
    }
}
