<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Answer;
use App\Models\Enrollment;
use App\Models\Question;
use App\Models\QuestionOption;
use Illuminate\Http\Request;

class QuestionnaireController extends Controller
{
    public function show(string $trainingId)
    {
        $questions = Question::query()
            ->whereHas('trainingBlock', fn ($query) => $query->where('training_id', $trainingId))
            ->with(['options:id,question_id,label,sort_order'])
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

        $enrollment = Enrollment::findOrFail($data['enrollment_id']);

        if ((int) $enrollment->user_id !== (int) $request->user()->id) {
            return response()->json(['message' => 'Você não pode responder por outro usuário.'], 403);
        }

        $isCorrect = null;
        if (! empty($data['question_option_id'])) {
            $selected = QuestionOption::findOrFail($data['question_option_id']);
            $isCorrect = (bool) $selected->is_correct;
        }

        $answer = Answer::updateOrCreate(
            [
                'enrollment_id' => $data['enrollment_id'],
                'question_id' => $data['question_id'],
            ],
            [
                'question_option_id' => $data['question_option_id'] ?? null,
                'text_answer' => $data['text_answer'] ?? null,
                'is_correct' => $isCorrect,
                'score' => $isCorrect === null ? null : ($isCorrect ? 1 : 0),
            ]
        );

        return response()->json($answer, 201);
    }
}
