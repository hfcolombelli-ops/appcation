<?php

namespace Tests\Feature;

use App\Models\Manufacturer;
use App\Models\ManufacturerDocument;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoManufacturerDocumentsTest extends TestCase
{
    use RefreshDatabase;

    /**
     * @return array{0: User, 1: string, 2: Manufacturer}
     */
    protected function manufacturerAdminWithToken(): array
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

        return [$user, $user->createToken('test')->plainTextToken, $m];
    }

    public function test_manufacturer_can_upload_list_download_and_delete_document(): void
    {
        Storage::fake('local');
        [, $token, $m] = $this->manufacturerAdminWithToken();

        $this->withToken($token)
            ->getJson('/api/manufacturer/documents')
            ->assertOk()
            ->assertJsonCount(0);

        $file = UploadedFile::fake()->create('manual.pdf', 120, 'application/pdf');

        $create = $this->withToken($token)->post('/api/manufacturer/documents', [
            'file' => $file,
            'document_kind' => 'manual',
            'notes' => 'Nota de teste',
        ]);

        $create->assertCreated();
        $id = $create->json('id');
        $this->assertNotNull($id);
        $stored = $create->json('stored_path');
        $this->assertIsString($stored);
        Storage::disk('local')->assertExists($stored);

        $this->withToken($token)
            ->getJson('/api/manufacturer/documents')
            ->assertOk()
            ->assertJsonCount(1);

        $this->withToken($token)
            ->get("/api/manufacturer/documents/{$id}/download")
            ->assertOk()
            ->assertHeader('content-type', 'application/pdf');

        $this->withToken($token)
            ->deleteJson("/api/manufacturer/documents/{$id}")
            ->assertOk();

        Storage::disk('local')->assertMissing($stored);
        $this->assertSame(0, ManufacturerDocument::query()->where('manufacturer_id', $m->id)->count());
    }

    public function test_other_manufacturer_cannot_download_peer_document(): void
    {
        Storage::fake('local');
        [, , $mA] = $this->manufacturerAdminWithToken();
        [, $tokenB, $mB] = $this->manufacturerAdminWithToken();
        $this->assertNotSame($mA->id, $mB->id);

        $stored = 'manufacturer-documents/'.$mA->id.'/peer.pdf';
        Storage::disk('local')->put($stored, 'conteúdo');
        $doc = ManufacturerDocument::query()->create([
            'manufacturer_id' => $mA->id,
            'stored_path' => $stored,
            'original_filename' => 'peer.pdf',
            'mime_type' => 'application/pdf',
            'size_bytes' => 8,
            'document_kind' => 'other',
            'notes' => null,
        ]);

        $this->withToken($tokenB)
            ->get("/api/manufacturer/documents/{$doc->id}/download")
            ->assertNotFound();
    }
}
