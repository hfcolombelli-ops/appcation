<?php

namespace Tests\Feature;

use App\Models\Enrollment;
use App\Models\Institution;
use App\Models\Manufacturer;
use App\Models\Training;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoManufacturerDashboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_manufacturer_dashboard_summary_and_csv(): void
    {
        $manufacturer = Manufacturer::query()->create([
            'name' => 'Fab Dash',
            'slug' => 'fab-dash-'.Str::lower(Str::random(6)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $manufacturer->id,
        ]);

        $inst = Institution::query()->create([
            'name' => 'Inst Fab',
            'cnpj' => '99.888.777/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $tr = Training::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $manufacturer->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino of',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);

        Enrollment::query()->create([
            'training_id' => $tr->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 8.5,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $token = $admin->createToken('m')->plainTextToken;

        $res = $this->withToken($token)->getJson('/api/manufacturer/dashboard-summary');
        $res->assertOk();
        $res->assertJsonPath('trainings_count', 1);
        $res->assertJsonPath('finished_trainings_count', 1);
        $res->assertJsonPath('completion_summary.total_enrollments', 1);
        $res->assertJsonPath('completion_summary.completed_count', 1);
        $this->assertEquals(8.5, (float) $res->json('avg_score_completed'));
        $res->assertJsonPath('aggregated_by_institution.0.label', 'Inst Fab');

        $csv = $this->withToken($token)->get('/api/manufacturer/dashboard-summary/export.csv');
        $csv->assertOk();
        $csv->assertHeader('content-type', 'text/csv; charset=UTF-8');
        $this->assertStringContainsString('Inst Fab', $csv->getContent());
        $this->assertStringContainsString('Por instituição', $csv->getContent());

        $pdf = $this->withToken($token)->get('/api/manufacturer/dashboard-summary/export.pdf');
        $pdf->assertOk();
        $this->assertStringStartsWith('%PDF', $pdf->getContent());
        $this->assertStringContainsString('application/pdf', (string) $pdf->headers->get('content-type'));
    }

    public function test_manufacturer_dashboard_forbidden_for_trainee(): void
    {
        $u = User::factory()->create(['role' => 'trainee']);
        $this->withToken($u->createToken('t')->plainTextToken)
            ->get('/api/manufacturer/dashboard-summary/export.csv')
            ->assertForbidden();
    }
}
