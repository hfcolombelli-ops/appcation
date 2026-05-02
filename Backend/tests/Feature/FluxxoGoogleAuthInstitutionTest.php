<?php

namespace Tests\Feature;

use App\Models\Institution;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoGoogleAuthInstitutionTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Config::set('services.google.client_id', 'test-google-web-client');
    }

    public function test_google_new_institution_admin_without_institution_id_returns_422(): void
    {
        Http::fake(fn () => Http::response([
            'aud' => 'test-google-web-client',
            'sub' => 'google-sub-'.Str::random(10),
            'email' => 'novo_gestor_'.Str::random(6).'@test.invalid',
            'name' => 'Gestor',
        ], 200));

        $this->postJson('/api/auth/google', [
            'id_token' => 'fake-id-token',
            'role' => 'institution_admin',
        ])
            ->assertStatus(422)
            ->assertJsonFragment([
                'message' => 'Selecione a instituição para o perfil gestor institucional.',
            ]);
    }

    public function test_google_new_institution_admin_persists_institution_id(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Hospital Google',
            'cnpj' => '11.222.333/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $email = 'gestor_ok_'.Str::random(8).'@test.invalid';

        Http::fake(function () use ($email) {
            return Http::response([
                'aud' => 'test-google-web-client',
                'sub' => 'google-sub-'.Str::random(12),
                'email' => $email,
                'name' => 'Gestor OK',
            ], 200);
        });

        $this->postJson('/api/auth/google', [
            'id_token' => 'fake-id-token',
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ])->assertOk()
            ->assertJsonStructure(['token', 'user']);

        $user = User::query()->where('email', strtolower($email))->first();
        $this->assertNotNull($user);
        $this->assertSame('institution_admin', $user->role);
        $this->assertSame($inst->id, $user->institution_id);
    }
}
