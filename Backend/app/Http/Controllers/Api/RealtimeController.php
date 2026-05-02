<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
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
        $data = $request->validate([
            'action' => ['required', 'in:start,release_block,pause,close,repescage'],
            'payload' => ['nullable', 'array'],
        ]);

        // TODO: disparar evento broadcast com Reverb/Pusher para o canal training.{id}.command.
        return response()->json([
            'training_id' => $trainingId,
            'accepted' => true,
            'action' => $data['action'],
            'payload' => $data['payload'] ?? [],
        ]);
    }
}
