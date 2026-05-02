<?php

namespace App\Support;

use App\Events\TrainingSignal;
use App\Models\Enrollment;
use App\Models\Training;
use App\Models\TrainingBlock;
use Illuminate\Support\Facades\DB;

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
}
