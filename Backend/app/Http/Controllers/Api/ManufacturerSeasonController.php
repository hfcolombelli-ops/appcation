<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\RequiresManufacturerApproved;
use App\Http\Controllers\Controller;
use App\Models\Season;
use App\Services\SeasonLeaderboardService;
use Illuminate\Http\Request;

class ManufacturerSeasonController extends Controller
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

        $q = Season::query()
            ->where('manufacturer_id', $user->manufacturer_id);

        if ($request->filled('search')) {
            $raw = trim((string) $request->query('search'));
            $term = '%'.str_replace(['%', '_'], ['\\%', '\\_'], mb_strtolower($raw)).'%';
            $q->where(function ($w) use ($term) {
                $w->whereRaw('LOWER(name) LIKE ?', [$term])
                    ->orWhereRaw('LOWER(COALESCE(notes, "")) LIKE ?', [$term])
                    ->orWhereRaw('CAST(target_trainings AS TEXT) LIKE ?', [$term]);
            });
        }

        $paginator = $q
            ->orderByDesc('starts_at')
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

    public function store(Request $request, SeasonLeaderboardService $leaderboardService)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:180'],
            'starts_at' => ['required', 'date'],
            'ends_at' => ['required', 'date', 'after_or_equal:starts_at'],
            'target_trainings' => ['nullable', 'integer', 'min:0', 'max:999999'],
            'notes' => ['nullable', 'string', 'max:2000'],
        ]);

        $season = Season::query()->create([
            'manufacturer_id' => $user->manufacturer_id,
            'name' => $data['name'],
            'starts_at' => $data['starts_at'],
            'ends_at' => $data['ends_at'],
            'target_trainings' => $data['target_trainings'] ?? null,
            'notes' => $data['notes'] ?? null,
        ]);

        $leaderboardService->recompute($season);

        return response()->json($season->fresh(), 201);
    }

    public function update(Request $request, string $id, SeasonLeaderboardService $leaderboardService)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $season = Season::query()
            ->whereKey($id)
            ->where('manufacturer_id', $user->manufacturer_id)
            ->firstOrFail();

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:180'],
            'starts_at' => ['sometimes', 'date'],
            'ends_at' => ['sometimes', 'date'],
            'target_trainings' => ['nullable', 'integer', 'min:0', 'max:999999'],
            'notes' => ['nullable', 'string', 'max:2000'],
        ]);

        $season->fill($data);
        if ($season->ends_at < $season->starts_at) {
            return response()->json(['message' => 'A data de fim deve ser ≥ à de início.'], 422);
        }

        $season->save();

        if (array_intersect_key($data, array_flip(['starts_at', 'ends_at']))) {
            $season->refresh();
            $leaderboardService->recompute($season);
        }

        return response()->json($season->fresh());
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

        $season = Season::query()
            ->whereKey($id)
            ->where('manufacturer_id', $user->manufacturer_id)
            ->firstOrFail();

        $season->delete();

        return response()->json(['ok' => true]);
    }

    public function leaderboard(Request $request, string $id)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $season = Season::query()
            ->whereKey($id)
            ->where('manufacturer_id', $user->manufacturer_id)
            ->firstOrFail();

        $entries = $season->leaderboardEntries()
            ->with('instructor:id,name,email')
            ->orderBy('rank')
            ->orderByDesc('points')
            ->get();

        return response()->json([
            'season' => $season,
            'entries' => $entries,
            'target_trainings' => $season->target_trainings,
        ]);
    }

    public function recompute(Request $request, string $id, SeasonLeaderboardService $leaderboardService)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $season = Season::query()
            ->whereKey($id)
            ->where('manufacturer_id', $user->manufacturer_id)
            ->firstOrFail();

        $leaderboardService->recompute($season);

        return response()->json(['ok' => true]);
    }
}
