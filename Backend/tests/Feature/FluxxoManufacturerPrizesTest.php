<?php

namespace Tests\Feature;

use App\Models\Manufacturer;
use App\Models\ManufacturerPrize;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoManufacturerPrizesTest extends TestCase
{
    use RefreshDatabase;

    public function test_manufacturer_crud_and_public_catalog(): void
    {
        $manufacturer = Manufacturer::query()->create([
            'name' => 'Fab Prémios '.Str::random(4),
            'slug' => 'fab-prizes-'.Str::lower(Str::random(4)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $manufacturer->id,
        ]);

        $token = $admin->createToken('m')->plainTextToken;

        $create = $this->withToken($token)->postJson('/api/manufacturer/prizes', [
            'title' => 'Destaque trimestral',
            'description' => 'Reconhecimento interno — sem valor monetário no MVP.',
            'sort_order' => 1,
        ]);
        $create->assertCreated();
        $id = (int) $create->json('id');

        $this->getJson('/api/public/manufacturer-prizes?manufacturer_id='.$manufacturer->id)
            ->assertOk()
            ->assertJsonPath('0.title', 'Destaque trimestral');

        $this->withToken($token)->patchJson("/api/manufacturer/prizes/{$id}", [
            'title' => 'Destaque trimestral (atualizado)',
        ])->assertOk();

        $this->withToken($token)->deleteJson("/api/manufacturer/prizes/{$id}")->assertOk();
        $this->assertSame(0, ManufacturerPrize::query()->count());
    }

    public function test_prizes_index_search_filters_title_and_description(): void
    {
        $manufacturer = Manufacturer::query()->create([
            'name' => 'Fab Search '.Str::random(4),
            'slug' => 'fab-search-'.Str::lower(Str::random(4)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $manufacturer->id,
        ]);

        $token = $admin->createToken('m')->plainTextToken;

        $this->withToken($token)->postJson('/api/manufacturer/prizes', [
            'title' => 'Prémio Alpha',
            'description' => 'Descrição comum',
        ])->assertCreated();

        $this->withToken($token)->postJson('/api/manufacturer/prizes', [
            'title' => 'Outro título',
            'description' => 'Texto beta aqui',
        ])->assertCreated();

        $this->withToken($token)
            ->getJson('/api/manufacturer/prizes?search=alpha')
            ->assertOk()
            ->assertJsonCount(1, 'items')
            ->assertJsonFragment(['title' => 'Prémio Alpha']);

        $this->withToken($token)
            ->getJson('/api/manufacturer/prizes?search=beta')
            ->assertOk()
            ->assertJsonCount(1, 'items');
    }
}
