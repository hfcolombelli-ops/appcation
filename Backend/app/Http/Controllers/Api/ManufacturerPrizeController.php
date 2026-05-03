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

        $validated = $request->validate([
            'search' => ['nullable', 'string', 'max:120'],
            'page' => ['nullable', 'integer', 'min:1'],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:50'],
        ]);

        $page = max(1, (int) ($validated['page'] ?? 1));
        $perPage = min(50, max(1, (int) ($validated['per_page'] ?? 20)));

        $q = ManufacturerPrize::query()
            ->where('manufacturer_id', $user->manufacturer_id);

        if ($request->filled('search')) {
            $raw = trim((string) $request->query('search'));
            $term = '%'.str_replace(['%', '_'], ['\\%', '\\_'], mb_strtolower($raw)).'%';
            $q->where(function ($w) use ($term) {
                $w->whereRaw('LOWER(title) LIKE ?', [$term])
                    ->orWhereRaw('LOWER(COALESCE(description, "")) LIKE ?', [$term]);
            });
        }

        $paginator = $q
            ->orderBy('sort_order')
            ->orderBy('id')
            ->paginate($perPage, ['*'], 'page', $page);

        return response()->json([
            'items' => $paginator->items(),
            'meta' => [
                'current_page' => $paginator->currentPage(),
                'last_page' => max(1, $paginator->lastPage()),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
            ],
        ]);
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
