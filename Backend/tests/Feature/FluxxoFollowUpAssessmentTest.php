<?php

namespace Tests\Feature;

use App\Models\Enrollment;
use App\Models\EnrollmentFollowUp;
use App\Models\Institution;
use App\Models\Training;
use App\Models\User;
use App\Models\UserConsent;
use App\Support\FollowUpScheduler;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoFollowUpAssessmentTest extends TestCase
{
    use RefreshDatabase;

    public function test_scheduler_creates_windows_from_config(): void
    {
        Config::set('follow_up.default_days', [10, 30]);

        $inst = Institution::query()->create([
            'name' => 'Inst FU',
            'cnpj' => '88.999.000/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino FU',
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
            'joined_at' => now()->subWeek(),
            'completed_at' => now()->subWeek(),
        ]);

        FollowUpScheduler::schedule($enrollment->fresh());

        $this->assertSame(2, EnrollmentFollowUp::query()->count());
        $this->assertSame([10, 30], EnrollmentFollowUp::query()->orderBy('days_offset')->pluck('days_offset')->all());
    }

    public function test_trainee_lists_and_submits_follow_up(): void
    {
        Config::set('follow_up.default_days', [10]);

        $inst = Institution::query()->create([
            'name' => 'Inst FU2',
            'cnpj' => '99.000.111/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        UserConsent::query()->create([
            'user_id' => $trainee->id,
            'consent_type' => 'lgpd_trainee',
            'policy_version' => config('lgpd.privacy_policy_version'),
            'given_at' => now(),
        ]);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino FU2',
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
            'joined_at' => now()->subWeek(),
            'completed_at' => now()->subWeek(),
        ]);

        FollowUpScheduler::schedule($enrollment->fresh());

        $row = EnrollmentFollowUp::query()->firstOrFail();
        $row->update(['due_at' => now()->subDay()]);

        $token = $trainee->createToken('t')->plainTextToken;

        $this->withToken($token)->getJson('/api/me/follow-up-assessments')
            ->assertOk()
            ->assertJsonCount(1);

        $this->withToken($token)->getJson('/api/me/follow-up-assessments/'.$row->id)
            ->assertOk()
            ->assertJsonPath('can_submit', true)
            ->assertJsonStructure(['questions']);

        $this->withToken($token)->postJson('/api/me/follow-up-assessments/'.$row->id.'/submit', [
            'responses' => [
                'confidence' => 4,
                'applied' => 'yes',
                'comment' => '',
            ],
        ])->assertOk();

        $row->refresh();
        $this->assertSame('completed', $row->status);
        $this->assertNotNull($row->completed_at);
        $this->assertSame(4, $row->responses['confidence']);
    }
}
