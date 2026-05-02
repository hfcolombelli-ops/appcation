<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Schedule::command('privacy:purge-access-logs')->dailyAt('03:15');

Schedule::command('certificates:send-recertification-reminders')->dailyAt('08:40');

Schedule::command('leaderboard:recompute-seasons')->dailyAt('04:05');

Schedule::command('reports:send-weekly-dashboard-digests')->weekly()->mondays()->at('07:00');
