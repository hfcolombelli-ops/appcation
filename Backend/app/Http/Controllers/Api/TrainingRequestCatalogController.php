<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;

class TrainingRequestCatalogController extends Controller
{
    /**
     * Motivos padronizados e prioridades para pedidos de treino.
     */
    public function options()
    {
        return response()->json([
            'reason_codes' => config('training_requests.reason_codes', []),
            'priorities' => config('training_requests.priorities', []),
        ]);
    }
}
