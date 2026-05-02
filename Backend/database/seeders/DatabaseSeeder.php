<?php

namespace Database\Seeders;

use App\Models\Institution;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        Institution::query()->updateOrCreate(
            ['cnpj' => '00000000000191'],
            [
                'name' => 'Instituição Demo Appcation',
                'legal_name' => 'Instituição Demo Appcation LTDA',
                'email' => 'contato@appcation.local',
                'phone' => '11999999999',
                'city' => 'São Paulo',
                'state' => 'SP',
                'status' => 'active',
            ],
        );

        User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'role' => 'trainee',
        ]);

        User::query()->updateOrCreate(
            ['email' => 'instrutor@appcation.local'],
            [
                'name' => 'Instrutor Demo',
                'password' => 'password',
                'role' => 'instructor',
            ],
        );
    }
}
