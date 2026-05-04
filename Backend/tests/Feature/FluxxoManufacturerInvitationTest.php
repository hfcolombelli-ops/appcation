<?php

namespace Tests\Feature;

use App\Mail\InvitationMail;
use App\Models\Institution;
use App\Models\Invitation;
use App\Models\Manufacturer;
use App\Models\ManufacturerInstructor;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FluxxoManufacturerInvitationTest extends TestCase
{
    use RefreshDatabase;

    /**
     * @return array{0: Manufacturer, 1: User}
     */
    private function makeManufacturerAdmin(): array
    {
        $suffix = Str::lower(Str::random(6));
        $m = Manufacturer::query()->create([
            'name' => 'Fab '.$suffix,
            'slug' => 'fab-'.$suffix,
            'status' => 'active',
            'validation_status' => 'active',
        ]);
        $user = User::factory()->create([
            'email' => 'mfg-'.$suffix.'@test.local',
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $m->id,
        ]);

        return [$m, $user];
    }

    public function test_manufacturer_creates_institution_with_manufacturer_id(): void
    {
        [$m, $admin] = $this->makeManufacturerAdmin();
        Sanctum::actingAs($admin);

        $cnpj = '112223330001'.Str::padLeft((string) random_int(10, 99), 2, '0');
        $res = $this->postJson('/api/manufacturer/institutions', [
            'name' => 'Hospital Teste',
            'cnpj' => $cnpj,
            'city' => 'Lisboa',
        ]);

        $res->assertCreated();
        $this->assertDatabaseHas('institutions', [
            'cnpj' => preg_replace('/\D+/', '', $cnpj),
            'manufacturer_id' => $m->id,
        ]);
    }

    public function test_manufacturer_lists_only_own_institutions(): void
    {
        [$m, $admin] = $this->makeManufacturerAdmin();
        Sanctum::actingAs($admin);

        $cnpjA = '998887770001'.Str::padLeft((string) random_int(10, 99), 2, '0');
        $this->postJson('/api/manufacturer/institutions', [
            'name' => 'Hospital A',
            'cnpj' => $cnpjA,
        ])->assertCreated();

        $suffix = Str::lower(Str::random(6));
        $other = Manufacturer::query()->create([
            'name' => 'Outro Fab '.$suffix,
            'slug' => 'outro-'.$suffix,
            'status' => 'active',
            'validation_status' => 'active',
        ]);
        Institution::query()->create([
            'name' => 'Hospital Outro',
            'cnpj' => '887776660001'.Str::padLeft((string) random_int(10, 99), 2, '0'),
            'status' => 'active',
            'manufacturer_id' => $other->id,
        ]);

        $list = $this->getJson('/api/manufacturer/institutions');
        $list->assertOk();
        $rows = $list->json();
        $this->assertIsArray($rows);
        $this->assertCount(1, $rows);
        $this->assertSame('Hospital A', $rows[0]['name'] ?? null);
    }

    public function test_invite_and_accept_institution_admin(): void
    {
        Mail::fake();
        [$m, $admin] = $this->makeManufacturerAdmin();
        Sanctum::actingAs($admin);

        $inst = Institution::query()->create([
            'name' => 'Inst '.$m->id,
            'cnpj' => '445566770001'.Str::padLeft((string) random_int(10, 99), 2, '0'),
            'status' => 'active',
            'manufacturer_id' => $m->id,
        ]);

        $inviteEmail = 'gestor-'.Str::lower(Str::random(5)).'@test.local';
        $this->postJson('/api/manufacturer/invitations', [
            'invited_email' => $inviteEmail,
            'invited_name' => 'Gestor Um',
            'invited_cpf' => '52998224725',
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ])->assertCreated();

        Mail::assertSent(InvitationMail::class);

        $plain = null;
        Mail::assertSent(InvitationMail::class, function (InvitationMail $mail) use (&$plain) {
            $q = parse_url($mail->acceptUrl, PHP_URL_QUERY);
            parse_str((string) $q, $parts);
            $plain = $parts['token'] ?? null;

            return $plain !== null && $plain !== '';
        });

        $this->assertNotNull($plain);

        $this->getJson('/api/public/invitations/'.$plain)
            ->assertOk()
            ->assertJsonPath('status', 'pending')
            ->assertJsonPath('requires_cpf', true);

        $this->postJson('/api/public/invitations/'.$plain.'/accept', [
            'name' => 'Gestor Um',
            'password' => 'SecretPass9!',
            'password_confirmation' => 'SecretPass9!',
            'cpf' => '529.982.247-25',
        ])->assertCreated()
            ->assertJsonPath('user.role', 'institution_admin')
            ->assertJsonPath('user.institution_id', $inst->id);

        $u = User::query()->where('email', $inviteEmail)->first();
        $this->assertNotNull($u);
        $this->assertSame('52998224725', $u->cpf);
        $this->assertNotNull(Invitation::query()->where('invited_email', $inviteEmail)->whereNotNull('accepted_at')->first());
    }

    public function test_invite_rejected_when_email_already_registered(): void
    {
        Mail::fake();
        [$m, $admin] = $this->makeManufacturerAdmin();
        Sanctum::actingAs($admin);

        $existing = User::factory()->create(['email' => 'exists@test.local']);

        $inst = Institution::query()->create([
            'name' => 'Inst X',
            'cnpj' => '554433220001'.Str::padLeft((string) random_int(10, 99), 2, '0'),
            'status' => 'active',
            'manufacturer_id' => $m->id,
        ]);

        $this->postJson('/api/manufacturer/invitations', [
            'invited_email' => $existing->email,
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ])->assertStatus(422);
    }

    public function test_invite_instructor_creates_pivot_rows(): void
    {
        Mail::fake();
        [$m, $admin] = $this->makeManufacturerAdmin();
        Sanctum::actingAs($admin);

        $inst = Institution::query()->create([
            'name' => 'Inst Ins',
            'cnpj' => '334455660001'.Str::padLeft((string) random_int(10, 99), 2, '0'),
            'status' => 'active',
            'manufacturer_id' => $m->id,
        ]);

        $inviteEmail = 'instr-'.Str::lower(Str::random(5)).'@test.local';
        $this->postJson('/api/manufacturer/invitations', [
            'invited_email' => $inviteEmail,
            'role' => 'instructor',
            'institution_id' => $inst->id,
        ])->assertCreated();

        $plain = null;
        Mail::assertSent(InvitationMail::class, function (InvitationMail $mail) use (&$plain) {
            $q = parse_url($mail->acceptUrl, PHP_URL_QUERY);
            parse_str((string) $q, $parts);
            $plain = $parts['token'] ?? null;

            return true;
        });

        $this->postJson('/api/public/invitations/'.$plain.'/accept', [
            'name' => 'Instrutor Um',
            'password' => 'SecretPass9!',
            'password_confirmation' => 'SecretPass9!',
        ])->assertCreated();

        $u = User::query()->where('email', $inviteEmail)->firstOrFail();
        $this->assertSame('instructor', $u->role);
        $this->assertSame((int) $m->id, (int) $u->manufacturer_id);

        $this->assertTrue(ManufacturerInstructor::query()
            ->where('manufacturer_id', $m->id)
            ->where('instructor_id', $u->id)
            ->where('status', 'approved')
            ->exists());
    }

    public function test_manufacturer_can_revoke_invitation(): void
    {
        Mail::fake();
        [$m, $admin] = $this->makeManufacturerAdmin();
        Sanctum::actingAs($admin);

        $inst = Institution::query()->create([
            'name' => 'Inst R',
            'cnpj' => '998877660001'.Str::padLeft((string) random_int(10, 99), 2, '0'),
            'status' => 'active',
            'manufacturer_id' => $m->id,
        ]);

        $res = $this->postJson('/api/manufacturer/invitations', [
            'invited_email' => 'revoke-'.Str::lower(Str::random(4)).'@test.local',
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ])->assertCreated();

        $id = $res->json('id');
        $this->deleteJson('/api/manufacturer/invitations/'.$id)->assertOk();

        $inv = Invitation::query()->findOrFail($id);
        $this->assertNotNull($inv->revoked_at);
    }
}
