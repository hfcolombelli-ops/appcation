<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Training;
use Illuminate\Support\Str;

class PublicTrainingPreviewController extends Controller
{
    /**
     * Metadados mínimos para landing pública (fase 2 — registo treinando).
     */
    public function joinPreview(string $hash)
    {
        $h = Str::lower(trim($hash));
        if ($h === '') {
            return response()->json(['message' => 'Código inválido.'], 404);
        }

        $training = Training::query()
            ->where('join_hash', $h)
            ->with('institution:id,name')
            ->first();

        if ($training === null) {
            return response()->json(['message' => 'Treino não encontrado.'], 404);
        }

        return response()->json([
            'title' => $training->title,
            'institution_name' => $training->institution?->name,
        ]);
    }
}
