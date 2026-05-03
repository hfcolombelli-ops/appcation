<?php

namespace Tests\Feature;

use App\Models\Equipment;
use App\Models\Institution;
use App\Models\InstitutionInstructor;
use App\Models\Manufacturer;
use App\Models\TraineeProfile;
use App\Models\Training;
use App\Models\TrainingRequest;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoTrainingRequestFieldsTest extends TestCase
{
    use RefreshDatabase;

    public function test_trainee_creates_request_with_reason_priority_and_dates(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Hosp Teste',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $trainee = User::factory()->create(['role' => 'trainee']);
        $token = $trainee->createToken('t')->plainTextToken;

        $res = $this->withToken($token)
            ->postJson('/api/training-requests', [
                'institution_id' => $inst->id,
                'reason_code' => 'recertification',
                'priority' => 'high',
                'desired_date' => '2026-08-01',
                'latest_acceptable_date' => '2026-08-20',
                'notes' => 'Sala 2',
            ]);

        $res->assertCreated();
        $this->assertSame('recertification', $res->json('reason_code'));
        $this->assertSame('high', $res->json('priority'));
        $this->assertArrayHasKey('reason_label', $res->json());
        $this->assertArrayHasKey('priority_label', $res->json());
    }

    public function test_rejects_missing_reason_code(): void
    {
        $inst = Institution::query()->create([
            'name' => 'H2',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $trainee = User::factory()->create(['role' => 'trainee']);
        $token = $trainee->createToken('t')->plainTextToken;

        $this->withToken($token)
            ->postJson('/api/training-requests', [
                'institution_id' => $inst->id,
            ])
            ->assertStatus(422);
    }

    public function test_catalog_options_endpoint(): void
    {
        $u = User::factory()->create(['role' => 'trainee']);
        $token = $u->createToken('t')->plainTextToken;

        $this->withToken($token)
            ->getJson('/api/catalog/training-request-options')
            ->assertOk()
            ->assertJsonStructure(['reason_codes', 'priorities']);
    }

    public function test_rejects_equipment_not_in_institution_park(): void
    {
        $instA = Institution::query()->create([
            'name' => 'H A',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);
        $instB = Institution::query()->create([
            'name' => 'H B',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $m = Manufacturer::query()->create([
            'name' => 'Fab '.Str::lower(Str::random(6)),
            'slug' => 'fab-'.Str::lower(Str::random(6)),
            'status' => 'active',
            'validation_status' => 'active',
        ]);

        $catalog = Equipment::query()->create([
            'institution_id' => null,
            'manufacturer_id' => $m->id,
            'name' => 'Cat',
            'model' => 'C-1',
            'quantity' => 1,
            'status' => 'active',
        ]);

        $parkB = Equipment::query()->create([
            'institution_id' => $instB->id,
            'manufacturer_id' => $m->id,
            'catalog_equipment_id' => $catalog->id,
            'name' => $catalog->name,
            'model' => $catalog->model,
            'quantity' => 1,
            'status' => 'pending',
        ]);

        $trainee = User::factory()->create(['role' => 'trainee']);
        $token = $trainee->createToken('t')->plainTextToken;

        $this->withToken($token)
            ->postJson('/api/training-requests', [
                'institution_id' => $instA->id,
                'reason_code' => 'new_equipment',
                'equipment_id' => $parkB->id,
            ])
            ->assertStatus(422);
    }

    public function test_accepts_equipment_from_same_institution_park(): void
    {
        $inst = Institution::query()->create([
            'name' => 'H Parque',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $m = Manufacturer::query()->create([
            'name' => 'Fab '.Str::lower(Str::random(6)),
            'slug' => 'fab-'.Str::lower(Str::random(6)),
            'status' => 'active',
            'validation_status' => 'active',
        ]);

        $catalog = Equipment::query()->create([
            'institution_id' => null,
            'manufacturer_id' => $m->id,
            'name' => 'Vent',
            'model' => 'V-1',
            'quantity' => 1,
            'status' => 'active',
        ]);

        $park = Equipment::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $m->id,
            'catalog_equipment_id' => $catalog->id,
            'name' => $catalog->name,
            'model' => $catalog->model,
            'quantity' => 1,
            'status' => 'pending',
        ]);

        $trainee = User::factory()->create(['role' => 'trainee']);
        $token = $trainee->createToken('t')->plainTextToken;

        $res = $this->withToken($token)
            ->postJson('/api/training-requests', [
                'institution_id' => $inst->id,
                'reason_code' => 'new_equipment',
                'equipment_id' => $park->id,
            ]);

        $res->assertCreated();
        $this->assertSame($park->id, (int) $res->json('equipment_id'));
        $this->assertSame('Vent', $res->json('equipment.name'));
    }

    public function test_trainee_lists_park_when_profile_has_institution(): void
    {
        $inst = Institution::query()->create([
            'name' => 'H Lista',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $m = Manufacturer::query()->create([
            'name' => 'Fab '.Str::lower(Str::random(6)),
            'slug' => 'fab-'.Str::lower(Str::random(6)),
            'status' => 'active',
            'validation_status' => 'active',
        ]);

        $catalog = Equipment::query()->create([
            'institution_id' => null,
            'manufacturer_id' => $m->id,
            'name' => 'Lista X',
            'model' => 'LX',
            'quantity' => 1,
            'status' => 'active',
        ]);

        Equipment::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $m->id,
            'catalog_equipment_id' => $catalog->id,
            'name' => $catalog->name,
            'model' => $catalog->model,
            'quantity' => 1,
            'status' => 'active',
        ]);

        $trainee = User::factory()->create(['role' => 'trainee']);
        TraineeProfile::query()->updateOrCreate(
            ['user_id' => $trainee->id],
            ['institution_id' => $inst->id, 'sector' => 'UCI'],
        );
        $token = $trainee->createToken('t')->plainTextToken;

        $this->withToken($token)
            ->getJson('/api/me/institution-park-equipment')
            ->assertOk()
            ->assertJsonCount(1)
            ->assertJsonFragment(['model' => 'LX']);
    }

    public function test_trainee_park_422_without_institution_on_profile(): void
    {
        $trainee = User::factory()->create(['role' => 'trainee']);
        $token = $trainee->createToken('t')->plainTextToken;

        $this->withToken($token)
            ->getJson('/api/me/institution-park-equipment')
            ->assertStatus(422);
    }

    public function test_institution_cannot_set_scheduled_without_instructor(): void
    {
        $inst = Institution::query()->create([
            'name' => 'H Sched',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ]);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $req = TrainingRequest::query()->create([
            'institution_id' => $inst->id,
            'requested_by' => $trainee->id,
            'reason_code' => 'recertification',
            'priority' => 'normal',
            'status' => 'approved',
        ]);

        $token = $admin->createToken('a')->plainTextToken;

        $this->withToken($token)->patchJson("/api/institution/training-requests/{$req->id}", [
            'status' => 'scheduled',
        ])->assertUnprocessable();
    }

    public function test_institution_can_set_scheduled_with_instructor(): void
    {
        $inst = Institution::query()->create([
            'name' => 'H Sched OK',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ]);
        $trainee = User::factory()->create(['role' => 'trainee']);
        $instructor = User::factory()->create(['role' => 'instructor']);

        InstitutionInstructor::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'status' => 'approved',
        ]);

        $req = TrainingRequest::query()->create([
            'institution_id' => $inst->id,
            'requested_by' => $trainee->id,
            'reason_code' => 'recertification',
            'priority' => 'normal',
            'status' => 'approved',
        ]);

        $token = $admin->createToken('a')->plainTextToken;

        $this->withToken($token)->patchJson("/api/institution/training-requests/{$req->id}", [
            'status' => 'scheduled',
            'assigned_instructor_id' => $instructor->id,
        ])->assertOk()->assertJsonPath('status', 'scheduled');
    }

    public function test_institution_cannot_set_fulfilled_without_training(): void
    {
        $inst = Institution::query()->create([
            'name' => 'H Ful',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ]);
        $trainee = User::factory()->create(['role' => 'trainee']);
        $instructor = User::factory()->create(['role' => 'instructor']);

        InstitutionInstructor::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'status' => 'approved',
        ]);

        $req = TrainingRequest::query()->create([
            'institution_id' => $inst->id,
            'requested_by' => $trainee->id,
            'reason_code' => 'recertification',
            'priority' => 'normal',
            'status' => 'scheduled',
            'assigned_instructor_id' => $instructor->id,
        ]);

        $token = $admin->createToken('a')->plainTextToken;

        $this->withToken($token)->patchJson("/api/institution/training-requests/{$req->id}", [
            'status' => 'fulfilled',
        ])->assertUnprocessable();
    }

    public function test_institution_can_set_fulfilled_with_training(): void
    {
        $inst = Institution::query()->create([
            'name' => 'H Ful OK',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ]);
        $trainee = User::factory()->create(['role' => 'trainee']);
        $instructor = User::factory()->create(['role' => 'instructor']);

        InstitutionInstructor::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'status' => 'approved',
        ]);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino vinculado',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);

        $req = TrainingRequest::query()->create([
            'institution_id' => $inst->id,
            'requested_by' => $trainee->id,
            'reason_code' => 'recertification',
            'priority' => 'normal',
            'status' => 'scheduled',
            'assigned_instructor_id' => $instructor->id,
        ]);

        $token = $admin->createToken('a')->plainTextToken;

        $this->withToken($token)->patchJson("/api/institution/training-requests/{$req->id}", [
            'status' => 'fulfilled',
            'fulfilled_training_id' => $training->id,
        ])->assertOk()->assertJsonPath('status', 'fulfilled');
    }
}
