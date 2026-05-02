<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

/**
 * Sinal em tempo real para treinandos (WebSocket/Reverb quando BROADCAST_CONNECTION=reverb).
 * O Flutter Web usa também GET /api/trainings/{id}/live-state como fallback por polling.
 */
class TrainingSignal implements ShouldBroadcastNow
{
    use Dispatchable, SerializesModels;

    public function __construct(
        public int $trainingId,
        public int $seq,
        public string $action,
        public array $payload,
    ) {}

    /**
     * @return array<int, Channel>
     */
    public function broadcastOn(): array
    {
        return [new Channel('training.'.$this->trainingId)];
    }

    public function broadcastAs(): string
    {
        return 'training.signal';
    }

    /**
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        return [
            'training_id' => $this->trainingId,
            'seq' => $this->seq,
            'action' => $this->action,
            'payload' => $this->payload,
        ];
    }
}
