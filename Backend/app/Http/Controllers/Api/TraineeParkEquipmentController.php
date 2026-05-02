<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Equipment;
use App\Models\TraineeProfile;
use Illuminate\Http\Request;

/**
 * Parque tecnológico da instituição do treinando (ligação pedido de treino ↔ equipamento).
 */
class TraineeParkEquipmentController extends Controller
{
    public function index(Request $request)
    {
        if ($request->user()->role !== 'trainee') {
            return response()->json(['message' => 'Somente treinandos.'], 403);
        }

        $profile = TraineeProfile::query()->where('user_id', $request->user()->id)->first();
        if ($profile === null || $profile->institution_id === null) {
            return response()->json([
                'message' => 'Associe uma instituição ao seu perfil (pré-registro) para ver o parque hospitalar.',
            ], 422);
        }

        $rows = Equipment::query()
            ->where('institution_id', $profile->institution_id)
            ->with(['catalogTemplate.manufacturer:id,name'])
            ->orderBy('name')
            ->orderBy('id')
            ->limit(200)
            ->get();

        return response()->json($rows);
    }
}
