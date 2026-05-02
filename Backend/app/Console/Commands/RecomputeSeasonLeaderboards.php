<?php

namespace App\Console\Commands;

use App\Models\Season;
use App\Services\SeasonLeaderboardService;
use Illuminate\Console\Command;

class RecomputeSeasonLeaderboards extends Command
{
    protected $signature = 'leaderboard:recompute-seasons';

    protected $description = 'Recalcula entradas de ranking para todas as temporadas.';

    public function handle(SeasonLeaderboardService $service): int
    {
        $n = 0;
        Season::query()->orderBy('id')->chunkById(50, function ($seasons) use ($service, &$n): void {
            foreach ($seasons as $season) {
                $service->recompute($season);
                $n++;
            }
        });

        $this->info("Processadas {$n} temporada(s).");

        return self::SUCCESS;
    }
}
