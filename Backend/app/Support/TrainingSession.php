<?php

namespace App\Support;

use App\Events\TrainingSignal;
use App\Http\Controllers\Api\EnrollmentController;
use App\Models\Answer;
use App\Models\Certificate;
use App\Models\Enrollment;
use App\Models\Question;
use App\Models\Training;
use App\Models\TrainingBlock;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class TrainingSession
{
    /**
     * Treinamento entra em andamento: fila ativa + primeiro bloco liberado + sequência realtime.
     */
    public static function markInProgress(Training $training): void
    {
        if ($training->status === 'in_progress') {
            return;
        }

        DB::transaction(function () use ($training) {
            $training->update(['status' => 'in_progress']);

            Enrollment::query()
                ->where('training_id', $training->id)
                ->where('status', 'waiting')
                ->update(['status' => 'active']);

            self::releaseNextUnreleasedBlock($training);

            $training->increment('command_seq');
            $training->update([
                'last_command' => 'start',
                'last_command_payload' => [],
            ]);

            $training->refresh();

            broadcast(new TrainingSignal(
                $training->id,
                (int) $training->command_seq,
                'start',
                [],
            ));
        });
    }

    public static function releaseNextBlock(Training $training): bool
    {
        $released = false;

        DB::transaction(function () use ($training, &$released) {
            $released = self::releaseNextUnreleasedBlock($training);

            if (! $released) {
                return;
            }

            $training->increment('command_seq');
            $training->update([
                'last_command' => 'release_block',
                'last_command_payload' => [],
            ]);
            $training->refresh();

            broadcast(new TrainingSignal(
                $training->id,
                (int) $training->command_seq,
                'release_block',
                [],
            ));
        });

        return $released;
    }

    public static function releaseNextUnreleasedBlock(Training $training): bool
    {
        $block = TrainingBlock::query()
            ->where('training_id', $training->id)
            ->where('is_released', false)
            ->orderBy('sort_order')
            ->first();

        if ($block === null) {
            return false;
        }

        $block->update(['is_released' => true]);

        return true;
    }

    /**
     * Libera um bloco específico (id), se pertencer ao treinamento.
     */
    public static function releaseBlockById(Training $training, int $blockId): bool
    {
        $block = TrainingBlock::query()
            ->where('training_id', $training->id)
            ->whereKey($blockId)
            ->first();

        if ($block === null || $block->is_released) {
            return false;
        }

        DB::transaction(function () use ($training, $block) {
            $block->update(['is_released' => true]);

            $training->increment('command_seq');
            $training->update([
                'last_command' => 'release_block',
                'last_command_payload' => ['training_block_id' => $block->id],
            ]);
            $training->refresh();

            broadcast(new TrainingSignal(
                $training->id,
                (int) $training->command_seq,
                'release_block',
                ['training_block_id' => $block->id],
            ));
        });

        return true;
    }

    /**
     * Emite ou actualiza certificado quando a nota final (0–10) cumpre o limiar do treino.
     * Usado ao concluir questionário e ao encerrar o treino (GA10).
     */
    public static function issueCertificateForPassedEnrollment(Enrollment $enrollment, Training $training, float $scoreTen): void
    {
        $passing = (float) ($training->passing_score_percent ?? 70) / 10.0;
        if ($scoreTen < $passing) {
            return;
        }

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

    /**
     * Ao encerrar o treino: garante certificados para todas as inscrições concluídas com nota ≥ limiar.
     *
     * @return int Número de inscrições elegíveis para as quais foi garantido certificado.
     */
    public static function issueCertificatesOnTrainingFinished(Training $training): int
    {
        $training->refresh();

        $passing = (float) ($training->passing_score_percent ?? 70) / 10.0;
        $count = 0;

        foreach (
            Enrollment::query()
                ->where('training_id', $training->id)
                ->where('status', 'completed')
                ->whereNotNull('score')
                ->cursor() as $enrollment
        ) {
            $scoreTen = (float) $enrollment->score;
            if ($scoreTen < $passing) {
                continue;
            }
            self::issueCertificateForPassedEnrollment($enrollment, $training, $scoreTen);
            $count++;
        }

        return $count;
    }

    /**
     * Mesma regra que {@see EnrollmentController::forTraining}:
     * contagem de respostas certas no bloco &lt; metade do número de perguntas do bloco.
     */
    public static function enrollmentBlockBelowHalfAccuracy(Enrollment $enrollment, int $trainingBlockId): bool
    {
        $belongs = TrainingBlock::query()
            ->whereKey($trainingBlockId)
            ->where('training_id', $enrollment->training_id)
            ->exists();
        if (! $belongs) {
            return false;
        }

        $total = Question::query()
            ->where('training_block_id', $trainingBlockId)
            ->count();
        if ($total === 0) {
            return false;
        }

        $correct = Answer::query()
            ->where('enrollment_id', $enrollment->id)
            ->whereHas('question', fn ($q) => $q->where('training_block_id', $trainingBlockId))
            ->where('is_correct', true)
            ->count();

        return $correct < ($total / 2);
    }

    /**
     * Fase 2 (variantes): substitui cada pergunta errada por outra do mesmo {@see Question::recovery_variant_group}
     * no mesmo treino, quando {@see Training::metadata}['repescage_variant_bank'] é verdadeiro.
     *
     * @param  list<int>  $clearedQuestionIds
     * @return list<int>
     */
    public static function resolveRecoveryQuestionIdsForVariantBank(Training $training, array $clearedQuestionIds): array
    {
        $meta = $training->metadata ?? [];
        if (empty($meta['repescage_variant_bank'])) {
            return array_values(array_map('intval', $clearedQuestionIds));
        }

        $assigned = [];
        $out = [];
        foreach ($clearedQuestionIds as $qid) {
            $qid = (int) $qid;
            $q = Question::query()->find($qid);
            $group = $q?->recovery_variant_group;
            if ($q === null || $group === null || $group === '') {
                $out[] = $qid;
                $assigned[] = $qid;

                continue;
            }

            $candidates = Question::query()
                ->whereHas('trainingBlock', fn ($b) => $b->where('training_id', $training->id))
                ->where('recovery_variant_group', $group)
                ->where('id', '!=', $qid)
                ->whereNotIn('id', $assigned)
                ->pluck('id');
            if ($candidates->isEmpty()) {
                $out[] = $qid;
                $assigned[] = $qid;

                continue;
            }
            $substitute = (int) $candidates->random();
            $out[] = $substitute;
            $assigned[] = $substitute;
        }

        return array_values(array_unique($out));
    }

    /**
     * Repescagem: remove respostas incorretas, reabre inscrição para nova tentativa (documento Fluxxo).
     * Com {@see $trainingBlockId}, remove apenas erros do bloco (repescagem por bloco).
     *
     * @param  list<int|string>  $enrollmentIds
     */
    public static function applyRepescage(Training $training, array $enrollmentIds, ?int $trainingBlockId = null): void
    {
        DB::transaction(function () use ($training, $enrollmentIds, $trainingBlockId) {
            $affectedIds = [];

            foreach ($enrollmentIds as $eid) {
                $e = Enrollment::query()
                    ->whereKey($eid)
                    ->where('training_id', $training->id)
                    ->firstOrFail();

                if ($trainingBlockId !== null) {
                    $clearedQuestionIds = Answer::query()
                        ->where('enrollment_id', $e->id)
                        ->whereHas('question', fn ($q) => $q->where('training_block_id', $trainingBlockId))
                        ->where(function ($q) {
                            $q->where('is_correct', false)->orWhereNull('is_correct');
                        })
                        ->pluck('question_id')
                        ->unique()
                        ->values()
                        ->all();

                    $deleted = Answer::query()
                        ->where('enrollment_id', $e->id)
                        ->whereHas('question', fn ($q) => $q->where('training_block_id', $trainingBlockId))
                        ->where(function ($q) {
                            $q->where('is_correct', false)->orWhereNull('is_correct');
                        })
                        ->delete();

                    if ($deleted === 0) {
                        continue;
                    }
                } else {
                    $clearedQuestionIds = Answer::query()
                        ->where('enrollment_id', $e->id)
                        ->where(function ($q) {
                            $q->where('is_correct', false)->orWhereNull('is_correct');
                        })
                        ->pluck('question_id')
                        ->unique()
                        ->values()
                        ->all();

                    Answer::query()
                        ->where('enrollment_id', $e->id)
                        ->where(function ($q) {
                            $q->where('is_correct', false)->orWhereNull('is_correct');
                        })
                        ->delete();
                }

                Certificate::query()->where('enrollment_id', $e->id)->delete();

                $recoveryIds = $clearedQuestionIds === []
                    ? []
                    : self::resolveRecoveryQuestionIdsForVariantBank(
                        $training,
                        array_values(array_map('intval', $clearedQuestionIds))
                    );

                $patch = [
                    'in_recovery' => true,
                    'recovery_question_ids' => $recoveryIds === []
                        ? null
                        : $recoveryIds,
                ];
                if ($e->status === 'completed') {
                    $patch['status'] = 'active';
                    $patch['completed_at'] = null;
                    $patch['score'] = null;
                }
                $e->update($patch);
                $e->increment('repescage_round');
                $affectedIds[] = (int) $e->id;
            }

            if ($trainingBlockId !== null && $affectedIds === []) {
                throw ValidationException::withMessages([
                    'payload' => ['Nenhuma resposta errada neste bloco para os inscritos seleccionados.'],
                ]);
            }

            $signalPayload = [
                'enrollment_ids' => $trainingBlockId !== null
                    ? $affectedIds
                    : array_map('intval', $enrollmentIds),
            ];
            if ($trainingBlockId !== null) {
                $signalPayload['training_block_id'] = $trainingBlockId;
                $signalPayload['requested_enrollment_ids'] = array_map('intval', $enrollmentIds);
            }

            $training->increment('command_seq');
            $training->update([
                'last_command' => 'repescage',
                'last_command_payload' => $signalPayload,
            ]);
            $training->refresh();

            broadcast(new TrainingSignal(
                $training->id,
                (int) $training->command_seq,
                'repescage',
                $signalPayload,
            ));
        });
    }
}
