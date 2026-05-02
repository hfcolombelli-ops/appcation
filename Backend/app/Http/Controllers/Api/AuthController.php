<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Manufacturer;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:190', 'unique:users,email'],
            'password' => ['required', Password::min(8)],
            'role' => ['required', 'in:trainee,instructor,institution_admin,manufacturer_admin'],
            'phone' => ['nullable', 'string', 'max:25'],
            'manufacturer_name' => ['required_if:role,manufacturer_admin', 'string', 'max:180'],
            'manufacturer_cnpj' => ['nullable', 'string', 'max:20'],
        ]);

        $manufacturerId = null;

        if ($data['role'] === 'manufacturer_admin') {
            $manufacturer = Manufacturer::create([
                'name' => $data['manufacturer_name'],
                'slug' => Str::slug($data['manufacturer_name']).'-'.Str::lower(Str::random(8)),
                'cnpj' => $data['manufacturer_cnpj'] ?? null,
                'support_email' => $data['email'],
                'status' => 'active',
            ]);
            $manufacturerId = $manufacturer->id;
        }

        unset($data['manufacturer_name'], $data['manufacturer_cnpj']);

        $user = User::create(array_merge($data, ['manufacturer_id' => $manufacturerId]));

        return response()->json([
            'token' => $user->createToken('web')->plainTextToken,
            'user' => $user,
        ], 201);
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('email', $credentials['email'])->first();

        if (! $user || $user->password === null || ! Hash::check($credentials['password'], $user->password)) {
            return response()->json(['message' => 'Credenciais inválidas.'], 422);
        }

        return response()->json([
            'token' => $user->createToken('web')->plainTextToken,
            'user' => $user,
        ]);
    }

    public function me(Request $request)
    {
        return response()->json($request->user());
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json(['message' => 'Sessão encerrada com sucesso.']);
    }
}
