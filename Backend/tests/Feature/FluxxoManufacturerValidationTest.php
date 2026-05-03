<?php

namespace Tests\Feature;

use App\Mail\ManufacturerRegistrationApproved;
use App\Mail\ManufacturerValidationRequested;
use App\Mail\NewManufacturerRegistered;
use App\Models\Manufacturer;
use App\Models\ManufacturerDocument;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FluxxoManufacturerValidationTest extends TestCase
{
    use RefreshDatabase;

    protected function makeManufacturerAdmin(string $validationStatus = 'pending_info'): array
    {
        $suffix = Str::lower(Str::random(6));
        $m = Manufacturer::query()->create([
            'name' => 'Fab '.$suffix,
            'slug' => 'fab-'.$suffix,
            'status' => 'active',
            'validation_status' => $validationStatus,
        ]);
        $user = User::factory()->create([
            'email' => 'mfg-'.$suffix.'@test.local',
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $m->id,
        ]);

        return [$m, $user];
    }

    protected function seedManufacturerReadyForValidation(Manufacturer $m, string $supportEmail): void
    {
        $m->update([
            'name' => 'Empresa Teste LTDA',
            'trade_name' => 'Empresa Teste',
            'cnpj' => '12345678000199',
            'commercial_phone' => '1130005000',
            'support_email' => $supportEmail,
            'address_postal_code' => '86020110',
            'address_street' => 'Av Tiradentes, 1500',
            'address_neighborhood' => 'Centro',
            'address_city' => 'Londrina',
            'address_state' => 'PR',
            'legal_rep_full_name' => 'Roberto Silva Pereira',
            'legal_rep_cpf' => '52998224725',
            'legal_rep_role' => 'Diretor de Qualidade',
            'legal_rep_phone' => '11999990000',
            'declaration_accepted_at' => now(),
        ]);

        foreach (['cnpj_proof', 'articles_of_incorporation', 'address_proof'] as $kind) {
            ManufacturerDocument::query()->create([
                'manufacturer_id' => $m->id,
                'stored_path' => 'manufacturer-documents/'.$m->id.'/test-'.$kind.'.pdf',
                'original_filename' => $kind.'.pdf',
                'mime_type' => 'application/pdf',
                'size_bytes' => 120,
                'document_kind' => $kind,
            ]);
        }
    }

    public function test_manufacturer_submits_for_validation(): void
    {
        Mail::fake();
        Config::set('manufacturer.reviewer_emails', ['rev@notify.test']);
        Config::set('manufacturer.skip_validation_review', false);

        [$m, $user] = $this->makeManufacturerAdmin('pending_info');
        $this->seedManufacturerReadyForValidation($m, $user->email);

        Sanctum::actingAs($user);

        $res = $this->postJson('/api/manufacturer/request-validation')
            ->assertOk()
            ->assertJsonPath('manufacturer.validation_status', 'pending_validation');

        $proto = $res->json('manufacturer.validation_protocol');
        $this->assertIsString($proto);
        $this->assertStringStartsWith('FAB-', $proto);

        Mail::assertQueued(ManufacturerValidationRequested::class);
    }

    public function test_manufacturer_request_validation_skips_review_when_config_enabled(): void
    {
        Mail::fake();
        Config::set('manufacturer.reviewer_emails', ['rev@notify.test']);
        Config::set('manufacturer.skip_validation_review', true);

        [$m, $user] = $this->makeManufacturerAdmin('pending_info');
        $this->seedManufacturerReadyForValidation($m, $user->email);

        Sanctum::actingAs($user);

        $res = $this->postJson('/api/manufacturer/request-validation')
            ->assertOk()
            ->assertJsonPath('manufacturer.validation_status', 'active');

        $proto = $res->json('manufacturer.validation_protocol');
        $this->assertIsString($proto);
        $this->assertStringStartsWith('FAB-', $proto);

        Mail::assertNothingQueued();
    }

    public function test_reviewer_gets_registration_mail_when_option_enabled(): void
    {
        Mail::fake();
        Config::set('manufacturer.reviewer_emails', ['rev@notify.test']);
        Config::set('manufacturer.notify_reviewers_on_registration', true);

        $suffix = Str::lower(Str::random(8));

        $this->postJson('/api/auth/register', [
            'name' => 'Admin Fab',
            'email' => "fab-reg-{$suffix}@test.local",
            'password' => 'password12345',
            'role' => 'manufacturer_admin',
            'manufacturer_name' => "Empresa Reg {$suffix}",
        ])
            ->assertCreated();

        Mail::assertQueued(NewManufacturerRegistered::class);
    }

    public function test_manufacturer_cannot_resubmit_while_in_review(): void
    {
        [, $user] = $this->makeManufacturerAdmin('pending_validation');

        Sanctum::actingAs($user);

        $this->postJson('/api/manufacturer/request-validation')
            ->assertStatus(422);
    }

    public function test_reviewer_can_approve(): void
    {
        Mail::fake();
        Config::set('manufacturer.reviewer_emails', ['reviewer@fluxxo.test']);

        [$mfg] = $this->makeManufacturerAdmin('pending_validation');
        $mfg->update([
            'support_email' => 'fab-approved@notify.test',
            'validation_protocol' => 'FAB-20990101-0001',
            'validation_submitted_at' => now(),
        ]);

        $reviewer = User::factory()->create([
            'email' => 'reviewer@fluxxo.test',
            'role' => 'instructor',
        ]);

        Sanctum::actingAs($reviewer);

        $this->patchJson('/api/manufacturer/reviews/'.$mfg->id, [
            'validation_status' => 'active',
        ])
            ->assertOk()
            ->assertJsonPath('manufacturer.validation_status', 'active');

        Mail::assertQueued(ManufacturerRegistrationApproved::class);
    }

    public function test_non_reviewer_cannot_review(): void
    {
        Config::set('manufacturer.reviewer_emails', ['reviewer@fluxxo.test']);

        [$mfg] = $this->makeManufacturerAdmin('pending_validation');

        $other = User::factory()->create([
            'email' => 'nobody@fluxxo.test',
            'role' => 'instructor',
        ]);

        Sanctum::actingAs($other);

        $this->patchJson('/api/manufacturer/reviews/'.$mfg->id, [
            'validation_status' => 'active',
        ])
            ->assertForbidden();
    }

    public function test_reviewer_can_list_queue(): void
    {
        Config::set('manufacturer.reviewer_emails', ['queue@fluxxo.test']);

        [$mfg] = $this->makeManufacturerAdmin('pending_validation');

        $reviewer = User::factory()->create([
            'email' => 'queue@fluxxo.test',
            'role' => 'instructor',
        ]);

        Sanctum::actingAs($reviewer);

        $this->getJson('/api/manufacturer/review-queue')
            ->assertOk()
            ->assertJsonFragment(['id' => $mfg->id]);
    }

    public function test_register_rejects_institution_admin_role(): void
    {
        $suffix = Str::lower(Str::random(8));

        $this->postJson('/api/auth/register', [
            'name' => 'Gestor',
            'email' => "inst-try-{$suffix}@test.local",
            'password' => 'password12345',
            'role' => 'institution_admin',
        ])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['role']);
    }
}
