<?php

namespace App\Console\Commands;

use App\Mail\InstitutionDashboardDigestMail;
use App\Mail\ManufacturerDashboardDigestMail;
use App\Models\Institution;
use App\Models\Manufacturer;
use App\Models\User;
use App\Services\Dashboard\InstitutionDashboardAggregateService;
use App\Services\Dashboard\ManufacturerDashboardAggregateService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Mail;

class SendWeeklyDashboardDigests extends Command
{
    protected $signature = 'reports:send-weekly-dashboard-digests';

    protected $description = 'Envia por e-mail o resumo agregado semanal a gestores de instituição e admins de fabricante.';

    public function handle(
        InstitutionDashboardAggregateService $institutionAgg,
        ManufacturerDashboardAggregateService $manufacturerAgg,
    ): int {
        if (! config('reports.dashboard_digest_enabled')) {
            $this->info('Digestos desativados (DASHBOARD_DIGEST_ENABLED).');

            return self::SUCCESS;
        }

        $frontend = config('reports.frontend_url');
        $institutionCount = 0;
        $manufacturerCount = 0;

        User::query()
            ->where('role', 'institution_admin')
            ->whereNotNull('institution_id')
            ->where('weekly_dashboard_digest', true)
            ->orderBy('id')
            ->chunkById(50, function ($users) use ($institutionAgg, $frontend, &$institutionCount) {
                foreach ($users as $user) {
                    $institution = Institution::query()->find($user->institution_id);
                    if ($institution === null) {
                        continue;
                    }
                    $data = $institutionAgg->aggregate((int) $user->institution_id);
                    Mail::to($user->email)->send(new InstitutionDashboardDigestMail(
                        recipientName: (string) ($user->name ?? ''),
                        institutionName: (string) $institution->name,
                        data: $data,
                        frontendUrl: $frontend,
                    ));
                    $institutionCount++;
                }
            });

        User::query()
            ->where('role', 'manufacturer_admin')
            ->whereNotNull('manufacturer_id')
            ->where('weekly_dashboard_digest', true)
            ->orderBy('id')
            ->chunkById(50, function ($users) use ($manufacturerAgg, $frontend, &$manufacturerCount) {
                foreach ($users as $user) {
                    $manufacturer = Manufacturer::query()->find($user->manufacturer_id);
                    if ($manufacturer === null) {
                        continue;
                    }
                    $data = $manufacturerAgg->aggregate((int) $user->manufacturer_id);
                    Mail::to($user->email)->send(new ManufacturerDashboardDigestMail(
                        recipientName: (string) ($user->name ?? ''),
                        manufacturerName: (string) $manufacturer->name,
                        data: $data,
                        frontendUrl: $frontend,
                    ));
                    $manufacturerCount++;
                }
            });

        $this->info("Enviados: {$institutionCount} e-mails (instituição), {$manufacturerCount} (fabricante).");

        return self::SUCCESS;
    }
}
