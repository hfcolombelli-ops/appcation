<?php

namespace Tests\Feature;

use App\Models\Institution;
use App\Models\Training;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FluxxoPublicTraineeRegisterAndJoinTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_and_join_creates_trainee_and_enrollment(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Hospital X',
            'cnpj' => '22333444000155',
            'status' => 'active',
        ]);

        $instr = User::factory()->create(['role' => 'instructor']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instr->id,
            'title' => 'Treino Público',
            'type' => 'session',
            'status' => 'scheduled',
            'join_hash' => 'public-join-hash-1',
        ]);

        $res = $this->postJson('/api/public/trainings/register-and-join', [
            'join_hash' => 'public-join-hash-1',
            'name' => 'Maria Trainee',
            'email' => 'maria.trainee@example.com',
            'password' => 'Password1!',
            'password_confirmation' => 'Password1!',
        ]);

        $res->assertCreated()
            ->assertJsonStructure(['token', 'user', 'training']);

        $this->assertDatabaseHas('users', [
            'email' => 'maria.trainee@example.com',
            'role' => 'trainee',
        ]);

        $u = User::query()->where('email', 'maria.trainee@example.com')->first();
        $this->assertNotNull($u);
        $this->assertDatabaseHas('enrollments', [
            'training_id' => $training->id,
            'user_id' => $u->id,
        ]);
    }

    public function test_register_and_join_rejects_draft_training(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Hospital Y',
            'cnpj' => '33444555000166',
            'status' => 'active',
        ]);

        $instr = User::factory()->create(['role' => 'instructor']);

        Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instr->id,
            'title' => 'Rascunho',
            'type' => 'session',
            'status' => 'draft',
            'join_hash' => 'draft-hash',
        ]);

        $this->postJson('/api/public/trainings/register-and-join', [
            'join_hash' => 'draft-hash',
            'name' => 'João',
            'email' => 'joao@example.com',
            'password' => 'Password1!',
            'password_confirmation' => 'Password1!',
        ])->assertStatus(422);
    }
}
