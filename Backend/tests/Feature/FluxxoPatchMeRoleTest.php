<?php

namespace Tests\Feature;

use App\Models\Manufacturer;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FluxxoPatchMeRoleTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_with_unknown_role_can_claim_instructor(): void
    {
        $u = User::factory()->create(['role' => 'legacy_unknown']);

        Sanctum::actingAs($u);

        $this->patchJson('/api/me/role', [
            'role' => 'instructor',
        ])
            ->assertOk()
            ->assertJsonPath('role', 'instructor');

        $this->assertSame('instructor', $u->fresh()->role);
        $this->assertNull($u->fresh()->manufacturer_id);
    }

    public function test_user_with_trainee_role_cannot_patch_role(): void
    {
        $u = User::factory()->create(['role' => 'trainee']);

        Sanctum::actingAs($u);

        $this->patchJson('/api/me/role', [
            'role' => 'instructor',
        ])->assertStatus(403);

        $this->assertSame('trainee', $u->fresh()->role);
    }

    public function test_manufacturer_claim_requires_company_name_when_domain_is_new(): void
    {
        $u = User::factory()->create([
            'role' => '',
            'email' => 'admin@freshmfg-domain-test.example',
        ]);

        Sanctum::actingAs($u);

        $this->patchJson('/api/me/role', [
            'role' => 'manufacturer_admin',
        ])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['manufacturer_name']);

        $this->assertSame('', $u->fresh()->role);
    }

    public function test_manufacturer_claim_creates_manufacturer_when_name_provided(): void
    {
        $email = 'ceo@newwidgetcorp-test.example';
        $u = User::factory()->create([
            'role' => 'typo_role',
            'email' => $email,
        ]);

        Sanctum::actingAs($u);

        $this->patchJson('/api/me/role', [
            'role' => 'manufacturer_admin',
            'manufacturer_name' => 'New Widget Corp Test',
        ])
            ->assertOk()
            ->assertJsonPath('role', 'manufacturer_admin');

        $u = $u->fresh();
        $this->assertSame('manufacturer_admin', $u->role);
        $this->assertNotNull($u->manufacturer_id);

        $m = Manufacturer::query()->find($u->manufacturer_id);
        $this->assertNotNull($m);
        $this->assertSame('newwidgetcorp-test.example', $m->registration_email_domain);
    }
}
