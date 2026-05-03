<?php

namespace App\Http\Controllers\Api;

use App\Events\TrainingSignal;
use App\Http\Controllers\Controller;
use App\Models\Enrollment;
use App\Models\SecurityAuditLog;
use App\Models\Training;
use App\Models\TrainingBlock;
use App\Support\TrainingSession;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class RealtimeController extends Controller
{
    /**
     * Metadados públicos para o Flutter Web ligar ao Reverb (protocolo Pusher).
     * Sem segredos; a app key do Reverb é pública por desenho.
     */
    public function clientConfig(): JsonResponse
    {
        $default = config('broadcasting.default');

        if ($default !== 'reverb') {
            return response()->json([
                'enabled' => false,
                'driver' => $default,
                'reverb' => null,
            ]);
        }

        $key = config('broadcasting.connections.reverb.key');
        if (! is_string($key) || $key === '') {
            return response()->json([
                'enabled' => false,
                'driver' => $default,
                'reverb' => null,
            ]);
        }

        $scheme = env('REVERB_SCHEME', 'http');
        $useTls = $scheme === 'https';
        $port = (int) env('REVERB_PORT', $useTls ? 443 : 8080);
        $clientHost = config('broadcasting.connections.reverb.client_host', '127.0.0.1');

        return response()->json([
            'enabled' => true,
            'driver' => 'reverb',
            'reverb' => [
                'key' => $key,
                'host' => is_string($clientHost) && $clientHost !== '' ? $clientHost : '127.0.0.1',
                'port' => $port,
                'scheme' => $scheme,
                'use_tls' => $useTls,
            ],
        ]);
    }

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
            'action' => ['required', 'in:start,release_block,pause,resume,close,repescage'],
            'payload' => ['nullable', 'array'],
        ]);

        $payload = $data['payload'] ?? [];

        match ($data['action']) {
            'start' => $this->handleStart($training),
            'release_block' => $this->handleReleaseBlock($training, $payload),
            'pause' => $this->handleSignalOnly($training, 'pause', $payload),
            'resume' => $this->handleSignalOnly($training, 'resume', $payload),
            'repescage' => $this->handleRepescage($training, $payload),
            'close' => $this->handleClose($training, $payload),
        };

        $training->refresh();

        SecurityAuditLog::record($request, 'realtime.training_command', Training::class, (int) $training->id, [
            'command' => $data['action'],
        ]);

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

    protected function handleRepescage(Training $training, array $payload): void
    {
        $ids = $payload['enrollment_ids'] ?? null;
        if (! is_array($ids) || $ids === []) {
            throw ValidationException::withMessages([
                'payload.enrollment_ids' => ['Informe enrollment_ids (lista de inscrições) para repescagem.'],
            ]);
        }

        $clean = array_values(array_unique(array_map('intval', $ids)));

        $blockId = isset($payload['training_block_id']) ? (int) $payload['training_block_id'] : null;
        if ($blockId !== null && ! TrainingBlock::query()->where('training_id', $training->id)->whereKey($blockId)->exists()) {
            throw ValidationException::withMessages([
                'payload.training_block_id' => ['Bloco inválido para este treinamento.'],
            ]);
        }

        if ($blockId !== null) {
            foreach ($clean as $eid) {
                $enrollment = Enrollment::query()
                    ->whereKey($eid)
                    ->where('training_id', $training->id)
                    ->firstOrFail();
                if (! TrainingSession::enrollmentBlockBelowHalfAccuracy($enrollment, $blockId)) {
                    throw ValidationException::withMessages([
                        'payload' => [
                            'Repescagem por bloco só é permitida quando o desempenho no bloco está abaixo de 50% (regra Fluxxo). Inscrição #'.$eid.'.',
                        ],
                    ]);
                }
            }
        }

        TrainingSession::applyRepescage($training, $clean, $blockId);
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
        TrainingSession::issueCertificatesOnTrainingFinished($training->fresh());
        $this->handleSignalOnly($training->fresh(), 'close', $payload);
    }
}
