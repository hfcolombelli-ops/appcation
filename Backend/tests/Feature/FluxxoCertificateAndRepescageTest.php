<?php

namespace Tests\Feature;

use App\Models\Answer;
use App\Models\Certificate;
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

class FluxxoCertificateAndRepescageTest extends TestCase
{
    use RefreshDatabase;

    public function test_trainee_lists_own_certificates(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Cert',
            'cnpj' => '98.765.432/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino teste',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 85.5,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        Certificate::query()->create([
            'user_id' => $trainee->id,
            'enrollment_id' => $enrollment->id,
            'training_id' => $training->id,
            'score' => 85.5,
            'certificate_code' => 'APP²-TEST'.Str::upper(Str::random(8)),
            'issued_at' => now(),
            'expires_at' => now()->addYear(),
        ]);

        $ttoken = $trainee->createToken('tr')->plainTextToken;

        $res = $this->withToken($ttoken)->getJson('/api/me/certificates');
        $res->assertOk();
        $res->assertJsonCount(1);
        $this->assertSame($training->title, $res->json('0.training.title'));
    }

    public function test_instructor_repescage_reopens_enrollment(): void
    {
        Event::fake();

        $inst = Institution::query()->create([
            'name' => 'Inst Rep',
            'cnpj' => '11.222.333/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino repescagem',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
        ]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 50.0,
            'joined_at' => now(),
            'completed_at' => now(),
            'repescage_round' => 0,
            'in_recovery' => false,
        ]);

        $itoken = $instructor->createToken('ins')->plainTextToken;

        $cmd = $this->withToken($itoken)->postJson("/api/realtime/trainings/{$training->id}/command", [
            'action' => 'repescage',
            'payload' => [
                'enrollment_ids' => [$enrollment->id],
            ],
        ]);

        $cmd->assertOk();
        $cmd->assertJsonPath('action', 'repescage');

