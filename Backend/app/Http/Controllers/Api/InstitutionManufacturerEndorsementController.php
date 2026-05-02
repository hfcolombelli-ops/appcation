<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\InstitutionInstructor;
use App\Models\ManufacturerInstructor;
use App\Models\SecurityAuditLog;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

/**
 * Endosso institucional a pedidos de homologação instrutor ↔ fabricante (Fluxxo).
 */
class InstitutionManufacturerEndorsementController extends Controller
{
    protected function institutionId(Request $request): ?int
    {
        $user = $request->user();
        if ($user->role !== 'institution_admin' || $user->institution_id === null) {
            return null;
        }

        return (int) $user->institution_id;
    }

    /**
     * Pedidos de homologação ao fabricante que aguardam endosso da instituição
     * (instrutores já aprovados na instituição do gestor).
     */
    public function queue(Request $request)
    {
        $iid = $this->institutionId($request);
        if ($iid === null) {
            return response()->json(['message' => 'Disponível para gestores com instituição vinculada.'], 403);
        }

        $approvedInstructorIds = InstitutionInstructor::query()
            ->where('institution_id', $iid)
            ->where('status', 'approved')
            ->pluck('instructor_id');

        $rows = ManufacturerInstructor::query()
            ->whereIn('instructor_id', $approvedInstructorIds)
            ->whereNull('endorsed_at')
            ->where('status', 'pending')
            ->with([
                'instructor:id,name,email',
                'manufacturer:id,name,slug',
            ])
            ->orderBy('created_at')
            ->limit(100)
            ->get();

        return response()->json($rows);
    }

    public function endorse(Request $request, string $id)
    {
        $iid = $this->institutionId($request);
        if ($iid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $approvedInstructorIds = InstitutionInstructor::query()
            ->where('institution_id', $iid)
            ->where('status', 'approved')
            ->pluck('instructor_id');

        $row = ManufacturerInstructor::query()
            ->whereKey($id)
            ->whereIn('instructor_id', $approvedInstructorIds)
            ->whereNull('endorsed_at')
            ->firstOrFail();

        $row->update([
            'endorsed_by_institution_id' => $iid,
            'endorsed_at' => Carbon::now(),
        ]);

        SecurityAuditLog::record($request, 'institution.manufacturer_instructor_endorse', ManufacturerInstructor::class, (int) $row->id, [
            'endorsed_by_institution_id' => $iid,
        ]);

        return response()->json($row->fresh()->load([
            'instructor:id,name,email',
            'manufacturer:id,name,slug',
            'endorsedByInstitution:id,name',
        ]));
    }
}
