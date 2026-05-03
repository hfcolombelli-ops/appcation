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
            'trade_name' => ['sometimes', 'nullable', 'string', 'max:180'],
            'support_email' => ['sometimes', 'nullable', 'email', 'max:190'],
            'cnpj' => ['sometimes', 'nullable', 'string', 'max:20'],
            'state_registration' => ['sometimes', 'nullable', 'string', 'max:32'],
            'website' => ['sometimes', 'nullable', 'string', 'max:255'],
            'commercial_phone' => ['sometimes', 'nullable', 'string', 'max:32'],
            'address_postal_code' => ['sometimes', 'nullable', 'string', 'max:16'],
            'address_street' => ['sometimes', 'nullable', 'string', 'max:255'],
            'address_neighborhood' => ['sometimes', 'nullable', 'string', 'max:120'],
            'address_city' => ['sometimes', 'nullable', 'string', 'max:120'],
            'address_state' => ['sometimes', 'nullable', 'string', 'size:2'],
            'legal_rep_full_name' => ['sometimes', 'nullable', 'string', 'max:180'],
            'legal_rep_cpf' => ['sometimes', 'nullable', 'string', 'max:18'],
            'legal_rep_role' => ['sometimes', 'nullable', 'string', 'max:120'],
            'legal_rep_phone' => ['sometimes', 'nullable', 'string', 'max:32'],
            'declaration_accepted' => ['sometimes', 'boolean'],
        ]);

        $m = Manufacturer::query()->findOrFail($user->manufacturer_id);

        if (array_key_exists('cnpj', $data)) {
            $digits = preg_replace('/\D+/', '', (string) ($data['cnpj'] ?? ''));
            $data['cnpj'] = $digits !== '' ? $digits : null;
        }

        if (array_key_exists('legal_rep_cpf', $data)) {
            $digits = preg_replace('/\D+/', '', (string) ($data['legal_rep_cpf'] ?? ''));
            $data['legal_rep_cpf'] = $digits !== '' ? $digits : null;
        }

        if (array_key_exists('address_postal_code', $data) && $data['address_postal_code'] !== null) {
            $data['address_postal_code'] = preg_replace('/\D+/', '', (string) $data['address_postal_code']);
        }

        if (array_key_exists('address_state', $data) && is_string($data['address_state'])) {
            $data['address_state'] = strtoupper(substr(trim($data['address_state']), 0, 2));
        }

        if (array_key_exists('declaration_accepted', $data)) {
            if ($data['declaration_accepted'] === true) {
                $data['declaration_accepted_at'] = now();
            }
            unset($data['declaration_accepted']);
        }

        if (isset($data['name'])) {
            $data['slug'] = Str::slug($data['name']).'-'.$m->id;
        }

        $m->update($data);

        return response()->json(['manufacturer' => $m->fresh()]);
    }
}
