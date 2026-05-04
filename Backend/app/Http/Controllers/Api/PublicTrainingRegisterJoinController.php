<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Enrollment;
use App\Models\Training;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;

class PublicTrainingRegisterJoinController extends Controller
{
    /**
     * Cria conta treinando e inscrição no treino identificado por `join_hash` (sem sessão prévia).
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'join_hash' => ['required', 'string', 'max:64'],
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:190', 'unique:users,email'],
            'password' => ['required', 'confirmed', Password::min(8)],
        ]);

        $h = Str::lower(trim($data['join_hash']));
        if ($h === '') {
            return response()->json(['message' => 'Código inválido.'], 404);
        }

        $training = Training::query()->where('join_hash', $h)->first();
        if ($training === null) {
            return response()->json(['message' => 'Treino não encontrado.'], 404);
        }

        if (! in_array($training->status, ['scheduled', 'in_progress'], true)) {
            return response()->json(['message' => 'Este treino não aceita novas inscrições por link.'], 422);
        }

        $email = strtolower(trim($data['email']));

        $user = DB::transaction(function () use ($data, $email, $training) {
            $user = User::create([
                'name' => trim($data['name']),
                'email' => $email,
                'password' => $data['password'],
                'role' => 'trainee',
                'institution_id' => $training->institution_id,
                'google_triage_completed_at' => now(),
            ]);

            Enrollment::query()->firstOrCreate(
                [
                    'training_id' => $training->id,
                    'user_id' => $user->id,
                ],
                [
                    'status' => 'waiting',
                    'joined_at' => now(),
                ],
            );

            return $user->fresh();
        });

        $training->load('institution:id,name');

        return response()->json([
            'token' => $user->createToken('web')->plainTextToken,
            'user' => $user->toApiArray(),
            'training' => $training,
        ], 201);
    }
}
