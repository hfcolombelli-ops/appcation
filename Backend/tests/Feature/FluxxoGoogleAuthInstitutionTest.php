<?php

namespace Tests\Feature;

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

    public function test_google_institution_admin_role_is_not_accepted(): void
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
            ->assertJsonValidationErrors(['role']);
    }
}
