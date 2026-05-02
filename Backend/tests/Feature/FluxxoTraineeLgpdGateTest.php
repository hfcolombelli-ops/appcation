<?php

namespace Tests\Feature;

use App\Models\Enrollment;
use App\Models\Institution;
use App\Models\Training;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FluxxoTraineeLgpdGateTest extends TestCase
{
    use RefreshDatabase;

    public function test_trainee_can_save_profile_without_lgpd_consent(): void
    {
        $trainee = User::factory()->create(['role' => 'trainee']);
        Sanctum::actingAs($trainee);

        $this->putJson('/api/me/trainee-profile', [
            'sector' => 'UTI',
        ])
            ->assertOk()
            ->assertJsonPath('profile.sector', 'UTI');
    }

    public function test_trainee_can_join_training_without_lgpd_consent(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst LGPD',
            'cnpj' => '11.222.333/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $hash = Str::lower(Str::random(12));

        Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino join',
            'type' => 'official',
            'status' => 'scheduled',
            'join_hash' => $hash,
            'is_official_template' => false,
            'command_seq' => 0,
        ]);

        $trainee = User::factory()->create(['role' => 'trainee']);
        Sanctum::actingAs($trainee);

        $this->postJson('/api/enrollments/join', ['join_hash' => $hash])
            ->assertOk()
            ->assertJsonPath('enrollment.status', 'waiting');
    }

    public function test_trainee_state_does_not_require_lgpd_while_training_not_in_progress(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst State',
            'cnpj' => '22.333.444/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $hash = Str::lower(Str::random(12));

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino wait',
            'type' => 'official',
            'status' => 'scheduled',
            'join_hash' => $hash,
            'is_official_template' => false,
            'command_seq' => 0,
        ]);

        $trainee = User::factory()->create(['role' => 'trainee']);
        Sanctum::actingAs($trainee);

        $this->postJson('/api/enrollments/join', ['join_hash' => $hash])->assertOk();

        $this->getJson('/api/me/trainee-state')
            ->assertOk()
            ->assertJsonPath('needs_lgpd_consent', false);
    }

    public function test_trainee_state_requires_lgpd_when_session_is_in_progress_without_consent(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Live',
            'cnpj' => '33.444.555/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $hash = Str::lower(Str::random(12));

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino live',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => $hash,
            'is_official_template' => false,
            'command_seq' => 0,
        ]);

        $trainee = User::factory()->create(['role' => 'trainee']);
        Sanctum::actingAs($trainee);

        Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'waiting',
            'joined_at' => now(),
        ]);

        $this->getJson('/api/me/trainee-state')
            ->assertOk()
            ->assertJsonPath('needs_lgpd_consent', true);
    }

    public function test_questionnaire_requires_lgpd_consent(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Q',
            'cnpj' => '44.555.666/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino Q',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
        ]);

        $trainee = User::factory()->create(['role' => 'trainee']);
        Sanctum::actingAs($trainee);

        $this->getJson("/api/trainings/{$training->id}/questionnaire")
            ->assertStatus(428)
            ->assertJsonPath('code', 'lgpd_consent_required');
    }
}
