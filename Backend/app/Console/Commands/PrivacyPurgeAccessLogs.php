<?php

namespace App\Console\Commands;

use App\Models\AccessLog;
use Illuminate\Console\Command;

class PrivacyPurgeAccessLogs extends Command
{
    protected $signature = 'privacy:purge-access-logs {--days=90 : Retenção em dias}';

    protected $description = 'Remove access_logs mais antigos que o prazo LGPD (90 dias por defeito).';

    public function handle(): int
    {
        $days = max(1, (int) $this->option('days'));
        $cutoff = now()->subDays($days);

        $n = AccessLog::query()->where('created_at', '<', $cutoff)->delete();

        $this->info("Removidos {$n} registos de access_logs anteriores a {$cutoff->toDateTimeString()}.");

        return self::SUCCESS;
    }
}
