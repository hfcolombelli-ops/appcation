<?php

namespace Tests\Feature;

use App\Models\Certificate;
use App\Models\Enrollment;
use App\Models\Institution;
use App\Models\Training;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoCertificatePdfVerifyTest extends TestCase
{
    use RefreshDatabase;

    public function test_public_verify_returns_404_for_unknown_code(): void
    {
        $this->get('/certificates/verify/APP-NADA')
            ->assertNotFound();
    }

    public function test_public_verify_html_for_valid_code(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst Verify',
            'cnpj' => '33.444.555/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee', 'name' => 'Maria Treinanda']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino PDF',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 90.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $code = 'APP²-VERIFY'.Str::upper(Str::random(6));

        Certificate::query()->create([
            'user_id' => $trainee->id,
            'enrollment_id' => $enrollment->id,
            'training_id' => $training->id,
            'score' => 9.0,
            'certificate_code' => $code,
            'issued_at' => now(),
            'expires_at' => now()->addYear(),
        ]);

        $this->get('/certificates/verify/'.rawurlencode($code))
            ->assertOk()
            ->assertSee('Certificado válido', false)
            ->assertSee(e($code), false)
            ->assertSee('Maria Treinanda', false)
            ->assertSee('Treino PDF', false);
    }

    public function test_public_verify_json(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst J',
            'cnpj' => '44.555.666/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'JSON treino',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 80.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $code = 'APP-J-'.Str::upper(Str::random(8));

        Certificate::query()->create([
            'user_id' => $trainee->id,
            'enrollment_id' => $enrollment->id,
            'training_id' => $training->id,
            'score' => 8.0,
            'certificate_code' => $code,
            'issued_at' => now(),
            'expires_at' => now()->addYear(),
        ]);

        $this->getJson('/certificates/verify/'.rawurlencode($code))
            ->assertOk()
            ->assertJsonPath('valid', true)
            ->assertJsonPath('certificate_code', $code)
            ->assertJsonPath('training_title', 'JSON treino');

        $this->getJson('/api/public/certificates/verify/'.rawurlencode($code))
            ->assertOk()
            ->assertJsonPath('valid', true)
            ->assertJsonPath('certificate_code', $code)
            ->assertJsonPath('training_title', 'JSON treino');
    }

    public function test_trainee_downloads_own_certificate_pdf(): void
    {
        $inst = Institution::query()->create([
            'name' => 'Inst PDF',
            'cnpj' => '55.666.777/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $training = Training::query()->create([
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino down',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);

        $enrollment = Enrollment::query()->create([
            'training_id' => $training->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 85.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $cert = Certificate::query()->create([
            'user_id' => $trainee->id,
            'enrollment_id' => $enrollment->id,
            'training_id' => $training->id,
            'score' => 8.5,
            'certificate_code' => 'APP-PDF-'.Str::upper(Str::random(8)),
            'issued_at' => now(),
            'expires_at' => now()->addYear(),
        ]);

        $token = $trainee->createToken('t')->plainTextToken;

        $res = $this->withToken($token)->get('/api/me/certificates/'.$cert->id.'/pdf');
        $res->assertOk();
        $this->assertStringStartsWith('%PDF', $res->getContent());
        $this->assertStringContainsString('application/pdf', (string) $res->headers->get('content-type'));
    }
}
