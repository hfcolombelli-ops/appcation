<?php

namespace Tests\Feature;

use App\Models\Institution;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoNotificationPreferencesTest extends TestCase
{
    use RefreshDatabase;

    public function test_gestor_can_toggle_weekly_dashboard_digest(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst NP',
            'cnpj' => '22.333.444/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $u = User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ]);

        $token = $u->createToken('t')->plainTextToken;

        $this->withToken($token)
            ->patchJson('/api/me/notification-preferences', [
                'weekly_dashboard_digest' => false,
            ])
            ->assertOk()
            ->assertJsonPath('weekly_dashboard_digest', false);

        $this->assertFalse((bool) $u->fresh()->weekly_dashboard_digest);
    }

    public function test_trainee_cannot_patch_notification_preferences_without_validation_passing(): void
    {
        $u = User::factory()->create(['role' => 'trainee']);
        $token = $u->createToken('t')->plainTextToken;

        $this->withToken($token)
            ->patchJson('/api/me/notification-preferences', [
                'weekly_dashboard_digest' => false,
            ])
            ->assertOk();

        $this->assertFalse((bool) $u->fresh()->weekly_dashboard_digest);
    }
}
