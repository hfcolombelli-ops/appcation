<?php

namespace Tests\Feature;

use App\Mail\InstitutionDashboardDigestMail;
use App\Mail\ManufacturerDashboardDigestMail;
use App\Models\Institution;
use App\Models\Manufacturer;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoWeeklyDashboardDigestTest extends TestCase
{
    use RefreshDatabase;

    public function test_weekly_digest_sends_mails_to_gestor_and_fabricante(): void
    {
        Mail::fake();
        Config::set('reports.dashboard_digest_enabled', true);
        Config::set('reports.frontend_url', 'https://app.example.test');

        $inst = Institution::query()->create([
            'name' => 'Inst Digest',
            'cnpj' => '11.222.333/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $fab = Manufacturer::query()->create([
            'name' => 'Fab Digest',
            'slug' => 'fab-digest-'.Str::lower(Str::random(4)),
            'status' => 'active',
        ]);

        User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
            'email' => 'gestor@example.test',
        ]);

        User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $fab->id,
            'email' => 'fab@example.test',
        ]);

        $this->artisan('reports:send-weekly-dashboard-digests')->assertSuccessful();

        Mail::assertSent(InstitutionDashboardDigestMail::class, 1);
        Mail::assertSent(ManufacturerDashboardDigestMail::class, 1);
    }

    public function test_weekly_digest_skips_when_disabled(): void
    {
        Mail::fake();
        Config::set('reports.dashboard_digest_enabled', false);

        User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => Institution::query()->create([
                'name' => 'I',
                'cnpj' => '44.555.666/0001-'.Str::upper(Str::random(2)),
                'status' => 'active',
            ])->id,
        ]);

        $this->artisan('reports:send-weekly-dashboard-digests')->assertSuccessful();

        Mail::assertNothingSent();
    }

    public function test_weekly_digest_skips_user_with_opt_out(): void
    {
        Mail::fake();
        Config::set('reports.dashboard_digest_enabled', true);

        $inst = Institution::query()->create([
            'name' => 'Inst Opt',
            'cnpj' => '55.666.777/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
            'weekly_dashboard_digest' => false,
        ]);

        $this->artisan('reports:send-weekly-dashboard-digests')->assertSuccessful();

        Mail::assertNotSent(InstitutionDashboardDigestMail::class);
    }
}
