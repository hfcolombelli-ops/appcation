<?php

namespace Tests\Feature;

use App\Models\Institution;
use App\Models\InstitutionInstructor;
use App\Models\Manufacturer;
use App\Models\ManufacturerInstructor;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FluxxoCredentialsTest extends TestCase
{
    use RefreshDatabase;

    public function test_instructor_applies_to_institution_and_gestor_approves(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Hospital Teste',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);

        Sanctum::actingAs($instructor);

        $this->postJson('/api/credentials/institution', ['institution_id' => $inst->id])
            ->assertCreated();

        $mine = $this->getJson('/api/credentials/me');
        $mine->assertOk();
        $mine->assertJsonCount(1, 'institutions');
        $this->assertSame('pending', $mine->json('institutions.0.status'));

        $admin = User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ]);

        Sanctum::actingAs($admin);

        $queue = $this->getJson('/api/credentials/institution/queue');
        $queue->assertOk();
        $queue->assertJsonCount(1);
        $rowId = $queue->json('0.id');

        $this->patchJson("/api/credentials/institution/{$rowId}", ['status' => 'approved'])
            ->assertOk()
            ->assertJsonPath('status', 'approved');

        $this->assertDatabaseHas('security_audit_logs', [
            'user_id' => $admin->id,
            'action' => 'credential.institution_decide',
            'subject_type' => InstitutionInstructor::class,
            'subject_id' => $rowId,
        ]);
    }

    public function test_instructor_applies_to_manufacturer_and_fabricante_approves(): void
    {
        $suffix = Str::lower(Str::random(6));
        $mfg = Manufacturer::query()->create([
            'name' => 'Fab '.$suffix,
            'slug' => 'fab-'.$suffix,
            'status' => 'active',
            'validation_status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);

        Sanctum::actingAs($instructor);

        $this->postJson('/api/credentials/manufacturer', ['manufacturer_id' => $mfg->id])
            ->assertCreated();

        $mine = $this->getJson('/api/credentials/me');
        $mine->assertOk();
        $mine->assertJsonCount(1, 'manufacturers');

        $mAdmin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $mfg->id,
        ]);

        Sanctum::actingAs($mAdmin);

        $queue = $this->getJson('/api/credentials/manufacturer/queue');
        $queue->assertOk();
        $queue->assertJsonCount(1);
        $rowId = $queue->json('0.id');

        $this->patchJson("/api/credentials/manufacturer/{$rowId}", [
            'status' => 'approved',
            'fee_paid' => true,
        ])
            ->assertOk()
            ->assertJsonPath('status', 'approved')
            ->assertJsonPath('fee_paid', true);
    }

    public function test_gestor_endorses_manufacturer_request_for_approved_instructor(): void
    {
        $suffix = Str::lower(Str::random(6));
        $inst = Institution::query()->create([
            'name' => 'Inst '.$suffix,
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $mfg = Manufacturer::query()->create([
            'name' => 'Fab '.$suffix,
            'slug' => 'fab-'.$suffix,
            'status' => 'active',
            'validation_status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);

        InstitutionInstructor::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'status' => 'approved',
        ]);

        $mi = ManufacturerInstructor::query()->create([
            'manufacturer_id' => $mfg->id,
            'instructor_id' => $instructor->id,
            'status' => 'pending',
        ]);

        $admin = User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ]);

        Sanctum::actingAs($admin);

        $queue = $this->getJson('/api/institution/manufacturer-endorsement-queue');
        $queue->assertOk();
        $queue->assertJsonCount(1);
        $this->assertSame($mi->id, $queue->json('0.id'));

        $this->postJson("/api/institution/manufacturer-endorsements/{$mi->id}/endorse")
            ->assertOk()
            ->assertJsonPath('endorsed_by_institution_id', $inst->id);

        $this->assertNotNull($mi->fresh()->endorsed_at);

        $empty = $this->getJson('/api/institution/manufacturer-endorsement-queue');
        $empty->assertOk();
        $empty->assertJsonCount(0);
    }

    public function test_other_institution_gestor_cannot_endorse(): void
    {
        $suffix = Str::lower(Str::random(6));
        $instA = Institution::query()->create([
            'name' => 'Inst A '.$suffix,
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);
        $instB = Institution::query()->create([
            'name' => 'Inst B '.$suffix,
            'cnpj' => '12.345.679/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $mfg = Manufacturer::query()->create([
            'name' => 'Fab '.$suffix,
            'slug' => 'fab-'.$suffix,
            'status' => 'active',
            'validation_status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);

        InstitutionInstructor::query()->create([
            'institution_id' => $instA->id,
            'instructor_id' => $instructor->id,
            'status' => 'approved',
        ]);

        $mi = ManufacturerInstructor::query()->create([
            'manufacturer_id' => $mfg->id,
            'instructor_id' => $instructor->id,
            'status' => 'pending',
        ]);

        $gestorB = User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => $instB->id,
        ]);

        Sanctum::actingAs($gestorB);

        $this->postJson("/api/institution/manufacturer-endorsements/{$mi->id}/endorse")
            ->assertNotFound();
    }

    public function test_manufacturer_cannot_approve_without_institution_endorsement_when_instructor_is_institution_linked(): void
    {
        $suffix = Str::lower(Str::random(6));
        $inst = Institution::query()->create([
            'name' => 'Inst '.$suffix,
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $mfg = Manufacturer::query()->create([
            'name' => 'Fab '.$suffix,
            'slug' => 'fab-'.$suffix,
            'status' => 'active',
            'validation_status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);

        InstitutionInstructor::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'status' => 'approved',
        ]);

        $mi = ManufacturerInstructor::query()->create([
            'manufacturer_id' => $mfg->id,
            'instructor_id' => $instructor->id,
            'status' => 'pending',
        ]);

        $mAdmin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $mfg->id,
        ]);

        Sanctum::actingAs($mAdmin);

        $this->patchJson("/api/credentials/manufacturer/{$mi->id}", [
            'status' => 'approved',
            'fee_paid' => true,
        ])
            ->assertStatus(422);

        $gestor = User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ]);
        Sanctum::actingAs($gestor);
        $this->postJson("/api/institution/manufacturer-endorsements/{$mi->id}/endorse")
            ->assertOk();

        Sanctum::actingAs($mAdmin);
        $this->patchJson("/api/credentials/manufacturer/{$mi->id}", [
            'status' => 'approved',
            'fee_paid' => true,
        ])
            ->assertOk()
            ->assertJsonPath('status', 'approved');
    }
}
