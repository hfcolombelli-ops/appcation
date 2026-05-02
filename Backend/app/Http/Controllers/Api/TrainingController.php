<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Enrollment;
use App\Models\Training;
use App\Support\TrainingSession;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class TrainingController extends Controller
{
    /**
     * Catálogo de treinamentos oficiais (templates) publicados por fabricantes.
     */
    public function officialTemplatesCatalog(Request $request)
    {
        $rows = Training::query()
            ->where('is_official_template', true)
            ->whereHas('manufacturer', fn ($q) => $q->where('validation_status', 'active'))
            ->with('manufacturer:id,name,slug')
            ->latest()
            ->limit(100)
            ->get();

        return response()->json($rows);
    }

    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role === 'manufacturer_admin' && $request->boolean('templates_only')) {
            return Training::query()
                ->where('manufacturer_id', $user->manufacturer_id)
                ->where('is_official_template', true)
                ->with('institution:id,name')
                ->latest()
                ->limit(80)
                ->get();
        }

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
        $isTemplate = $request->boolean('is_official_template');

        $data = $request->validate([
            'institution_id' => [
                'nullable',
                Rule::requiredIf(! $isTemplate),
                'integer',
                'exists:institutions,id',
            ],
            'manufacturer_id' => ['nullable', 'integer', 'exists:manufacturers,id'],
            'equipment_id' => ['nullable', 'integer', 'exists:equipment,id'],
            'title' => ['required', 'string', 'max:180'],
            'type' => ['required', 'in:official,custom'],
            'scheduled_at' => ['nullable', 'date'],
            'status' => ['nullable', 'in:draft,scheduled,in_progress,finished,cancelled'],
            'is_official_template' => ['sometimes', 'boolean'],
            'passing_score_percent' => ['nullable', 'integer', 'min:40', 'max:100'],
        ]);

        if (! in_array($request->user()->role, ['instructor', 'institution_admin', 'manufacturer_admin'], true)) {
            return response()->json(['message' => 'Sem permissão para criar treinamento.'], 403);
        }

        if ($isTemplate) {
            if ($request->user()->role !== 'manufacturer_admin' || $request->user()->manufacturer_id === null) {
                return response()->json(['message' => 'Apenas o fabricante cria templates oficiais.'], 403);
            }
            $data['institution_id'] = null;
            $data['manufacturer_id'] = $request->user()->manufacturer_id;
            $data['is_official_template'] = true;
        } else {
            $data['is_official_template'] = false;
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

        if (! $this->userCanEditTraining($request, $training)) {
            return response()->json(['message' => 'Sem permissão para alterar este treinamento.'], 403);
        }

        $data = $request->validate([
            'title' => ['sometimes', 'string', 'max:180'],
            'type' => ['sometimes', 'in:official,custom'],
            'scheduled_at' => ['nullable', 'date'],
            'status' => ['sometimes', 'in:draft,scheduled,in_progress,finished,cancelled'],
            'metadata' => ['sometimes', 'array'],
            'metadata.post_repescage_score_policy' => ['sometimes', 'nullable', 'in:full_average,recovery_only'],
            'metadata.repescage_variant_bank' => ['sometimes', 'boolean'],
        ]);

        if (($data['status'] ?? null) === 'in_progress') {
            TrainingSession::markInProgress($training);
            unset($data['status']);
        }

        if (isset($data['metadata'])) {
            $incoming = $data['metadata'];
            unset($data['metadata']);
            $merged = array_merge($training->metadata ?? [], $incoming);
            $training->metadata = $merged;
            $training->save();
        }

        if ($data !== []) {
            $training->update($data);
        }

        return response()->json($training->fresh()->load('institution:id,name'));
    }

    /**
     * Estado realtime (sequência + último comando) — polling no Flutter Web; WebSocket quando Reverb activo.
     */
    public function liveState(Request $request, string $id)
    {
        $training = Training::query()->findOrFail($id);

        if (! $this->userCanAccessTraining($request, $training)) {
            return response()->json(['message' => 'Acesso negado.'], 403);
        }

        $policy = ($training->metadata ?? [])['post_repescage_score_policy'] ?? 'full_average';
        $policyLabelPt = match ($policy) {
            'recovery_only' => 'Nota final: média apenas das questões da última repescagem (substitui a média global).',
            default => 'Nota final: média de todas as questões libertadas no treino.',
        };

        return response()->json([
            'training_id' => $training->id,
            'status' => $training->status,
            'command_seq' => (int) $training->command_seq,
            'last_command' => $training->last_command,
            'last_command_payload' => $training->last_command_payload ?? [],
            'session_paused' => $training->last_command === 'pause',
            'post_repescage_score_policy' => $policy,
            'post_repescage_score_policy_label_pt' => $policyLabelPt,
        ]);
    }

    public function destroy(Request $request, string $id)
    {
        $training = Training::findOrFail($id);

        if (! $this->userCanEditTraining($request, $training)) {
            return response()->json(['message' => 'Sem permissão para excluir este treinamento.'], 403);
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

        if ($user->role === 'manufacturer_admin'
            && $training->manufacturer_id !== null
            && (int) $training->manufacturer_id === (int) $user->manufacturer_id) {
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

    protected function userCanEditTraining(Request $request, Training $training): bool
    {
        $user = $request->user();

        if ((int) $training->instructor_id === (int) $user->id) {
            return true;
        }

        return $user->role === 'manufacturer_admin'
            && $training->is_official_template
            && $training->manufacturer_id !== null
            && (int) $training->manufacturer_id === (int) $user->manufacturer_id;
    }
}
