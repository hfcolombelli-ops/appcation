<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Answer;
use App\Models\Enrollment;
use App\Models\Question;
use App\Models\QuestionOption;
use App\Models\Training;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class QuestionnaireController extends Controller
{
    public function show(Request $request, string $trainingId)
    {
        $training = Training::findOrFail($trainingId);
        $user = $request->user();

        $isInstructor = (int) $training->instructor_id === (int) $user->id;

        if (! $isInstructor && $user->role === 'trainee') {
            Enrollment::query()
                ->where('training_id', $training->id)
                ->where('user_id', $user->id)
                ->firstOrFail();

            if ($training->status !== 'in_progress') {
                return response()->json(['message' => 'Aguarde o instrutor iniciar o treinamento.'], 423);
            }
        } elseif (! $isInstructor) {
            return response()->json(['message' => 'Acesso negado.'], 403);
        }

        $questions = Question::query()
            ->whereHas('trainingBlock', function ($query) use ($trainingId) {
                $query->where('training_id', $trainingId)->where('is_released', true);
            })
            ->with(['options' => fn ($q) => $q->select('id', 'question_id', 'label', 'sort_order')])
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

        $avg = Answer::query()
            ->where('enrollment_id', $enrollment->id)
            ->whereIn('question_id', $questionIds)
            ->whereNotNull('score')
            ->avg('score');

        $scoreTen = $avg === null ? null : round(((float) $avg) * 10, 2);

        $enrollment->update([
            'status' => 'completed',
            'completed_at' => now(),
            'score' => $scoreTen,
        ]);
    }
}
