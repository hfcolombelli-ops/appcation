<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Equipment;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/**
 * Parque tecnológico da instituição: unidades físicas ligadas a modelos do catálogo do fabricante.
 */
class InstitutionEquipmentController extends Controller
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

    protected function institutionId(Request $request): ?int
    {
        $user = $request->user();
        if ($user->role !== 'institution_admin' || $user->institution_id === null) {
            return null;
        }

        return (int) $user->institution_id;
    }

    /**
     * Modelos do catálogo (fabricante) disponíveis para vincular ao parque.
     */
    public function templates(Request $request)
    {
        if ($this->institutionId($request) === null) {
            return response()->json(['message' => 'Disponível para gestores com instituição vinculada.'], 403);
        }

        $allowed = $this->allowedCategoryIds();
        if ($request->filled('category')) {
            $cat = (string) $request->query('category');
            if (! in_array($cat, $allowed, true)) {
                return response()->json(['message' => 'Categoria inválida.'], 422);
            }
        }

        $q = Equipment::query()
            ->whereNull('institution_id')
            ->whereNotNull('manufacturer_id')
            ->with(['manufacturer:id,name']);

        if ($request->filled('category')) {
            $q->where('category', (string) $request->query('category'));
        }

        $rows = $q
            ->orderBy('manufacturer_id')
            ->orderBy('name')
            ->orderBy('id')
            ->limit(500)
            ->get();

        return response()->json($rows);
    }

    public function index(Request $request)
    {
        $iid = $this->institutionId($request);
        if ($iid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $allowed = $this->allowedCategoryIds();
        if ($request->filled('category')) {
            $cat = (string) $request->query('category');
            if (! in_array($cat, $allowed, true)) {
                return response()->json(['message' => 'Categoria inválida.'], 422);
            }
        }

        if ($request->filled('status')) {
            $st = (string) $request->query('status');
            if (! in_array($st, ['pending', 'active'], true)) {
                return response()->json(['message' => 'Estado inválido (use pending ou active).'], 422);
            }
        }

        $q = Equipment::query()
            ->where('institution_id', $iid)
            ->with(['catalogTemplate.manufacturer:id,name', 'manufacturer:id,name']);

        if ($request->filled('category')) {
            $q->where('category', (string) $request->query('category'));
        }

        if ($request->filled('status')) {
            $q->where('status', (string) $request->query('status'));
        }

        $rows = $q->orderBy('name')->orderBy('id')->limit(200)->get();

        return response()->json($rows);
    }

    public function store(Request $request)
    {
        $iid = $this->institutionId($request);
        if ($iid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $data = $request->validate([
            'catalog_equipment_id' => ['required', 'integer', 'exists:equipment,id'],
            'sector' => ['nullable', 'string', 'max:120'],
            'quantity' => ['nullable', 'integer', 'min:1'],
            'status' => ['nullable', 'string', Rule::in(['pending', 'active'])],
        ]);

        $catalog = Equipment::query()
            ->whereKey($data['catalog_equipment_id'])
            ->whereNull('institution_id')
            ->whereNotNull('manufacturer_id')
            ->first();

        if ($catalog === null) {
            return response()->json(['message' => 'O modelo de catálogo indicado não existe ou não é um modelo de fabricante.'], 422);
        }

        $row = Equipment::create([
            'institution_id' => $iid,
            'manufacturer_id' => $catalog->manufacturer_id,
            'parent_equipment_id' => null,
            'catalog_equipment_id' => $catalog->id,
            'name' => $catalog->name,
            'model' => $catalog->model,
            'sector' => $data['sector'] ?? $catalog->sector,
            'category' => $catalog->category,
            'quantity' => $data['quantity'] ?? 1,
            'status' => $data['status'] ?? 'pending',
        ]);

        return response()->json($row->load(['catalogTemplate.manufacturer:id,name', 'manufacturer:id,name']), 201);
    }

    public function update(Request $request, string $id)
    {
        $iid = $this->institutionId($request);
        if ($iid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $row = Equipment::query()
            ->whereKey($id)
            ->where('institution_id', $iid)
            ->firstOrFail();

        $data = $request->validate([
            'sector' => ['sometimes', 'nullable', 'string', 'max:120'],
            'quantity' => ['sometimes', 'integer', 'min:1'],
            'status' => ['sometimes', 'string', Rule::in(['pending', 'active'])],
        ]);

        $row->update($data);

        return response()->json($row->fresh()->load(['catalogTemplate.manufacturer:id,name', 'manufacturer:id,name']));
    }

    public function destroy(Request $request, string $id)
    {
        $iid = $this->institutionId($request);
        if ($iid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $row = Equipment::query()
            ->whereKey($id)
            ->where('institution_id', $iid)
            ->firstOrFail();

        $row->delete();

        return response()->noContent();
    }
}
