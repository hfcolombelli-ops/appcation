<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Manufacturer;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ManufacturerProfileController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Perfil disponível apenas para administrador de fabricante vinculado.'], 403);
        }

        $m = Manufacturer::query()->findOrFail($user->manufacturer_id);

        return response()->json(['manufacturer' => $m]);
    }

    public function update(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:180'],
            'support_email' => ['sometimes', 'nullable', 'email', 'max:190'],
            'cnpj' => ['sometimes', 'nullable', 'string', 'max:20'],
        ]);

        $m = Manufacturer::query()->findOrFail($user->manufacturer_id);

        if (isset($data['name'])) {
            $data['slug'] = Str::slug($data['name']).'-'.$m->id;
        }

        $m->update($data);

        return response()->json(['manufacturer' => $m->fresh()]);
    }
}
