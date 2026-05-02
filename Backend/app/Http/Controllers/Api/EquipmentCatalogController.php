<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;

class EquipmentCatalogController extends Controller
{
    /**
     * Categorias de equipamento (lista fechada para filtros e classificação).
     */
    public function categories()
    {
        return response()->json(config('equipment.categories', []));
    }
}
