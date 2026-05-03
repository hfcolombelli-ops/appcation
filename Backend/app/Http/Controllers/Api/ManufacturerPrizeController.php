<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\RequiresManufacturerApproved;
use App\Http\Controllers\Controller;
use App\Models\ManufacturerPrize;
use Illuminate\Http\Request;

class ManufacturerPrizeController extends Controller
{
    use RequiresManufacturerApproved;

    public function index(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Disponível apenas para administrador de fabricante.'], 403);
        }

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $rows = ManufacturerPrize::query()
            ->where('manufacturer_id', $user->manufacturer_id)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->limit(200)
            ->get();

        return response()->json($rows);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $data = $request->validate([
            'title' => ['required', 'string', 'max:200'],
            'description' => ['nullable', 'string', 'max:8000'],
            'sort_order' => ['nullable', 'integer', 'min:0', 'max:999999'],
        ]);

        $row = ManufacturerPrize::query()->create([
            'manufacturer_id' => $user->manufacturer_id,
            'title' => $data['title'],
            'description' => $data['description'] ?? null,
            'sort_order' => $data['sort_order'] ?? 0,
        ]);

        return response()->json($row, 201);
    }

    public function update(Request $request, string $id)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $row = ManufacturerPrize::query()
            ->whereKey($id)
            ->where('manufacturer_id', $user->manufacturer_id)
            ->firstOrFail();

        $data = $request->validate([
            'title' => ['sometimes', 'string', 'max:200'],
            'description' => ['nullable', 'string', 'max:8000'],
            'sort_order' => ['nullable', 'integer', 'min:0', 'max:999999'],
        ]);

        $row->update($data);

        return response()->json($row->fresh());
    }

    public function destroy(Request $request, string $id)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $row = ManufacturerPrize::query()
            ->whereKey($id)
            ->where('manufacturer_id', $user->manufacturer_id)
            ->firstOrFail();

        $row->delete();

        return response()->json(['ok' => true]);
    }
}
