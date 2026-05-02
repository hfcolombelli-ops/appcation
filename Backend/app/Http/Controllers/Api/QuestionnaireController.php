<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Answer;
use App\Models\Certificate;
use App\Models\Enrollment;
use App\Models\Question;
use App\Models\QuestionOption;
use App\Models\Training;
use App\Support\FollowUpScheduler;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class QuestionnaireController extends Controller
{
    public function show(Request $request, string $trainingId)
    {
        $training = Training::findOrFail($trainingId);
        $user = $request->user();

        $isInstructor = (int) $training->instructor_id === (int) $user->id;

        $traineeEnrollment = null;
        if (! $isInstructor && $user->role === 'trainee') {
            $traineeEnrollment = Enrollment::query()
                ->where('training_id', $training->id)
                ->where('user_id', $user->id)
                ->firstOrFail();

            if ($training->status !== 'in_progress') {
                return response()->json(['message' => 'Aguarde o instrutor iniciar o treinamento.'], 423);
            }
        } elseif (! $isInstructor) {
            return response()->json(['message' => 'Acesso negado.'], 403);
        }

        // Instrutores precisam ver rascunhos (blocos ainda não libertados) ao editar o questionário;
        // trainees só veem blocos já libertados em sessão.
        // Em repescagem (fase 1 Fluxxo): só perguntas ainda erradas / por repescar no conjunto gravado.
        $questionsQuery = Question::query()
            ->whereHas('trainingBlock', function ($query) use ($trainingId, $user) {
                $query->where('training_id', $trainingId);
                if ($user->role === 'trainee') {
                    $query->where('is_released', true);
                }
            });

        if ($traineeEnrollment !== null
            && $traineeEnrollment->in_recovery
            && is_array($traineeEnrollment->recovery_question_ids)
            && count($traineeEnrollment->recovery_question_ids) > 0
        ) {
            $focus = collect($traineeEnrollment->recovery_question_ids)->map(fn ($v) => (int) $v);
            $correctIds = Answer::query()
                ->where('enrollment_id', $traineeEnrollment->id)
                ->whereIn('question_id', $focus->all())
                ->where('is_correct', true)
                ->pluck('question_id');
            $remaining = $focus->diff($correctIds);
            if ($remaining->isEmpty()) {
                $questionsQuery->whereRaw('0 = 1');
            } else {
                $questionsQuery->whereIn('id', $remaining->all());
            }
        }

        $questions = $questionsQuery
            ->with([
                'options' => function ($q) use ($user) {
                    $cols = ['id', 'question_id', 'label', 'sort_order'];
                    if ($user->role !== 'trainee') {
                        $cols[] = 'is_correct';
                    }
                    $q->select($cols);
                },
            ])
            ->orderBy('sort_order')
            ->get();

        return response()->json($questions);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'enrollment_id' => ['required', 'integer', 'exists:enrollments,id'],
            'question_id' => ['required', 'integer', 'exists:questions,id'],
            'question_option_id' => ['nullable', 'integer', 'exists:question_options,id'],
            'text_answer' => ['nullable', 'string'],
        ]);

        $enrollment = Enrollment::query()->with('training')->findOrFail($data['enrollment_id']);

        if ((int) $enrollment->user_id !== (int) $request->user()->id) {
            return response()->json(['message' => 'Você não pode responder por outro usuário.'], 403);
        }

        if ($enrollment->training->status !== 'in_progress') {
            return response()->json(['message' => 'Treinamento não está em andamento.'], 423);
        }

        $isCorrect = null;
        if (! empty($data['question_option_id'])) {
            $selected = QuestionOption::findOrFail($data['question_option_id']);
            $isCorrect = (bool) $selected->is_correct;
        }

        $textAnswer = isset($data['text_answer'])
            ? Str::limit(trim(strip_tags($data['text_answer'])), 2000)
            : null;
        if ($textAnswer === '') {
            $textAnswer = null;
        }

        $answer = Answer::updateOrCreate(
            [
                'enrollment_id' => $data['enrollment_id'],
                'question_id' => $data['question_id'],
            ],
            [
                'question_option_id' => $data['question_option_id'] ?? null,
                'text_answer' => $textAnswer,
                'is_correct' => $isCorrect,
                'score' => $isCorrect === null ? null : ($isCorrect ? 1 : 0),
            ]
        );

        $this->tryCompleteEnrollment($enrollment);

        return response()->json($answer->fresh(), 201);
    }

    protected function tryCompleteEnrollment(Enrollment $enrollment): void
    {
        $enrollment->refresh();
        $trainingId = $enrollment->training_id;

        $questionIds = Question::query()
            ->whereHas('trainingBlock', fn ($q) => $q->where('training_id', $trainingId)->where('is_released', true))
            ->pluck('id');

        $total = $questionIds->count();

        if ($total === 0) {
            return;
        }

        $answered = Answer::query()
            ->where('enrollment_id', $enrollment->id)
            ->whereIn('question_id', $questionIds)
            ->whereNotNull('question_option_id')
            ->count();

        if ($answered < $total) {
            return;
        }

        if ($enrollment->in_recovery
            && is_array($enrollment->recovery_question_ids)
            && count($enrollment->recovery_question_ids) > 0
        ) {
            foreach ($enrollment->recovery_question_ids as $rqid) {
                $a = Answer::query()
                    ->where('enrollment_id', $enrollment->id)
                    ->where('question_id', (int) $rqid)
                    ->first();
                if ($a === null || ! (bool) $a->is_correct) {
                    return;
                }
            }
        }

        $training = Training::query()->findOrFail($enrollment->training_id);
        $policy = ($training->metadata ?? [])['post_repescage_score_policy'] ?? 'full_average';
        $recoverySnapshot = collect($enrollment->recovery_question_ids ?? [])
            ->map(fn ($v) => (int) $v)
            ->filter()
            ->values();

        $idsForScore = $questionIds;
        if ($policy === 'recovery_only'
            && (int) $enrollment->repescage_round > 0
            && $recoverySnapshot->isNotEmpty()
        ) {
            $idsForScore = $recoverySnapshot;
        }

        $answerRows = Answer::query()
            ->where('enrollment_id', $enrollment->id)
            ->whereIn('question_id', $idsForScore)
            ->get(['score', 'is_correct']);

        $values = $answerRows->map(function (Answer $a) {
            if ($a->score !== null) {
                return (float) $a->score;
            }

            return (bool) $a->is_correct ? 1.0 : 0.0;
        });

        $avg = $values->isEmpty() ? null : $values->avg();

        $scoreTen = $avg === null ? null : round(((float) $avg) * 10, 2);

        $enrollment->update([
            'status' => 'completed',
            'completed_at' => now(),
            'score' => $scoreTen,
            'in_recovery' => false,
            'recovery_question_ids' => null,
        ]);

        $enrollment->refresh();
        FollowUpScheduler::schedule($enrollment);

        $training->load('institution:id,name');
        $passing = (float) ($training->passing_score_percent ?? 70) / 10.0;
        if ($scoreTen !== null && (float) $scoreTen >= $passing) {
            $code = Certificate::query()->where('enrollment_id', $enrollment->id)->value('certificate_code');
            if ($code === null) {
                do {
                    $code = 'APP²-'.Str::upper(Str::random(10));
                } while (Certificate::query()->where('certificate_code', $code)->exists());
            }
            Certificate::updateOrCreate(
                ['enrollment_id' => $enrollment->id],
                [
                    'user_id' => $enrollment->user_id,
                    'training_id' => $enrollment->training_id,
                    'score' => $scoreTen,
                    'certificate_code' => $code,
                    'issued_at' => now(),
                    'expires_at' => now()->addMonths((int) config('app.certificate_validity_months', 24)),
                ]
            );
        }
    }
}
