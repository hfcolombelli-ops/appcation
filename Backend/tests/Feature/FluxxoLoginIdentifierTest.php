<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FluxxoLoginIdentifierTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_accepts_identifier_instead_of_email(): void
    {
        $user = User::factory()->create([
            'email' => 'urs_login_test@example.com',
            'password' => bcrypt('secret123'),
        ]);

        $this->postJson('/api/auth/login', [
            'identifier' => 'urs_login_test@example.com',
            'password' => 'secret123',
        ])
            ->assertOk()
            ->assertJsonStructure(['token', 'user']);

        $this->postJson('/api/auth/login', [
            'email' => 'urs_login_test@example.com',
            'password' => 'secret123',
        ])
            ->assertOk();
    }

    public function test_login_rejects_non_email_identifier(): void
    {
        User::factory()->create([
            'email' => 'only@email.com',
            'password' => bcrypt('secret123'),
        ]);

        $this->postJson('/api/auth/login', [
            'identifier' => '52998224725',
            'password' => 'secret123',
        ])
            ->assertStatus(422);
    }
}
