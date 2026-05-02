<?php

namespace App\Http\Controllers\Api;

use App\Events\TrainingSignal;
use App\Http\Controllers\Controller;
use App\Models\Training;
use App\Support\TrainingSession;
use Illuminate\Http\Request;

class RealtimeController extends Controller
{
    public function health()
    {
        return response()->json([
            'realtime' => 'ready',
            'driver' => config('broadcasting.default'),
        ]);
    }

    public function command(Request $request, string $trainingId)
    {
        $training = Training::query()->findOrFail($trainingId);

        if ((int) $training->instructor_id !== (int) $request->user()->id) {
            return response()->json(['message' => 'Somente o instrutor pode enviar comandos.'], 403);
        }

        $data = $request->validate([
            'action' => ['required', 'in:start,release_block,pause,close,repescage'],
            'payload' => ['nullable', 'array'],
        ]);

        $payload = $data['payload'] ?? [];

        match ($data['action']) {
            'start' => $this->handleStart($training),
            'release_block' => $this->handleReleaseBlock($training, $payload),
            'pause', 'repescage' => $this->handleSignalOnly($training, $data['action'], $payload),
            'close' => $this->handleClose($training, $payload),
        };

        $training->refresh();

        return response()->json([
            'training_id' => $training->id,
            'accepted' => true,
            'action' => $data['action'],
            'payload' => $payload,
            'command_seq' => (int) $training->command_seq,
            'status' => $training->status,
        ]);
    }

    protected function handleStart(Training $training): void
    {
        if ($training->status !== 'in_progress') {
            TrainingSession::markInProgress($training);
        }
    }

    protected function handleReleaseBlock(Training $training, array $payload): void
    {
        if (isset($payload['training_block_id'])) {
            TrainingSession::releaseBlockById($training, (int) $payload['training_block_id']);

            return;
        }

        TrainingSession::releaseNextBlock($training);
    }

    protected function handleSignalOnly(Training $training, string $action, array $payload): void
    {
        $training->increment('command_seq');
        $training->update([
            'last_command' => $action,
            'last_command_payload' => $payload,
        ]);
        $training->refresh();

        broadcast(new TrainingSignal(
            $training->id,
            (int) $training->command_seq,
            $action,
            $payload,
        ));
    }

    protected function handleClose(Training $training, array $payload): void
    {
        $training->update(['status' => 'finished']);
        $this->handleSignalOnly($training, 'close', $payload);
    }
}
