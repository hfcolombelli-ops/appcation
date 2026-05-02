<?php

namespace App\Support;

use App\Models\Question;
use App\Models\QuestionOption;
use App\Models\Training;
use App\Models\TrainingBlock;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class TrainingCloner
{
    /**
     * Cria um treinamento operacional a partir de um template oficial (questionário copiado).
     */
    public static function instantiateFromTemplate(
        Training $template,
        User $instructor,
        int $institutionId,
        ?string $title = null,
        ?\DateTimeInterface $scheduledAt = null,
    ): Training {
        if (! $template->is_official_template) {
            throw new \InvalidArgumentException('A origem não é um template oficial.');
        }

        return DB::transaction(function () use ($template, $instructor, $institutionId, $title, $scheduledAt) {
            $training = Training::create([
                'institution_id' => $institutionId,
                'manufacturer_id' => $template->manufacturer_id,
                'instructor_id' => $instructor->id,
                'equipment_id' => $template->equipment_id,
                'title' => $title ?? $template->title,
                'type' => 'official',
                'is_official_template' => false,
                'status' => 'draft',
                'scheduled_at' => $scheduledAt,
                'join_hash' => Str::lower(Str::random(12)),
                'passing_score_percent' => $template->passing_score_percent,
                'metadata' => array_merge($template->metadata ?? [], [
                    'cloned_from_training_id' => $template->id,
                ]),
            ]);

            $blocks = TrainingBlock::query()
                ->where('training_id', $template->id)
                ->with('questions.options')
                ->orderBy('sort_order')
                ->get();

            foreach ($blocks as $srcBlock) {
                $block = TrainingBlock::create([
                    'training_id' => $training->id,
                    'title' => $srcBlock->title,
                    'sort_order' => $srcBlock->sort_order,
                    'is_released' => false,
                ]);

                foreach ($srcBlock->questions as $srcQ) {
                    $q = Question::create([
                        'training_block_id' => $block->id,
                        'type' => $srcQ->type,
                        'prompt' => $srcQ->prompt,
                        'sort_order' => $srcQ->sort_order,
                        'is_required' => $srcQ->is_required,
                    ]);

                    foreach ($srcQ->options as $opt) {
                        QuestionOption::create([
                            'question_id' => $q->id,
                            'label' => $opt->label,
                            'is_correct' => $opt->is_correct,
                            'sort_order' => $opt->sort_order,
                        ]);
                    }
                }
            }

            return $training->fresh();
        });
    }
}
