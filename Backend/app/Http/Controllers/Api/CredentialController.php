<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\InstitutionInstructor;
use App\Models\Manufacturer;
use App\Models\ManufacturerInstructor;
use App\Models\SecurityAuditLog;
use Illuminate\Http\Request;

class CredentialController extends Controller
{
    /** Lista fabricantes para o instrutor solicitar homologação. */
    public function manufacturersCatalog()
    {
        $rows = Manufacturer::query()
            ->where('validation_status', 'active')
            ->orderBy('name')
            ->limit(200)
            ->get(['id', 'name', 'slug', 'status', 'validation_status']);

        return response()->json($rows);
    }

    /** Credenciamento duplo: pedido de vínculo com instituição (Application). */
    public function applyInstitution(Request $request)
    {
        $data = $request->validate([
            'institution_id' => ['required', 'integer', 'exists:institutions,id'],
        ]);

        if ($request->user()->role !== 'instructor') {
            return response()->json(['message' => 'Apenas instrutores solicitam vínculo institucional.'], 403);
        }

        $row = InstitutionInstructor::query()->updateOrCreate(
            [
                'institution_id' => $data['institution_id'],
                'instructor_id' => $request->user()->id,
            ],
            ['status' => 'pending'],
        );

        return response()->json($row->load('institution:id,name,cnpj'), 201);
    }

    /** Pedido de homologação junto ao fabricante (documento Fluxxo). */
    public function applyManufacturer(Request $request)
    {
        $data = $request->validate([
            'manufacturer_id' => ['required', 'integer', 'exists:manufacturers,id'],
        ]);

        if ($request->user()->role !== 'instructor') {
            return response()->json(['message' => 'Apenas instrutores solicitam homologação ao fabricante.'], 403);
        }

        $row = ManufacturerInstructor::query()->updateOrCreate(
            [
                'manufacturer_id' => $data['manufacturer_id'],
                'instructor_id' => $request->user()->id,
            ],
            ['status' => 'pending'],
        );

        return response()->json($row->load('manufacturer:id,name,slug'), 201);
    }

    /** Estado dos vínculos do instrutor logado. */
    public function mine(Request $request)
    {
        if ($request->user()->role !== 'instructor') {
            return response()->json(['message' => 'Disponível para instrutores.'], 403);
        }

        $uid = $request->user()->id;

        return response()->json([
            'institutions' => InstitutionInstructor::query()
                ->where('instructor_id', $uid)
                ->with('institution:id,name,cnpj')
                ->orderBy('updated_at', 'desc')
                ->get(),
            'manufacturers' => ManufacturerInstructor::query()
                ->where('instructor_id', $uid)
                ->with('manufacturer:id,name,slug')
                ->orderBy('updated_at', 'desc')
                ->get(),
        ]);
    }

    /** Fila de pedidos de vínculo à instituição do gestor. */
    public function institutionQueue(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'institution_admin' || $user->institution_id === null) {
            return response()->json(['message' => 'Disponível para gestores com instituição vinculada ao perfil.'], 403);
        }

        $rows = InstitutionInstructor::query()
            ->where('institution_id', $user->institution_id)
            ->where('status', 'pending')
            ->with('instructor:id,name,email')
            ->orderBy('created_at')
            ->get();

        return response()->json($rows);
    }

    public function institutionDecide(Request $request, string $id)
    {
        $user = $request->user();
        if ($user->role !== 'institution_admin' || $user->institution_id === null) {
            return response()->json(['message' => 'Acesso negado.'], 403);
        }

        $data = $request->validate([
            'status' => ['required', 'in:approved,rejected'],
        ]);

        $row = InstitutionInstructor::query()
            ->whereKey($id)
            ->where('institution_id', $user->institution_id)
            ->firstOrFail();

        $row->update(['status' => $data['status']]);

        SecurityAuditLog::record($request, 'credential.institution_decide', InstitutionInstructor::class, (int) $row->id, [
            'new_status' => $data['status'],
        ]);

        return response()->json($row->load('instructor:id,name,email'));
    }

    /** Fabricante: fila de homologações de instrutores. */
    public function manufacturerQueue(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Disponível para administradores do fabricante.'], 403);
        }

        $rows = ManufacturerInstructor::query()
            ->where('manufacturer_id', $user->manufacturer_id)
            ->where('status', 'pending')
            ->with([
                'instructor:id,name,email',
                'endorsedByInstitution:id,name',
            ])
            ->orderBy('created_at')
            ->get();

        return response()->json($rows);
    }

    public function manufacturerDecide(Request $request, string $id)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Acesso negado.'], 403);
        }

        $data = $request->validate([
            'status' => ['required', 'in:approved,rejected'],
            'fee_paid' => ['sometimes', 'boolean'],
        ]);

        $row = ManufacturerInstructor::query()
            ->whereKey($id)
            ->where('manufacturer_id', $user->manufacturer_id)
            ->firstOrFail();

        if ($data['status'] === 'approved') {
            $needsEndorsement = InstitutionInstructor::query()
                ->where('instructor_id', $row->instructor_id)
                ->where('status', 'approved')
                ->exists();
            if ($needsEndorsement && $row->endorsed_at === null) {
                return response()->json([
                    'message' => 'Homologação condicionada: a instituição do instrutor deve endossar o pedido antes de aprovar.',
                ], 422);
            }
        }

        $row->update([
            'status' => $data['status'],
            'fee_paid' => $data['fee_paid'] ?? $row->fee_paid,
        ]);

        SecurityAuditLog::record($request, 'credential.manufacturer_decide', ManufacturerInstructor::class, (int) $row->id, [
            'new_status' => $data['status'],
            'fee_paid' => $row->fee_paid,
        ]);

        return response()->json($row->load([
            'instructor:id,name,email',
            'endorsedByInstitution:id,name',
        ]));
    }
}
