<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\GoogleIdTokenVerifier;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoGoogleAuthTriageTest extends TestCase
{
    use RefreshDatabase;

    public function test_google_register_without_role_creates_user_with_null_role(): void
    {
        Config::set('services.google.client_id', 'test-google-web-client');
        // E-mail normalizado em minúsculas no controller; SQLite compara strings com sensibilidade a maiúsculas.
        $email = strtolower('triage_'.Str::random(8).'@test.invalid');

        $this->mock(GoogleIdTokenVerifier::class, function ($mock) use ($email) {
            $mock->shouldReceive('verify')->once()->andReturn([
                'aud' => 'test-google-web-client',
                'sub' => 'google-sub-triage-1',
                'email' => $email,
                'name' => 'Triage',
                'email_verified' => true,
            ]);
        });

        $this->postJson('/api/auth/google', [
            'id_token' => 'fake-id-token',
        ])
            ->assertOk()
            ->assertJsonStructure(['token', 'user'])
            ->assertJsonPath('user.role', null)
            ->assertJsonPath('user.needs_profile_gate', true);

        $u = User::query()->where('email', $email)->firstOrFail();
        $this->assertNull($u->role);
        $this->assertSame('google-sub-triage-1', $u->google_sub);
        $this->assertNull($u->google_triage_completed_at);
    }
}
