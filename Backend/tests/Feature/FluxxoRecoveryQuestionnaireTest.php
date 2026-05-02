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

class FluxxoRecoveryQuestionnaireTest extends TestCase
{
    use RefreshDatabase;

    public function test_trainee_questionnaire_lists_only_pending_recovery_questions(): void
    {
        Event::fake();

        $inst = Institution::query()->create([
            'name' => 'Inst RecQ',
            'cnpj' => '55.444.333/0001-'.Str::upper(Str::random(2)),
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
            'title' => 'Treino recQ',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
        ]);

        $block = TrainingBlock::query()->create([
            'training_id' => $training->id,
            'title' => 'B1',
            'sort_order' => 1,
            'is_released' => true,
        ]);

        $q1 = Question::query()->create([
            'training_block_id' => $block->id,
            'type' => 'multiple_choice',
            'prompt' => 'P1',
            'sort_order' => 1,
            'is_required' => true,
        ]);
        $q2 = Question::query()->create([
            'training_block_id' => $block->id,
            'type' => 'multiple_choice',
            'prompt' => 'P2',
            'sort_order' => 2,
            'is_required' => true,
        ]);

        $w1 = QuestionOption::query()->create(['question_id' => $q1->id, 'label' => 'Errada', 'is_correct' => false, 'sort_order' => 1]);
        $r2 = QuestionOption::query()->create(['question_id' => $q2->id, 'label' => 'Certa', 'is_correct' => true, 'sort_order' => 1]);

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
            'question_option_id' => $r2->id,
            'is_correct' => true,
        ]);

        $itoken = $instructor->createToken('ins')->plainTextToken;
        $this->withToken($itoken)->postJson("/api/realtime/trainings/{$training->id}/command", [
            'action' => 'repescage',
            'payload' => ['enrollment_ids' => [$enrollment->id]],
        ])->assertOk();

        $enrollment->refresh();
        $this->assertTrue($enrollment->in_recovery);
        $this->assertSame([$q1->id], $enrollment->recovery_question_ids);

        Sanctum::actingAs($trainee);
        $list = $this->getJson("/api/trainings/{$training->id}/questionnaire");
        $list->assertOk();
        $list->assertJsonCount(1);
        $this->assertSame($q1->id, $list->json('0.id'));
    }
}
