<?php

namespace Tests\Feature;

use App\Models\Equipment;
use App\Models\Manufacturer;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoManufacturerEquipmentVersionTest extends TestCase
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

    public function test_create_new_version_links_parent_and_allows_update_on_leaf(): void
    {
        [$token, $m] = $this->manufacturerTokenAndMfg();

        $v1 = $this->withToken($token)->postJson('/api/manufacturer/equipment', [
            'name' => 'Ventilador X',
            'model' => 'VX-100',
            'category' => 'ventilacao_pulmonar',
        ]);
        $v1->assertCreated();
        $id1 = $v1->json('id');

        $v2 = $this->withToken($token)->postJson('/api/manufacturer/equipment', [
            'name' => 'Ventilador X',
            'model' => 'VX-200',
            'parent_equipment_id' => $id1,
        ]);
        $v2->assertCreated();
        $this->assertSame((int) $id1, (int) $v2->json('parent_equipment_id'));

        $this->withToken($token)
            ->putJson('/api/manufacturer/equipment/'.$v2->json('id'), [
                'sector' => 'UCI',
            ])
            ->assertOk();
    }

    public function test_cannot_update_equipment_with_child_versions(): void
    {
        [$token] = $this->manufacturerTokenAndMfg();

        $v1 = $this->withToken($token)->postJson('/api/manufacturer/equipment', [
            'name' => 'Bomba Y',
            'model' => 'BY-1',
            'category' => 'bomba_infusao',
        ]);
        $id1 = $v1->json('id');

        $this->withToken($token)->postJson('/api/manufacturer/equipment', [
            'name' => 'Bomba Y',
            'model' => 'BY-2',
            'parent_equipment_id' => $id1,
        ])->assertCreated();

        $this->withToken($token)
            ->putJson('/api/manufacturer/equipment/'.$id1, ['name' => 'Alterado'])
            ->assertStatus(422);
    }

    public function test_cannot_delete_parent_with_child_versions(): void
    {
        [$token] = $this->manufacturerTokenAndMfg();

        $v1 = $this->withToken($token)->postJson('/api/manufacturer/equipment', [
            'name' => 'Monitor Z',
            'model' => 'MZ-1',
            'category' => 'monitorizacao',
        ]);
        $id1 = $v1->json('id');

        $this->withToken($token)->postJson('/api/manufacturer/equipment', [
            'name' => 'Monitor Z',
            'model' => 'MZ-2',
            'parent_equipment_id' => $id1,
        ])->assertCreated();

        $this->withToken($token)
            ->delete('/api/manufacturer/equipment/'.$id1)
            ->assertStatus(422);
    }

    public function test_rejects_parent_from_other_manufacturer(): void
    {
        [, $mA] = $this->manufacturerTokenAndMfg();
        [$tokenB, $mB] = $this->manufacturerTokenAndMfg();
        $this->assertNotSame($mA->id, $mB->id);

        $foreign = Equipment::query()->create([
            'manufacturer_id' => $mA->id,
            'institution_id' => null,
            'name' => 'Equip A',
            'model' => 'A-1',
            'category' => 'outro',
            'quantity' => 1,
            'status' => 'active',
        ]);

        $this->withToken($tokenB)
            ->postJson('/api/manufacturer/equipment', [
                'name' => 'Tentativa',
                'model' => 'T-1',
                'parent_equipment_id' => $foreign->id,
            ])
            ->assertStatus(422);
    }
}
