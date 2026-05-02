<?php

namespace Tests\Feature;

use App\Models\Equipment;
use App\Models\Manufacturer;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoEquipmentCategoriesTest extends TestCase
{
    use RefreshDatabase;

    /**
     * @return array{0: string, 1: Manufacturer}
     */
    protected function manufacturerTokenAndMfg(): array
    {
        $suffix = Str::lower(Str::random(8));
        $m = Manufacturer::query()->create([
            'name' => 'Mfg '.$suffix,
            'slug' => 'mfg-'.$suffix,
            'status' => 'active',
            'validation_status' => 'active',
        ]);
        $user = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $m->id,
        ]);

        return [$user->createToken('test')->plainTextToken, $m];
    }

    public function test_catalog_returns_categories(): void
    {
        [$token] = $this->manufacturerTokenAndMfg();

        $this->withToken($token)
            ->getJson('/api/catalog/equipment-categories')
            ->assertOk()
            ->assertJsonFragment(['id' => 'radiologia']);
    }

    public function test_store_and_filter_by_category(): void
    {
        [$token] = $this->manufacturerTokenAndMfg();

        $a = $this->withToken($token)->postJson('/api/manufacturer/equipment', [
            'name' => 'RX-1',
            'model' => 'M1',
            'category' => 'radiologia',
        ]);
        $a->assertCreated();

        $this->withToken($token)->postJson('/api/manufacturer/equipment', [
            'name' => 'UTI-1',
            'model' => 'M2',
            'category' => 'uti',
        ])->assertCreated();

        $this->withToken($token)
            ->getJson('/api/manufacturer/equipment?category=radiologia')
            ->assertOk()
            ->assertJsonCount(1);

        $this->withToken($token)
            ->getJson('/api/manufacturer/equipment?category=inexistente')
            ->assertStatus(422);
    }

    public function test_rejects_invalid_category_on_store(): void
    {
        [$token] = $this->manufacturerTokenAndMfg();

        $this->withToken($token)
            ->postJson('/api/manufacturer/equipment', [
                'name' => 'X',
                'model' => 'Y',
                'category' => 'não_listada',
            ])
            ->assertStatus(422);
    }

    public function test_can_clear_category_on_update(): void
    {
        [$token] = $this->manufacturerTokenAndMfg();

        $c = $this->withToken($token)->postJson('/api/manufacturer/equipment', [
            'name' => 'Z',
            'model' => 'Z1',
            'category' => 'laboratorio',
        ]);
        $c->assertCreated();
        $id = $c->json('id');

        $this->withToken($token)
            ->putJson('/api/manufacturer/equipment/'.$id, ['category' => null])
            ->assertOk();

        $this->assertNull(Equipment::query()->find($id)?->category);
    }
}
