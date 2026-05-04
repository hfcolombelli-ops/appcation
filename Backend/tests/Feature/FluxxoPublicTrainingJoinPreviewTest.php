<?php

namespace Tests\Feature;

use App\Models\Institution;
use App\Models\Training;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FluxxoPublicTrainingJoinPreviewTest extends TestCase
{
    use RefreshDatabase;

    public function test_join_preview_returns_minimal_metadata(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Hospital Público',
            'cnpj' => '11222333000199',
            'status' => 'active',
        ]);

        $instr = User::factory()->create(['role' => 'instructor']);

        $t = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instr->id,
            'title' => 'Treino Demo',
            'type' => 'session',
            'status' => 'scheduled',
            'join_hash' => 'abc-demo-hash',
        ]);

        $this->getJson('/api/public/trainings/join-preview/abc-demo-hash')
            ->assertOk()
            ->assertJsonPath('title', 'Treino Demo')
            ->assertJsonPath('institution_name', 'Hospital Público');
    }

    public function test_join_preview_404_for_unknown_hash(): void
    {
        $this->getJson('/api/public/trainings/join-preview/unknown')->assertNotFound();
    }
}
