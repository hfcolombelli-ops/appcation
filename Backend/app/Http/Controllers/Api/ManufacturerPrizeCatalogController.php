<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Manufacturer;
use App\Models\ManufacturerPrize;
use Illuminate\Http\Request;

/**
 * Catálogo público de prémios (registo descritivo, sem pagamento no MVP).
 */
class ManufacturerPrizeCatalogController extends Controller
{
    public function index(Request $request)
    {
        $data = $request->validate([
            'manufacturer_id' => ['required', 'integer', 'exists:manufacturers,id'],
        ]);

        Manufacturer::query()->whereKey($data['manufacturer_id'])->where('status', 'active')->firstOrFail();

        $rows = ManufacturerPrize::query()
            ->where('manufacturer_id', $data['manufacturer_id'])
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get(['id', 'title', 'description', 'sort_order']);

        return response()->json($rows);
    }
}
