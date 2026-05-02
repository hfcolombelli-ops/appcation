<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Institution;
use App\Models\InstitutionInstructor;
use App\Models\Training;
use App\Models\User;
use Illuminate\Http\Request;

class InstitutionController extends Controller
{
    /** Catálogo público (cadastro de gestor sem sessão). */
    public function publicCatalog()
    {
        return Institution::query()
            ->orderBy('name')
            ->limit(500)
            ->get(['id', 'name', 'cnpj', 'city', 'state']);
    }

    public function index()
    {
        return Institution::query()->orderBy('name')->limit(200)->get();
    }

    /** Treinos da instituição do gestor (ligar pedido → treino realizado). */
    public function myTrainingsAsGestor(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'institution_admin' || $user->institution_id === null) {
            return response()->json(['message' => 'Apenas gestores com instituição vinculada.'], 403);
        }

        return Training::query()
            ->where('institution_id', $user->institution_id)
            ->with('instructor:id,name,email')
            ->latest()
            ->limit(150)
            ->get();
    }

    /** Instrutores com vínculo aprovado nesta instituição. */
    public function approvedInstructors(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'institution_admin' || $user->institution_id === null) {
            return response()->json(['message' => 'Apenas gestores com instituição vinculada.'], 403);
        }

        $ids = InstitutionInstructor::query()
            ->where('institution_id', $user->institution_id)
            ->where('status', 'approved')
            ->pluck('instructor_id');

        return User::query()
            ->whereIn('id', $ids)
            ->orderBy('name')
            ->get(['id', 'name', 'email']);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:180'],
            'legal_name' => ['nullable', 'string', 'max:180'],
            'cnpj' => ['required', 'string', 'max:20', 'unique:institutions,cnpj'],
            'email' => ['nullable', 'email', 'max:190'],
            'phone' => ['nullable', 'string', 'max:25'],
            'city' => ['nullable', 'string', 'max:120'],
            'state' => ['nullable', 'string', 'max:2'],
        ]);

        $data['status'] = 'active';

        $institution = Institution::create($data);

        return response()->json($institution, 201);
    }
}
