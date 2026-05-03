<?php

namespace App\Http\Controllers\Api\Concerns;

use App\Models\Manufacturer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

trait RequiresManufacturerApproved
{
    protected function ensureManufacturerApproved(Request $request): ?JsonResponse
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return null;
        }

        $m = Manufacturer::query()->find($user->manufacturer_id);
        if ($m === null || $m->validation_status !== 'active') {
            return response()->json([
                'message' => 'Esta acção fica disponível após a homologação do seu cadastro de fabricante.',
                'code' => 'manufacturer_not_validated',
            ], 403);
        }

        return null;
    }
}
