<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Institution;
use Illuminate\Http\Request;

class ManufacturerInstitutionController extends Controller
{
    /** Instituições ligadas ao fabricante do administrador autenticado. */
    public function index(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Apenas administrador de fabricante.'], 403);
        }

        $rows = Institution::query()
            ->where('manufacturer_id', $user->manufacturer_id)
            ->orderBy('name')
            ->limit(200)
            ->get();

        return response()->json($rows->values()->all());
    }

    /** Instituição criada pelo fabricante (liga `manufacturer_id`). */
    public function store(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Apenas administrador de fabricante.'], 403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:180'],
            'legal_name' => ['nullable', 'string', 'max:180'],
            'cnpj' => ['required', 'string', 'max:20', 'unique:institutions,cnpj'],
            'email' => ['nullable', 'email', 'max:190'],
            'phone' => ['nullable', 'string', 'max:25'],
            'city' => ['nullable', 'string', 'max:120'],
            'state' => ['nullable', 'string', 'max:2'],
        ]);

        $digits = preg_replace('/\D+/', '', (string) $data['cnpj']);
        $data['cnpj'] = $digits !== '' ? $digits : $data['cnpj'];

        $institution = Institution::create([
            ...$data,
            'status' => 'active',
            'manufacturer_id' => $user->manufacturer_id,
        ]);

        return response()->json($institution, 201);
    }
}
