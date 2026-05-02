<?php

namespace Tests\Feature;

use App\Models\Enrollment;
use App\Models\Institution;
use App\Models\Training;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoInstructorDashboardMetricsTest extends TestCase
{
    use RefreshDatabase;

    public function test_instructor_dashboard_includes_finished_count_and_approval_rate(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Dash',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $t1 = User::factory()->create(['role' => 'trainee']);
        $t2 = User::factory()->create(['role' => 'trainee']);

        $trFinished = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Fechado',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'passing_score_percent' => 70,
        ]);

        Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Rascunho',
            'type' => 'official',
            'status' => 'draft',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'passing_score_percent' => 70,
        ]);

        Enrollment::query()->create([
            'training_id' => $trFinished->id,
            'user_id' => $t1->id,
            'status' => 'completed',
            'score' => 9.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        Enrollment::query()->create([
            'training_id' => $trFinished->id,
            'user_id' => $t2->id,
            'status' => 'completed',
            'score' => 5.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $token = $instructor->createToken('i')->plainTextToken;

        $res = $this->withToken($token)->getJson('/api/instructor/dashboard-summary');
        $res->assertOk();
        $res->assertJsonPath('training_count', 2);
        $res->assertJsonPath('finished_trainings_count', 1);
        $this->assertEquals(50.0, (float) $res->json('approval_rate_percent'));
        $this->assertEquals(7.0, (float) $res->json('average_score'));
    }
}
