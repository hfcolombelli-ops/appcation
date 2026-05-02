<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LeaderboardEntry;
use Illuminate\Http\Request;

class InstructorSeasonRankController extends Controller
{
    /**
     * Posições do instrutor em temporadas de fabricantes (treinos com manufacturer_id).
     */
    public function index(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'instructor') {
            return response()->json(['message' => 'Disponível apenas para instrutores.'], 403);
        }

        $rows = LeaderboardEntry::query()
            ->where('instructor_id', $user->id)
            ->with(['season' => fn ($q) => $q->with('manufacturer:id,name')])
            ->orderByDesc('last_computed_at')
            ->limit(40)
            ->get();

        return response()->json($rows);
    }
}
