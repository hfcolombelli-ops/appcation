<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TraineeProfile;
use Illuminate\Http\Request;

class TraineeProfileController extends Controller
{
    public function show(Request $request)
    {
        if ($request->user()->role !== 'trainee') {
            return response()->json(['message' => 'Perfil disponível apenas para treinandos.'], 403);
        }

        $profile = TraineeProfile::query()
            ->where('user_id', $request->user()->id)
            ->with('institution:id,name')
            ->first();

        return response()->json(['profile' => $profile]);
    }

    public function update(Request $request)
    {
        if ($request->user()->role !== 'trainee') {
            return response()->json(['message' => 'Perfil disponível apenas para treinandos.'], 403);
        }

        $data = $request->validate([
            'sector' => ['required', 'string', 'max:120'],
            'institution_id' => ['nullable', 'integer', 'exists:institutions,id'],
            'equipment_label' => ['nullable', 'string', 'max:180'],
            'session_at' => ['nullable', 'date'],
        ]);

        $profile = TraineeProfile::updateOrCreate(
            ['user_id' => $request->user()->id],
            $data
        );

        $profile->load('institution:id,name');

        return response()->json(['profile' => $profile]);
    }
}
