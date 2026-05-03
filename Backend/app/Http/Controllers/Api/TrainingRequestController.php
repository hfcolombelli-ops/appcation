<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Equipment;
use App\Models\SecurityAuditLog;
use App\Models\TrainingRequest;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class TrainingRequestController extends Controller
{
    /** Treinando: abre pedido de treinamento (Fluxxo cap. instituição). */
    public function store(Request $request)
    {
        if ($request->user()->role !== 'trainee') {
            return response()->json(['message' => 'Somente treinandos abrem pedidos.'], 403);
        }

        $reasonIds = collect(config('training_requests.reason_codes', []))->pluck('id')->all();
        $priorityIds = collect(config('training_requests.priorities', []))->pluck('id')->all();

        $data = $request->validate([
            'institution_id' => ['required', 'integer', 'exists:institutions,id'],
            'equipment_id' => ['nullable', 'integer', 'exists:equipment,id'],
            'reason_code' => ['required', 'string', 'max:48', Rule::in($reasonIds)],
            'priority' => ['nullable', 'string', 'max:24', Rule::in($priorityIds)],
            'desired_date' => ['nullable', 'date'],
            'latest_acceptable_date' => ['nullable', 'date'],
            'reason' => ['nullable', 'string', 'max:2000'],
            'notes' => ['nullable', 'string', 'max:2000'],
        ]);

        if (! empty($data['equipment_id'])) {
            $belongs = Equipment::query()
                ->whereKey($data['equipment_id'])
                ->where('institution_id', $data['institution_id'])
                ->whereNotNull('institution_id')
                ->exists();
            if (! $belongs) {
                return response()->json([
                    'message' => 'O equipamento indicado não pertence ao parque desta instituição.',
                ], 422);
            }
        }

        $row = TrainingRequest::create([
            'institution_id' => $data['institution_id'],
            'requested_by' => $request->user()->id,
            'equipment_id' => $data['equipment_id'] ?? null,
            'reason_code' => $data['reason_code'],
            'priority' => $data['priority'] ?? 'normal',
            'desired_date' => $data['desired_date'] ?? null,
            'latest_acceptable_date' => $data['latest_acceptable_date'] ?? null,
            'reason' => $data['reason'] ?? null,
            'notes' => $data['notes'] ?? null,
            'status' => 'pending',
        ]);

        return response()->json($row->load([
            'institution:id,name',
            'equipment:id,name,model,sector,category,status,catalog_equipment_id',
            'equipment.catalogTemplate.manufacturer:id,name',
        ]), 201);
    }

    public function mine(Request $request)
    {
        if ($request->user()->role !== 'trainee') {
            return response()->json(['message' => 'Somente treinandos.'], 403);
        }

        $rows = TrainingRequest::query()
            ->where('requested_by', $request->user()->id)
            ->with([
                'institution:id,name',
                'equipment:id,name,model,sector,category,status,catalog_equipment_id',
                'equipment.catalogTemplate.manufacturer:id,name',
            ])
            ->latest()
            ->limit(50)
            ->get();

        return response()->json($rows);
    }

    /** Gestor da instituição: fila de pedidos. */
    public function institutionIndex(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'institution_admin' || $user->institution_id === null) {
            return response()->json(['message' => 'Disponível para gestores com instituição no perfil.'], 403);
        }

        $rows = TrainingRequest::query()
            ->where('institution_id', $user->institution_id)
            ->with([
                'requester:id,name,email',
                'assignedInstructor:id,name,email',
                'fulfilledTraining:id,title,join_hash,status',
                'equipment:id,name,model,sector,category,status,catalog_equipment_id',
                'equipment.catalogTemplate.manufacturer:id,name',
            ])
            ->latest()
            ->limit(100)
            ->get();

        return response()->json($rows);
    }

    public function institutionUpdate(Request $request, string $id)
    {
        $user = $request->user();
        if ($user->role !== 'institution_admin' || $user->institution_id === null) {
            return response()->json(['message' => 'Acesso negado.'], 403);
        }

        $data = $request->validate([
            'status' => ['sometimes', 'in:pending,approved,scheduled,rejected,fulfilled'],
            'assigned_instructor_id' => ['nullable', 'integer', 'exists:users,id'],
            'fulfilled_training_id' => ['nullable', 'integer', 'exists:trainings,id'],
            'notes' => ['nullable', 'string', 'max:2000'],
        ]);

        $row = TrainingRequest::query()
            ->whereKey($id)
            ->where('institution_id', $user->institution_id)
            ->firstOrFail();

        $newStatus = $data['status'] ?? $row->status;
        $mergedInstr = array_key_exists('assigned_instructor_id', $data)
            ? $data['assigned_instructor_id']
            : $row->assigned_instructor_id;
        $mergedTraining = array_key_exists('fulfilled_training_id', $data)
            ? $data['fulfilled_training_id']
            : $row->fulfilled_training_id;

        $instrId = $mergedInstr !== null && $mergedInstr !== ''
            ? (int) $mergedInstr
            : null;
        $trainingId = $mergedTraining !== null && $mergedTraining !== ''
            ? (int) $mergedTraining
            : null;

        if ($newStatus === 'scheduled' && ($instrId === null || $instrId < 1)) {
            throw ValidationException::withMessages([
                'assigned_instructor_id' => ['Estado «agendado» requer instrutor designado.'],
            ]);
        }

        if ($newStatus === 'fulfilled' && ($trainingId === null || $trainingId < 1)) {
            throw ValidationException::withMessages([
                'fulfilled_training_id' => ['Estado «concluído» requer treino realizado associado.'],
            ]);
        }

        $row->update($data);

        SecurityAuditLog::record($request, 'training_request.institution_update', TrainingRequest::class, (int) $row->id, [
            'fields' => array_keys($data),
        ]);

        return response()->json($row->fresh()->load([
            'requester:id,name,email',
            'assignedInstructor:id,name,email',
            'fulfilledTraining:id,title,join_hash,status',
            'equipment:id,name,model,sector,category,status,catalog_equipment_id',
            'equipment.catalogTemplate.manufacturer:id,name',
        ]));
    }
}
