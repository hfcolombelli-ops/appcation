<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Equipment;
use Illuminate\Http\Request;

/**
 * Catálogo de equipamentos do fabricante (institution_id nulo).
 */
class ManufacturerEquipmentController extends Controller
{
    protected function manufacturerId(Request $request): ?int
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return null;
        }

        return (int) $user->manufacturer_id;
    }

    public function index(Request $request)
    {
        $mid = $this->manufacturerId($request);
        if ($mid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $rows = Equipment::query()
            ->where('manufacturer_id', $mid)
            ->whereNull('institution_id')
            ->orderBy('name')
            ->limit(200)
            ->get();

        return response()->json($rows);
    }

    public function store(Request $request)
    {
        $mid = $this->manufacturerId($request);
        if ($mid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:180'],
            'model' => ['required', 'string', 'max:120'],
            'sector' => ['nullable', 'string', 'max:120'],
            'quantity' => ['nullable', 'integer', 'min:1'],
            'status' => ['nullable', 'string', 'max:40'],
        ]);

        $row = Equipment::create([
            'manufacturer_id' => $mid,
            'institution_id' => null,
            'name' => $data['name'],
            'model' => $data['model'],
            'sector' => $data['sector'] ?? null,
            'quantity' => $data['quantity'] ?? 1,
            'status' => $data['status'] ?? 'active',
        ]);

        return response()->json($row, 201);
    }

    public function update(Request $request, string $id)
    {
        $mid = $this->manufacturerId($request);
        if ($mid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $row = Equipment::query()
            ->whereKey($id)
            ->where('manufacturer_id', $mid)
            ->whereNull('institution_id')
            ->firstOrFail();

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:180'],
            'model' => ['sometimes', 'string', 'max:120'],
            'sector' => ['sometimes', 'nullable', 'string', 'max:120'],
            'quantity' => ['sometimes', 'integer', 'min:1'],
            'status' => ['sometimes', 'string', 'max:40'],
        ]);

        $row->update($data);

        return response()->json($row->fresh());
    }

    public function destroy(Request $request, string $id)
    {
        $mid = $this->manufacturerId($request);
        if ($mid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $row = Equipment::query()
            ->whereKey($id)
            ->where('manufacturer_id', $mid)
            ->whereNull('institution_id')
            ->firstOrFail();

        $row->delete();

        return response()->noContent();
    }
}
