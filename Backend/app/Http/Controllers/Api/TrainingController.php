<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Enrollment;
use App\Models\Training;
use App\Models\TrainingBlock;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class TrainingController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        if (in_array($user->role, ['instructor', 'institution_admin', 'manufacturer_admin'], true)) {
            return Training::query()
                ->where('instructor_id', $user->id)
                ->with('institution:id,name')
                ->latest()
                ->limit(80)
                ->get();
        }

        return Training::query()
            ->whereHas('enrollments', fn ($q) => $q->where('user_id', $user->id))
            ->with('institution:id,name')
            ->latest()
            ->limit(80)
            ->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'institution_id' => ['required', 'integer', 'exists:institutions,id'],
            'manufacturer_id' => ['nullable', 'integer', 'exists:manufacturers,id'],
            'equipment_id' => ['nullable', 'integer', 'exists:equipment,id'],
            'title' => ['required', 'string', 'max:180'],
            'type' => ['required', 'in:official,custom'],
            'scheduled_at' => ['nullable', 'date'],
            'status' => ['nullable', 'in:draft,scheduled,in_progress,finished,cancelled'],
        ]);

        if (! in_array($request->user()->role, ['instructor', 'institution_admin', 'manufacturer_admin'], true)) {
            return response()->json(['message' => 'Sem permissão para criar treinamento.'], 403);
        }

        $data['instructor_id'] = $request->user()->id;
        $data['join_hash'] = Str::lower(Str::random(12));
        $data['status'] = $data['status'] ?? 'draft';

        $training = Training::create($data);

        return response()->json($training->load('institution:id,name'), 201);
    }

    public function show(Request $request, string $id)
    {
        $training = Training::query()->with('institution:id,name')->findOrFail($id);

        if (! $this->userCanAccessTraining($request, $training)) {
            return response()->json(['message' => 'Acesso negado.'], 403);
        }

        return response()->json($training);
    }

    public function update(Request $request, string $id)
    {
        $training = Training::findOrFail($id);

        if ((int) $training->instructor_id !== (int) $request->user()->id) {
            return response()->json(['message' => 'Somente o instrutor pode alterar este treinamento.'], 403);
        }

        $data = $request->validate([
            'title' => ['sometimes', 'string', 'max:180'],
            'type' => ['sometimes', 'in:official,custom'],
            'scheduled_at' => ['nullable', 'date'],
            'status' => ['sometimes', 'in:draft,scheduled,in_progress,finished,cancelled'],
        ]);

        if (($data['status'] ?? null) === 'in_progress') {
            Enrollment::query()
                ->where('training_id', $training->id)
                ->where('status', 'waiting')
                ->update(['status' => 'active']);

            TrainingBlock::query()
                ->where('training_id', $training->id)
                ->update(['is_released' => true]);
        }

        $training->update($data);

        return response()->json($training->fresh()->load('institution:id,name'));
    }

    public function destroy(Request $request, string $id)
    {
        $training = Training::findOrFail($id);

        if ((int) $training->instructor_id !== (int) $request->user()->id) {
            return response()->json(['message' => 'Somente o instrutor pode excluir este treinamento.'], 403);
        }

        $training->delete();

        return response()->noContent();
    }

    protected function userCanAccessTraining(Request $request, Training $training): bool
    {
        $user = $request->user();

        if ((int) $training->instructor_id === (int) $user->id) {
            return true;
        }

        if ($user->role === 'trainee') {
            return Enrollment::query()
                ->where('training_id', $training->id)
                ->where('user_id', $user->id)
                ->exists();
        }

        return false;
    }
}
