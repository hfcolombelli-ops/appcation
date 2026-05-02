<?php

namespace Tests\Feature;

use App\Models\Institution;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FluxxoPatchMeInstitutionTest extends TestCase
{
    use RefreshDatabase;

    public function test_institution_admin_can_link_profile_to_institution(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Hospital Patch',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => null,
        ]);

        Sanctum::actingAs($admin);

        $this->patchJson('/api/me/institution', [
            'institution_id' => $inst->id,
        ])
            ->assertOk()
            ->assertJsonPath('institution_id', $inst->id);

        $this->assertSame($inst->id, $admin->fresh()->institution_id);
    }

    public function test_non_gestor_cannot_patch_institution(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Hospital X',
            'cnpj' => '98.765.432/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);

        Sanctum::actingAs($instructor);

        $this->patchJson('/api/me/institution', [
            'institution_id' => $inst->id,
        ])->assertStatus(403);
    }
}
