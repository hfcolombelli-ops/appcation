<?php

namespace Tests\Feature;

use App\Models\Answer;
use App\Models\Enrollment;
use App\Models\Institution;
use App\Models\Question;
use App\Models\QuestionOption;
use App\Models\Training;
use App\Models\TrainingBlock;
use App\Models\User;
use App\Models\UserConsent;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FluxxoPostRepescageScorePolicyTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Bloco A repescado só: Q1 certa, Q2 ainda errada → recovery_only = 10,0 (só Q1 na média).
     */
    public function test_recovery_only_score_uses_only_repescued_questions(): void
    {
        Event::fake();

        $inst = Institution::query()->create([
            'name' => 'Inst Score',
            'cnpj' => '77.888.999/0001-'.Str::upper(Str::random(2)),
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
            'title' => 'Treino política nota',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
            'passing_score_percent' => 70,
            'metadata' => [
                'post_repescage_score_policy' => 'recovery_only',
            ],
        ]);

        $blockA = TrainingBlock::query()->create([
            'training_id' => $training->id,
            'title' => 'A',
            'sort_order' => 1,
            'is_released' => true,
        ]);
        $blockB = TrainingBlock::query()->create([
            'training_id' => $training->id,
            'title' => 'B',
            'sort_order' => 2,
            'is_released' => true,
        ]);

        $q1 = Question::query()->create([
            'training_block_id' => $blockA->id,
            'type' => 'multiple_choice',
            'prompt' => 'P1',
            'sort_order' => 1,
            'is_required' => true,
        ]);
        $q2 = Question::query()->create([
            'training_block_id' => $blockB->id,
            'type' => 'multiple_choice',
            'prompt' => 'P2',
            'sort_order' => 1,
            'is_required' => true,
        ]);

        $w1 = QuestionOption::query()->create(['question_id' => $q1->id, 'label' => 'E1', 'is_correct' => false, 'sort_order' => 1]);
        $r1 = QuestionOption::query()->create(['question_id' => $q1->id, 'label' => 'C1', 'is_correct' => true, 'sort_order' => 2]);
        $w2 = QuestionOption::query()->create(['question_id' => $q2->id, 'label' => 'E2', 'is_correct' => false, 'sort_order' => 1]);
        QuestionOption::query()->create(['question_id' => $q2->id, 'label' => 'C2', 'is_correct' => true, 'sort_order' => 2]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'active',
            'joined_at' => now(),
        ]);

        Answer::query()->create([
            'enrollment_id' => $enrollment->id,
            'question_id' => $q1->id,
            'question_option_id' => $w1->id,
            'is_correct' => false,
        ]);
        Answer::query()->create([
            'enrollment_id' => $enrollment->id,
            'question_id' => $q2->id,
            'question_option_id' => $w2->id,
            'is_correct' => false,
        ]);

        Sanctum::actingAs($instructor);
        $this->postJson("/api/realtime/trainings/{$training->id}/command", [
            'action' => 'repescage',
            'payload' => [
                'enrollment_ids' => [$enrollment->id],
                'training_block_id' => $blockA->id,
            ],
        ])->assertOk();

        $enrollment->refresh();
        $this->assertTrue($enrollment->in_recovery);
        $this->assertSame([$q1->id], $enrollment->recovery_question_ids);

        Sanctum::actingAs($trainee);
        $this->postJson('/api/questionnaire/answers', [
            'enrollment_id' => $enrollment->id,
            'question_id' => $q1->id,
            'question_option_id' => $r1->id,
        ])->assertCreated();

        $enrollment->refresh();
        $this->assertSame('completed', $enrollment->status);
        $this->assertEqualsWithDelta(10.0, (float) $enrollment->score, 0.01);
    }

    /**
     * Mesmo cenário com full_average → nota 5,0 (Q1 certa, Q2 ainda errada).
     */
    public function test_full_average_score_includes_all_answered_questions(): void
    {
        Event::fake();

        $inst = Institution::query()->create([
            'name' => 'Inst Score2',
            'cnpj' => '77.888.998/0001-'.Str::upper(Str::random(2)),
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
            'title' => 'Treino política nota 2',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
            'passing_score_percent' => 70,
            'metadata' => [
                'post_repescage_score_policy' => 'full_average',
            ],
        ]);

        $this->assertSame(
            'full_average',
            Training::query()->findOrFail($training->id)->metadata['post_repescage_score_policy'] ?? null,
            'metadata must persist for full_average policy'
        );

        $bA = TrainingBlock::query()->create([
            'training_id' => $training->id,
            'title' => 'A',
            'sort_order' => 1,
            'is_released' => true,
        ]);
        $bB = TrainingBlock::query()->create([
            'training_id' => $training->id,
            'title' => 'B',
            'sort_order' => 2,
            'is_released' => true,
        ]);

        $q1 = Question::query()->create([
            'training_block_id' => $bA->id,
            'type' => 'multiple_choice',
            'prompt' => 'P1',
            'sort_order' => 1,
            'is_required' => true,
        ]);
        $q2 = Question::query()->create([
            'training_block_id' => $bB->id,
            'type' => 'multiple_choice',
            'prompt' => 'P2',
            'sort_order' => 1,
            'is_required' => true,
        ]);

        $w1 = QuestionOption::query()->create(['question_id' => $q1->id, 'label' => 'E', 'is_correct' => false, 'sort_order' => 1]);
        $r1 = QuestionOption::query()->create(['question_id' => $q1->id, 'label' => 'C', 'is_correct' => true, 'sort_order' => 2]);
        $w2 = QuestionOption::query()->create(['question_id' => $q2->id, 'label' => 'E', 'is_correct' => false, 'sort_order' => 1]);
        QuestionOption::query()->create(['question_id' => $q2->id, 'label' => 'C', 'is_correct' => true, 'sort_order' => 2]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'active',
            'joined_at' => now(),
        ]);

        Answer::query()->create([
            'enrollment_id' => $enrollment->id,
            'question_id' => $q1->id,
            'question_option_id' => $w1->id,
            'is_correct' => false,
        ]);
        Answer::query()->create([
            'enrollment_id' => $enrollment->id,
            'question_id' => $q2->id,
            'question_option_id' => $w2->id,
            'is_correct' => false,
        ]);

        Sanctum::actingAs($instructor);
        $this->postJson("/api/realtime/trainings/{$training->id}/command", [
            'action' => 'repescage',
            'payload' => [
                'enrollment_ids' => [$enrollment->id],
                'training_block_id' => $bA->id,
            ],
        ])->assertOk();

        $a2After = Answer::query()->where('enrollment_id', $enrollment->id)->where('question_id', $q2->id)->first();
        $this->assertNotNull($a2After);
        $this->assertFalse((bool) $a2After->is_correct);

        Sanctum::actingAs($trainee);
        $this->postJson('/api/questionnaire/answers', [
            'enrollment_id' => $enrollment->id,
            'question_id' => $q1->id,
            'question_option_id' => $r1->id,
        ])->assertCreated();

        $q2AfterPost = Answer::query()->where('enrollment_id', $enrollment->id)->where('question_id', $q2->id)->first();
        $this->assertNotNull($q2AfterPost);
        $this->assertFalse((bool) $q2AfterPost->is_correct, 'Q2 deve permanecer errada após corrigir só Q1');

        $enrollment->refresh();
        $this->assertSame('completed', $enrollment->status);
        $this->assertEqualsWithDelta(5.0, (float) $enrollment->score, 0.01);
    }
}
