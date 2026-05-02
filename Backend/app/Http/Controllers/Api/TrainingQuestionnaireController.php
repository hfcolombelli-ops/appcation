<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Question;
use App\Models\QuestionOption;
use App\Models\Training;
use App\Models\TrainingBlock;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TrainingQuestionnaireController extends Controller
{
    /**
     * Substitui todo o questionário do treinamento (blocos, perguntas e opções).
     */
    public function sync(Request $request, string $trainingId)
    {
        $training = Training::findOrFail($trainingId);

        if ((int) $training->instructor_id !== (int) $request->user()->id) {
            return response()->json(['message' => 'Somente o instrutor pode editar o questionário.'], 403);
        }

        $data = $request->validate([
            'blocks' => ['required', 'array', 'min:1'],
            'blocks.*.title' => ['required', 'string', 'max:180'],
            'blocks.*.sort_order' => ['required', 'integer', 'min:1'],
            'blocks.*.questions' => ['required', 'array', 'min:1'],
            'blocks.*.questions.*.prompt' => ['required', 'string', 'max:2000'],
            'blocks.*.questions.*.sort_order' => ['required', 'integer', 'min:1'],
            'blocks.*.questions.*.options' => ['required', 'array', 'min:2'],
            'blocks.*.questions.*.options.*.label' => ['required', 'string', 'max:500'],
            'blocks.*.questions.*.options.*.is_correct' => ['required', 'boolean'],
            'blocks.*.questions.*.options.*.sort_order' => ['required', 'integer', 'min:1'],
        ]);

        DB::transaction(function () use ($training, $data) {
            TrainingBlock::query()->where('training_id', $training->id)->delete();

            foreach ($data['blocks'] as $blockPayload) {
                $block = TrainingBlock::create([
                    'training_id' => $training->id,
                    'title' => $blockPayload['title'],
                    'sort_order' => $blockPayload['sort_order'],
                    'is_released' => true,
                ]);

                foreach ($blockPayload['questions'] as $qPayload) {
                    $question = Question::create([
                        'training_block_id' => $block->id,
                        'type' => 'multiple_choice',
                        'prompt' => $qPayload['prompt'],
                        'sort_order' => $qPayload['sort_order'],
                        'is_required' => true,
                    ]);

                    foreach ($qPayload['options'] as $optPayload) {
                        QuestionOption::create([
                            'question_id' => $question->id,
                            'label' => $optPayload['label'],
                            'is_correct' => $optPayload['is_correct'],
                            'sort_order' => $optPayload['sort_order'],
                        ]);
                    }
                }
            }
        });

        return response()->json(['message' => 'Questionário salvo com sucesso.']);
    }
}
