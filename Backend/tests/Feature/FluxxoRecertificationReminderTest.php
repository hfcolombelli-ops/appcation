<?php

namespace Tests\Feature;

use App\Mail\RecertificationReminder;
use App\Models\Certificate;
use App\Models\Enrollment;
use App\Models\Institution;
use App\Models\RecertificationReminderSend;
use App\Models\Training;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoRecertificationReminderTest extends TestCase
{
    use RefreshDatabase;

    public function test_command_sends_reminder_and_logs_once(): void
    {
        Mail::fake();
        Config::set('app.recertification_reminders_enabled', true);
        Config::set('app.recertification_reminder_days', [30]);

        $inst = Institution::query()->create([
            'name' => 'Inst Recert',
            'cnpj' => '66.777.888/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create([
            'role' => 'trainee',
            'email' => 'trainee-recert@example.com',
        ]);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino recert',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 90.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $expires = now()->addDays(30)->startOfDay()->addHours(12);

        $cert = Certificate::query()->create([
            'user_id' => $trainee->id,
            'enrollment_id' => $enrollment->id,
            'training_id' => $training->id,
            'score' => 9.0,
            'certificate_code' => 'APP-RECERT-'.Str::upper(Str::random(6)),
            'issued_at' => now()->subYear(),
            'expires_at' => $expires,
        ]);

        $this->artisan('certificates:send-recertification-reminders')->assertSuccessful();

        Mail::assertSent(RecertificationReminder::class, function (RecertificationReminder $m) use ($cert): bool {
            return $m->certificate->is($cert) && $m->daysBeforeExpiry === 30;
        });

        $this->assertSame(1, RecertificationReminderSend::query()->count());
        $this->assertDatabaseHas('recertification_reminder_sends', [
            'certificate_id' => $cert->id,
            'days_before_expiry' => 30,
        ]);

        Mail::fake();
        $this->artisan('certificates:send-recertification-reminders')->assertSuccessful();
        Mail::assertNothingSent();
        $this->assertSame(1, RecertificationReminderSend::query()->count());
    }

    public function test_command_respects_disabled_config(): void
    {
        Mail::fake();
        Config::set('app.recertification_reminders_enabled', false);
        Config::set('app.recertification_reminder_days', [30]);

        $inst = Institution::query()->create([
            'name' => 'Inst Off',
            'cnpj' => '77.888.999/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee', 'email' => 'off@example.com']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'T',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 80.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        Certificate::query()->create([
            'user_id' => $trainee->id,
            'enrollment_id' => $enrollment->id,
            'training_id' => $training->id,
            'score' => 8.0,
            'certificate_code' => 'APP-OFF-'.Str::upper(Str::random(6)),
            'issued_at' => now()->subYear(),
            'expires_at' => now()->addDays(30),
        ]);

        $this->artisan('certificates:send-recertification-reminders')->assertSuccessful();
        Mail::assertNothingSent();
    }
}
