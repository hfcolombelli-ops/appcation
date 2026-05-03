<?php

namespace Tests\Feature;

use App\Models\Enrollment;
use App\Models\Institution;
use App\Models\Manufacturer;
use App\Models\Training;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FluxxoSeasonLeaderboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_manufacturer_season_leaderboard_counts_finished_trainings(): void
    {
        $manufacturer = Manufacturer::query()->create([
            'name' => 'Fab Rank '.Str::random(6),
            'slug' => 'fab-rank-'.Str::lower(Str::random(6)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $manufacturer->id,
        ]);

        $inst = Institution::query()->create([
            'name' => 'Inst Rank',
            'cnpj' => '11.222.333/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);

        $tr = Training::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $manufacturer->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino fab',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
            'passing_score_percent' => 70,
        ]);

        Enrollment::query()->create([
            'training_id' => $tr->id,
            'user_id' => User::factory()->create(['role' => 'trainee'])->id,
            'status' => 'completed',
            'score' => 8.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $token = $admin->createToken('m')->plainTextToken;

        $res = $this->withToken($token)->postJson('/api/manufacturer/seasons', [
            'name' => '2026-S1',
            'starts_at' => now()->subMonth()->toDateString(),
            'ends_at' => now()->addMonth()->toDateString(),
            'target_trainings' => 100,
        ]);
        $res->assertCreated();
        $seasonId = (int) $res->json('id');

        $board = $this->withToken($token)->getJson("/api/manufacturer/seasons/{$seasonId}/leaderboard");
        $board->assertOk();
        $board->assertJsonPath('entries.0.instructor_id', $instructor->id);
        $board->assertJsonPath('entries.0.points', 1);
        $board->assertJsonPath('entries.0.rank', 1);

        Sanctum::actingAs($instructor);
        $this->getJson('/api/instructor/season-ranks')
            ->assertOk()
            ->assertJsonPath('0.points', 1);
    }

    public function test_manufacturer_seasons_index_search_filters_by_name_or_notes(): void
    {
        $manufacturer = Manufacturer::query()->create([
            'name' => 'Fab SeasonSearch '.Str::random(6),
            'slug' => 'fab-ss-'.Str::lower(Str::random(6)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $manufacturer->id,
        ]);

        $token = $admin->createToken('m')->plainTextToken;

        $this->withToken($token)->postJson('/api/manufacturer/seasons', [
            'name' => 'Época Verão',
            'starts_at' => now()->subMonth()->toDateString(),
            'ends_at' => now()->addMonth()->toDateString(),
            'notes' => 'primeira vaga',
        ])->assertCreated();

        $this->withToken($token)->postJson('/api/manufacturer/seasons', [
            'name' => 'Inverno',
            'starts_at' => now()->subMonths(2)->toDateString(),
            'ends_at' => now()->subMonth()->toDateString(),
            'notes' => null,
        ])->assertCreated();

        $this->withToken($token)
            ->getJson('/api/manufacturer/seasons?search=verão')
            ->assertOk()
            ->assertJsonCount(1, 'items')
            ->assertJsonFragment(['name' => 'Época Verão']);

        $this->withToken($token)
            ->getJson('/api/manufacturer/seasons?search=primeira')
            ->assertOk()
            ->assertJsonCount(1, 'items');
    }
}
