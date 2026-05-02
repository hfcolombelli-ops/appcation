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
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoRepescageVariantBankTest extends TestCase
{
    use RefreshDatabase;

    public function test_variant_bank_maps_recovery_to_sibling_question(): void
    {
        Event::fake();

        $inst = Institution::query()->create([
            'name' => 'Inst Var',
            'cnpj' => '10.203.050/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino variantes',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
            'metadata' => [
                'repescage_variant_bank' => true,
            ],
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
            'prompt' => 'Original',
            'sort_order' => 1,
            'is_required' => true,
            'recovery_variant_group' => 'grp_a',
        ]);
        $q2 = Question::query()->create([
            'training_block_id' => $block->id,
            'type' => 'multiple_choice',
            'prompt' => 'Variante',
            'sort_order' => 2,
            'is_required' => true,
            'recovery_variant_group' => 'grp_a',
        ]);

        $w1 = QuestionOption::query()->create([
            'question_id' => $q1->id,
            'label' => 'E',
            'is_correct' => false,
            'sort_order' => 1,
        ]);
        QuestionOption::query()->create([
            'question_id' => $q2->id,
            'label' => 'E',
            'is_correct' => false,
            'sort_order' => 1,
        ]);

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

        $itoken = $instructor->createToken('ins')->plainTextToken;

        $this->withToken($itoken)->postJson("/api/realtime/trainings/{$training->id}/command", [
            'action' => 'repescage',
            'payload' => [
                'enrollment_ids' => [$enrollment->id],
            ],
        ])->assertOk();

        $enrollment->refresh();
        $this->assertTrue($enrollment->in_recovery);
        $this->assertSame([(int) $q2->id], $enrollment->recovery_question_ids);
    }

    public function test_without_variant_bank_keeps_original_question_ids(): void
    {
        Event::fake();

        $inst = Institution::query()->create([
            'name' => 'Inst NoVar',
            'cnpj' => '10.203.051/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino sem variantes',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
            'metadata' => [],
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
            'prompt' => 'Original',
            'sort_order' => 1,
            'is_required' => true,
            'recovery_variant_group' => 'grp_a',
        ]);
        Question::query()->create([
            'training_block_id' => $block->id,
            'type' => 'multiple_choice',
            'prompt' => 'Variante',
            'sort_order' => 2,
            'is_required' => true,
            'recovery_variant_group' => 'grp_a',
        ]);

        $w1 = QuestionOption::query()->create([
            'question_id' => $q1->id,
            'label' => 'E',
            'is_correct' => false,
            'sort_order' => 1,
        ]);

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

        $itoken = $instructor->createToken('ins')->plainTextToken;

        $this->withToken($itoken)->postJson("/api/realtime/trainings/{$training->id}/command", [
            'action' => 'repescage',
            'payload' => [
                'enrollment_ids' => [$enrollment->id],
            ],
        ])->assertOk();

        $enrollment->refresh();
        $this->assertSame([(int) $q1->id], $enrollment->recovery_question_ids);
    }
}