        $enrollment->refresh();
        $this->assertTrue($enrollment->in_recovery);
        $this->assertSame(1, (int) $enrollment->repescage_round);
        $this->assertSame('active', $enrollment->status);
        $this->assertNull($enrollment->completed_at);
        $this->assertNull($enrollment->score);
    }

    public function test_instructor_repescage_by_block_only_clears_wrong_in_that_block(): void
    {
        Event::fake();

        $inst = Institution::query()->create([
            'name' => 'Inst Bloco',
            'cnpj' => '10.203.040/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino blocos',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
        ]);

        $b1 = TrainingBlock::query()->create([
            'training_id' => $training->id,
            'title' => 'Bloco A',
            'sort_order' => 1,
            'is_released' => true,
        ]);
        $b2 = TrainingBlock::query()->create([
            'training_id' => $training->id,
            'title' => 'Bloco B',
            'sort_order' => 2,
            'is_released' => true,
        ]);

        $q1 = Question::query()->create([
            'training_block_id' => $b1->id,
            'type' => 'multiple_choice',
            'prompt' => 'P1',
            'sort_order' => 1,
            'is_required' => true,
        ]);
        $q2 = Question::query()->create([
            'training_block_id' => $b2->id,
            'type' => 'multiple_choice',
            'prompt' => 'P2',
            'sort_order' => 1,
            'is_required' => true,
        ]);

        $optWrong = QuestionOption::query()->create([
            'question_id' => $q1->id,
            'label' => 'Errada',
            'is_correct' => false,
            'sort_order' => 1,
        ]);
        $optRight = QuestionOption::query()->create([
            'question_id' => $q2->id,
            'label' => 'Certa',
            'is_correct' => true,
            'sort_order' => 1,
        ]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'active',
            'joined_at' => now(),
            'repescage_round' => 0,
            'in_recovery' => false,
        ]);

        Answer::query()->create([
            'enrollment_id' => $enrollment->id,
            'question_id' => $q1->id,
            'question_option_id' => $optWrong->id,
            'is_correct' => false,
        ]);
        Answer::query()->create([
            'enrollment_id' => $enrollment->id,
            'question_id' => $q2->id,
            'question_option_id' => $optRight->id,
            'is_correct' => true,
        ]);

        $itoken = $instructor->createToken('ins')->plainTextToken;

        $this->withToken($itoken)->postJson("/api/realtime/trainings/{$training->id}/command", [
            'action' => 'repescage',
            'payload' => [
                'enrollment_ids' => [$enrollment->id],
                'training_block_id' => $b1->id,
            ],
        ])->assertOk();

        $this->assertSame(1, Answer::query()->where('enrollment_id', $enrollment->id)->count());
        $this->assertTrue(Answer::query()->where('enrollment_id', $enrollment->id)->where('question_id', $q2->id)->exists());

        $enrollment->refresh();
        $this->assertTrue($enrollment->in_recovery);
        $this->assertSame(1, (int) $enrollment->repescage_round);
    }

    public function test_repescage_by_block_fails_when_no_wrong_answers_in_block(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Empty',
            'cnpj' => '10.203.041/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino vazio',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
        ]);

        $b1 = TrainingBlock::query()->create([
            'training_id' => $training->id,
            'title' => 'Bloco',
            'sort_order' => 1,
            'is_released' => true,
        ]);

        $q1 = Question::query()->create([
            'training_block_id' => $b1->id,
            'type' => 'multiple_choice',
            'prompt' => 'P1',
            'sort_order' => 1,
            'is_required' => true,
        ]);

        $optRight = QuestionOption::query()->create([
            'question_id' => $q1->id,
            'label' => 'Certa',
            'is_correct' => true,
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
            'question_option_id' => $optRight->id,
            'is_correct' => true,
        ]);

        $itoken = $instructor->createToken('ins')->plainTextToken;

        $this->withToken($itoken)->postJson("/api/realtime/trainings/{$training->id}/command", [
            'action' => 'repescage',
            'payload' => [
                'enrollment_ids' => [$enrollment->id],
                'training_block_id' => $b1->id,
            ],
        ])->assertUnprocessable();
    }

    public function test_repescage_by_block_rejected_when_accuracy_not_below_half(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Half',
            'cnpj' => '10.203.042/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino 50',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
        ]);

        $b1 = TrainingBlock::query()->create([
            'training_id' => $training->id,
            'title' => 'Bloco',
            'sort_order' => 1,
            'is_released' => true,
        ]);

        $q1 = Question::query()->create([
            'training_block_id' => $b1->id,
            'type' => 'multiple_choice',
            'prompt' => 'P1',
            'sort_order' => 1,
            'is_required' => true,
        ]);
        $q2 = Question::query()->create([
            'training_block_id' => $b1->id,
            'type' => 'multiple_choice',
            'prompt' => 'P2',
            'sort_order' => 2,
            'is_required' => true,
        ]);

        $r1 = QuestionOption::query()->create([
            'question_id' => $q1->id,
            'label' => 'Certa',
            'is_correct' => true,
            'sort_order' => 1,
        ]);
        $r2 = QuestionOption::query()->create([
            'question_id' => $q2->id,
            'label' => 'Certa',
            'is_correct' => true,
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
            'question_option_id' => $r1->id,
            'is_correct' => true,
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
            'payload' => [
                'enrollment_ids' => [$enrollment->id],
                'training_block_id' => $b1->id,
            ],
        ])->assertUnprocessable();
    }

    public function test_finish_training_issues_certificates_for_completed_passing_enrollments(): void
    {
        Event::fake();

        $inst = Institution::query()->create([
            'name' => 'Inst Finish GA10',
            'cnpj' => '77.888.999/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino encerrar cert',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 1,
            'passing_score_percent' => 70,
        ]);

        Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 8.5,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $this->assertSame(0, Certificate::query()->where('training_id', $training->id)->count());

        $itoken = $instructor->createToken('ins')->plainTextToken;

        $this->withToken($itoken)->patchJson("/api/trainings/{$training->id}", [
            'status' => 'finished',
        ])->assertOk();

        $training->refresh();
        $this->assertSame('finished', $training->status);
        $this->assertSame(1, Certificate::query()->where('training_id', $training->id)->count());
    }

    public function test_finish_training_does_not_issue_certificate_below_passing_score(): void
    {
        Event::fake();

        $inst = Institution::query()->create([
            'name' => 'Inst Fail GA10',
            'cnpj' => '88.999.000/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino baixa nota',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
            'passing_score_percent' => 70,
        ]);

        Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 5.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $itoken = $instructor->createToken('ins')->plainTextToken;

        $this->withToken($itoken)->patchJson("/api/trainings/{$training->id}", [
            'status' => 'finished',
        ])->assertOk();

        $this->assertSame(0, Certificate::query()->where('training_id', $training->id)->count());
    }

    public function test_close_realtime_command_issues_certificates(): void
    {
        Event::fake();

        $inst = Institution::query()->create([
            'name' => 'Inst Close RT',
            'cnpj' => '99.000.111/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino close cmd',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 2,
            'passing_score_percent' => 70,
        ]);

        Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 9.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $itoken = $instructor->createToken('ins')->plainTextToken;

        $this->withToken($itoken)->postJson("/api/realtime/trainings/{$training->id}/command", [
            'action' => 'close',
            'payload' => [],
        ])->assertOk();

        $this->assertSame(1, Certificate::query()->where('training_id', $training->id)->count());
    }

    public function test_instructor_can_manually_issue_certificate_when_passing_and_missing(): void
    {
        Event::fake();

        $inst = Institution::query()->create([
            'name' => 'Inst Manual Cert',
            'cnpj' => '11.222.333/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino manual cert',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
            'passing_score_percent' => 70,
        ]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 8.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $this->assertSame(0, Certificate::query()->where('enrollment_id', $enrollment->id)->count());

        $itoken = $instructor->createToken('ins')->plainTextToken;

        $res = $this->withToken($itoken)->postJson(
            "/api/trainings/{$training->id}/enrollments/{$enrollment->id}/certificate",
            []
        );

        $res->assertCreated();
        $res->assertJsonPath('already_issued', false);
        $this->assertSame(1, Certificate::query()->where('enrollment_id', $enrollment->id)->count());
    }

    public function test_manual_issue_certificate_idempotent_when_already_exists(): void
    {
        Event::fake();

        $inst = Institution::query()->create([
            'name' => 'Inst Manual Idem',
            'cnpj' => '22.333.444/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino idem',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
            'passing_score_percent' => 70,
        ]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 9.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $itoken = $instructor->createToken('ins')->plainTextToken;

        $this->withToken($itoken)->postJson(
            "/api/trainings/{$training->id}/enrollments/{$enrollment->id}/certificate",
            []
        )->assertCreated();

        $cert = Certificate::query()->where('enrollment_id', $enrollment->id)->firstOrFail();
        $issuedAt = $cert->issued_at?->toIso8601String();

        $res2 = $this->withToken($itoken)->postJson(
            "/api/trainings/{$training->id}/enrollments/{$enrollment->id}/certificate",
            []
        );
        $res2->assertOk();
        $res2->assertJsonPath('already_issued', true);

        $cert->refresh();
        $this->assertSame($issuedAt, $cert->issued_at?->toIso8601String());
        $this->assertSame(1, Certificate::query()->where('enrollment_id', $enrollment->id)->count());
    }

    public function test_manual_issue_certificate_rejects_below_passing(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Manual Fail',
            'cnpj' => '33.444.555/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino baixa',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
            'passing_score_percent' => 70,
        ]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 6.5,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $itoken = $instructor->createToken('ins')->plainTextToken;

        $this->withToken($itoken)->postJson(
            "/api/trainings/{$training->id}/enrollments/{$enrollment->id}/certificate",
            []
        )->assertUnprocessable();

        $this->assertSame(0, Certificate::query()->where('enrollment_id', $enrollment->id)->count());
    }

    public function test_manual_issue_certificate_wrong_instructor_forbidden(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Manual 403',
            'cnpj' => '44.555.666/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $other = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino outro',
            'type' => 'official',
            'status' => 'in_progress',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
            'passing_score_percent' => 70,
        ]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 8.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $otoken = $other->createToken('o')->plainTextToken;

        $this->withToken($otoken)->postJson(
            "/api/trainings/{$training->id}/enrollments/{$enrollment->id}/certificate",
            []
        )->assertForbidden();
    }

    public function test_manual_issue_certificate_rejects_when_training_not_started(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Manual Draft',
            'cnpj' => '55.666.777/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino rascunho',
            'type' => 'official',
            'status' => 'draft',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
            'passing_score_percent' => 70,
        ]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 8.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $itoken = $instructor->createToken('ins')->plainTextToken;

        $this->withToken($itoken)->postJson(
            "/api/trainings/{$training->id}/enrollments/{$enrollment->id}/certificate",
            []
        )->assertUnprocessable();
    }

    public function test_instructor_can_export_training_certificates_csv(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Export CSV',
            'cnpj' => '66.777.888/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino relatório CSV',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
            'passing_score_percent' => 70,
        ]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 8.5,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $certCode = 'APP²-CSV'.Str::upper(Str::random(8));
        Certificate::query()->create([
            'user_id' => $trainee->id,
            'enrollment_id' => $enrollment->id,
            'training_id' => $training->id,
            'score' => 8.5,
            'certificate_code' => $certCode,
            'issued_at' => now(),
            'expires_at' => now()->addYear(),
        ]);

        $itoken = $instructor->createToken('ins')->plainTextToken;

        $res = $this->withToken($itoken)->get("/api/trainings/{$training->id}/certificates/export.csv");

        $res->assertOk();
        $res->assertHeader('content-type', 'text/csv; charset=UTF-8');
        $body = (string) $res->getContent();
        $this->assertStringContainsString('Participante', $body);
        $this->assertStringContainsString('Treino relatório CSV', $body);
        $this->assertStringContainsString($certCode, $body);
        $this->assertStringContainsString((string) $trainee->name, $body);
    }

    public function test_export_training_certificates_csv_forbidden_for_other_instructor(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Export 403',
            'cnpj' => '77.888.999/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $other = User::factory()->create(['role' => 'instructor']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino privado',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
        ]);

        $otoken = $other->createToken('o')->plainTextToken;

        $this->withToken($otoken)->get("/api/trainings/{$training->id}/certificates/export.csv")
            ->assertForbidden();
    }

    public function test_instructor_can_export_training_certificates_pdf(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Export PDF',
            'cnpj' => '88.999.000/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino relatório PDF',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
            'passing_score_percent' => 70,
        ]);

        Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 7.5,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $itoken = $instructor->createToken('ins')->plainTextToken;

        $res = $this->withToken($itoken)->get("/api/trainings/{$training->id}/certificates/export.pdf");

        $res->assertOk();
        $this->assertStringStartsWith('%PDF', (string) $res->getContent());
    }

    public function test_export_training_certificates_pdf_forbidden_for_other_instructor(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst PDF 403',
            'cnpj' => '99.000.111/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $other = User::factory()->create(['role' => 'instructor']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino PDF priv',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'command_seq' => 0,
        ]);

        $otoken = $other->createToken('o')->plainTextToken;

        $this->withToken($otoken)->get("/api/trainings/{$training->id}/certificates/export.pdf")
            ->assertForbidden();
    }
}
