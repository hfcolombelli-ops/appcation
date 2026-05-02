<?php

namespace Tests\Feature;

use App\Models\Institution;
use App\Models\Training;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoSessionPauseTest extends TestCase
{
    use RefreshDatabase;

    public function test_live_state_reflects_pause_and_resume(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Pause',
            'cnpj' => '11.222.333/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino pause',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
        ]);

        $token = $instructor->createToken('ins')->plainTextToken;

        $this->withToken($token)->getJson("/api/trainings/{$training->id}/live-state")
            ->assertOk()
            ->assertJsonPath('session_paused', false)
            ->assertJsonPath('post_repescage_score_policy', 'full_average');

        $this->withToken($token)->postJson("/api/realtime/trainings/{$training->id}/command", [
            'action' => 'pause',
        ])->assertOk();

        $this->withToken($token)->getJson("/api/trainings/{$training->id}/live-state")
            ->assertOk()
            ->assertJsonPath('session_paused', true)
            ->assertJsonPath('last_command', 'pause');

        $this->withToken($token)->postJson("/api/realtime/trainings/{$training->id}/command", [
            'action' => 'resume',
        ])->assertOk();

        $this->withToken($token)->getJson("/api/trainings/{$training->id}/live-state")
            ->assertOk()
            ->assertJsonPath('session_paused', false)
            ->assertJsonPath('last_command', 'resume');
    }

    public function test_enrollments_monitor_includes_session_paused(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Mon',
            'cnpj' => '22.333.444/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino mon',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
        ]);

        $token = $instructor->createToken('ins')->plainTextToken;

        $this->withToken($token)->postJson("/api/realtime/trainings/{$training->id}/command", [
            'action' => 'pause',
        ])->assertOk();

        $this->withToken($token)->getJson("/api/trainings/{$training->id}/enrollments")
            ->assertOk()
            ->assertJsonPath('training.session_paused', true);
    }
}
