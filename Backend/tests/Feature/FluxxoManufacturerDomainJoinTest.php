<?php

namespace Tests\Feature;

use App\Models\Manufacturer;
use App\Models\User;
use App\Services\GoogleIdTokenVerifier;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoManufacturerDomainJoinTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_second_admin_same_domain_links_existing_manufacturer(): void
    {
        $domain = 'corp-domain-'.Str::lower(Str::random(6)).'.test';

        $first = Manufacturer::query()->create([
            'name' => 'Fab Primeiro',
            'slug' => 'fab-primeiro-'.Str::lower(Str::random(6)),
            'support_email' => 'admin@'.$domain,
            'registration_email_domain' => $domain,
            'status' => 'active',
            'validation_status' => 'pending_info',
        ]);

        $this->postJson('/api/auth/register', [
            'name' => 'Segundo Admin',
            'email' => 'outro@'.$domain,
            'password' => 'password12345',
            'role' => 'manufacturer_admin',
        ])
            ->assertCreated();

        $second = User::query()->where('email', 'outro@'.$domain)->firstOrFail();
        $this->assertSame((int) $first->id, (int) $second->manufacturer_id);
    }

    public function test_register_first_admin_without_company_name_fails(): void
    {
        $domain = 'new-domain-'.Str::lower(Str::random(6)).'.test';

        $this->postJson('/api/auth/register', [
            'name' => 'Primeiro Admin',
            'email' => 'primeiro@'.$domain,
            'password' => 'password12345',
            'role' => 'manufacturer_admin',
        ])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['manufacturer_name']);
    }

    public function test_google_second_user_same_domain_links_existing_manufacturer(): void
    {
        Config::set('services.google.client_id', 'test-google-web-client');

        $domain = 'gjoin-'.Str::lower(Str::random(8)).'.test';

        $m = Manufacturer::query()->create([
            'name' => 'Fab Base',
            'slug' => 'fab-base-'.Str::lower(Str::random(6)),
            'support_email' => 'first@'.$domain,
            'registration_email_domain' => $domain,
            'validation_status' => 'pending_info',
        ]);

        $secondEmail = 'second@'.$domain;

        $this->mock(GoogleIdTokenVerifier::class, function ($mock) use ($secondEmail) {
            $mock->shouldReceive('verify')->once()->andReturn([
                'aud' => 'test-google-web-client',
                'sub' => 'google-sub-'.Str::random(12),
                'email' => $secondEmail,
                'name' => 'Second',
                'email_verified' => true,
            ]);
        });

        $this->postJson('/api/auth/google', [
            'id_token' => 'fake-token',
            'role' => 'manufacturer_admin',
        ])
            ->assertOk();

        $u = User::query()->where('email', $secondEmail)->firstOrFail();
        $this->assertSame((int) $m->id, (int) $u->manufacturer_id);
    }
}
