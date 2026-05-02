<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Season;
use App\Services\SeasonLeaderboardService;
use Illuminate\Http\Request;

class ManufacturerSeasonController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Disponível apenas para administrador de fabricante.'], 403);
        }

        $rows = Season::query()
            ->where('manufacturer_id', $user->manufacturer_id)
            ->orderByDesc('starts_at')
            ->limit(80)
            ->get();

        return response()->json($rows);
    }

    public function store(Request $request, SeasonLeaderboardService $leaderboardService)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
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

        $season = Season::query()
            ->whereKey($id)
            ->where('manufacturer_id', $user->manufacturer_id)
            ->firstOrFail();

        $leaderboardService->recompute($season);

        return response()->json(['ok' => true]);
    }
}
