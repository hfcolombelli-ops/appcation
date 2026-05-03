<?php

namespace Tests\Feature;

use App\Models\Equipment;
use App\Models\Institution;
use App\Models\Manufacturer;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoInstitutionEquipmentParkTest extends TestCase
{
    use RefreshDatabase;

    /**
     * @return array{0: string, 1: Institution, 2: Equipment}
     */
    protected function gestorWithCatalogTemplate(): array
    {
        $inst = Institution::query()->create([
            'name' => 'Hospital Parque',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $suffix = Str::lower(Str::random(6));
        $m = Manufacturer::query()->create([
            'name' => 'Fab '.$suffix,
            'slug' => 'fab-'.$suffix,
            'status' => 'active',
            'validation_status' => 'active',
        ]);

        $catalog = Equipment::query()->create([
            'institution_id' => null,
            'manufacturer_id' => $m->id,
            'name' => 'Ventilador Flux',
            'model' => 'VF-9',
            'sector' => null,
            'category' => 'uti',
            'quantity' => 1,
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ]);

        return [$admin->createToken('t')->plainTextToken, $inst, $catalog];
    }

    public function test_gestor_lists_templates_and_creates_park_unit(): void
    {
        [$token, $inst, $catalog] = $this->gestorWithCatalogTemplate();

        $this->withToken($token)
            ->getJson('/api/institution/equipment-templates')
            ->assertOk()
            ->assertJsonFragment(['id' => $catalog->id]);

        $c = $this->withToken($token)->postJson('/api/institution/equipment', [
            'catalog_equipment_id' => $catalog->id,
            'sector' => 'UCI A',
        ]);
        $c->assertCreated();
        $this->assertSame($inst->id, (int) $c->json('institution_id'));
        $this->assertSame($catalog->id, (int) $c->json('catalog_equipment_id'));
        $this->assertSame('pending', $c->json('status'));

        $this->withToken($token)
            ->getJson('/api/institution/equipment')
            ->assertOk()
            ->assertJsonCount(1);
    }

    public function test_gestor_can_activate_and_filter_by_status(): void
    {
        [$token, , $catalog] = $this->gestorWithCatalogTemplate();

        $create = $this->withToken($token)->postJson('/api/institution/equipment', [
            'catalog_equipment_id' => $catalog->id,
        ]);
        $create->assertCreated();
        $id = $create->json('id');

        $this->withToken($token)
            ->putJson('/api/institution/equipment/'.$id, ['status' => 'active'])
            ->assertOk()
            ->assertJsonPath('status', 'active');

        $this->withToken($token)
            ->getJson('/api/institution/equipment?status=pending')
            ->assertOk()
            ->assertJsonCount(0);

        $this->withToken($token)
            ->getJson('/api/institution/equipment?status=active')
            ->assertOk()
            ->assertJsonCount(1);
    }

    public function test_gestor_filters_templates_and_park_by_category(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Hospital Filtro',
            'cnpj' => '98.765.432/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $suffix = Str::lower(Str::random(6));
        $m = Manufacturer::query()->create([
            'name' => 'Fab '.$suffix,
            'slug' => 'fab-'.$suffix,
            'status' => 'active',
            'validation_status' => 'active',
        ]);

        $catUti = Equipment::query()->create([
            'institution_id' => null,
            'manufacturer_id' => $m->id,
            'name' => 'Vent UTI',
            'model' => 'V-1',
            'category' => 'uti',
            'quantity' => 1,
            'status' => 'active',
        ]);

        $catRad = Equipment::query()->create([
            'institution_id' => null,
            'manufacturer_id' => $m->id,
            'name' => 'RX Sala',
            'model' => 'R-1',
            'category' => 'radiologia',
            'quantity' => 1,
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ]);
        $token = $admin->createToken('t')->plainTextToken;

        $this->withToken($token)
            ->getJson('/api/institution/equipment-templates?category=uti')
            ->assertOk()
            ->assertJsonCount(1)
            ->assertJsonFragment(['id' => $catUti->id]);

        $this->withToken($token)
            ->postJson('/api/institution/equipment', [
                'catalog_equipment_id' => $catUti->id,
            ])
            ->assertCreated();

        $this->withToken($token)
            ->postJson('/api/institution/equipment', [
                'catalog_equipment_id' => $catRad->id,
            ])
            ->assertCreated();

        $this->withToken($token)
            ->getJson('/api/institution/equipment?category=uti')
            ->assertOk()
            ->assertJsonCount(1)
            ->assertJsonFragment(['catalog_equipment_id' => $catUti->id]);

        $this->withToken($token)
            ->getJson('/api/institution/equipment')
            ->assertOk()
            ->assertJsonCount(2);
    }

    public function test_gestor_can_filter_park_by_search(): void
    {
        [$token, , $catalog] = $this->gestorWithCatalogTemplate();

        $this->withToken($token)->postJson('/api/institution/equipment', [
            'catalog_equipment_id' => $catalog->id,
            'sector' => 'Bloco Neuro',
        ])->assertCreated();

        $this->withToken($token)
            ->getJson('/api/institution/equipment?search='.urlencode('Ventilador'))
            ->assertOk()
            ->assertJsonCount(1);

        $this->withToken($token)
            ->getJson('/api/institution/equipment?search='.urlencode('inexistente'))
            ->assertOk()
            ->assertJsonCount(0);
    }

    public function test_gestor_downloads_catalog_model_image(): void
    {
        [$token, , $catalog] = $this->gestorWithCatalogTemplate();

        Storage::fake(config('filesystems.default', 'local'));
        $path = 'equipment-files/1/'.$catalog->id.'/thumb.jpg';
        Storage::disk(config('filesystems.default', 'local'))->put($path, 'fake-image-bytes');
        $catalog->update(['image_stored_path' => $path]);

        $this->withToken($token)
            ->get('/api/institution/catalog-equipment/'.$catalog->id.'/image')
            ->assertOk();
    }

    public function test_rejects_non_catalog_equipment_id(): void
    {
        [$token, $inst, $catalog] = $this->gestorWithCatalogTemplate();

        $wrong = Equipment::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $catalog->manufacturer_id,
            'catalog_equipment_id' => $catalog->id,
            'name' => 'X',
            'model' => 'Y',
            'quantity' => 1,
            'status' => 'active',
        ]);

        $this->withToken($token)
            ->postJson('/api/institution/equipment', [
                'catalog_equipment_id' => $wrong->id,
            ])
            ->assertStatus(422);
    }
}
