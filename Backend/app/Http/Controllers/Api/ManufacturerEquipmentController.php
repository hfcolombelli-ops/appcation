<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Equipment;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/**
 * Catálogo de equipamentos do fabricante (institution_id nulo).
 */
class ManufacturerEquipmentController extends Controller
{
    /**
     * @return list<string>
     */
    protected function allowedCategoryIds(): array
    {
        return collect(config('equipment.categories', []))
            ->pluck('id')
            ->map(fn ($id) => (string) $id)
            ->all();
    }

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

        $allowed = $this->allowedCategoryIds();
        if ($request->filled('category')) {
            $cat = (string) $request->query('category');
            if (! in_array($cat, $allowed, true)) {
                return response()->json(['message' => 'Categoria inválida.'], 422);
            }
        }

        $q = Equipment::query()
            ->where('manufacturer_id', $mid)
            ->whereNull('institution_id');

        if ($request->filled('category')) {
            $q->where('category', (string) $request->query('category'));
        }

        $rows = $q
            ->orderBy('name')
            ->orderBy('id')
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

        $allowed = $this->allowedCategoryIds();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:180'],
            'model' => ['required', 'string', 'max:120'],
            'sector' => ['nullable', 'string', 'max:120'],
            'category' => ['nullable', 'string', 'max:64', Rule::in($allowed)],
            'quantity' => ['nullable', 'integer', 'min:1'],
            'status' => ['nullable', 'string', 'max:40'],
            'parent_equipment_id' => ['nullable', 'integer', 'exists:equipment,id'],
        ]);

        $parentId = $data['parent_equipment_id'] ?? null;
        if ($parentId !== null) {
            $parent = Equipment::query()
                ->whereKey($parentId)
                ->where('manufacturer_id', $mid)
                ->whereNull('institution_id')
                ->first();
            if ($parent === null) {
                return response()->json(['message' => 'Equipamento de origem inválido ou de outro fabricante.'], 422);
            }
        }

        $row = Equipment::create([
            'manufacturer_id' => $mid,
            'institution_id' => null,
            'parent_equipment_id' => $parentId,
            'name' => $data['name'],
            'model' => $data['model'],
            'sector' => $data['sector'] ?? null,
            'category' => $data['category'] ?? null,
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

        if ($row->hasChildVersions()) {
            return response()->json([
                'message' => 'Este registo tem versões derivadas — não pode ser alterado (histórico imutável). Crie uma nova versão em vez de editar.',
            ], 422);
        }

        $allowed = $this->allowedCategoryIds();

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:180'],
            'model' => ['sometimes', 'string', 'max:120'],
            'sector' => ['sometimes', 'nullable', 'string', 'max:120'],
            'category' => ['sometimes', 'nullable', 'string', 'max:64', Rule::in($allowed)],
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

        if ($row->hasChildVersions()) {
            return response()->json([
                'message' => 'Remova primeiro as versões derivadas deste equipamento.',
            ], 422);
        }

        $row->delete();

        return response()->noContent();
    }
}
