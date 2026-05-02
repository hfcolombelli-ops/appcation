<?php

namespace Tests\Feature;

use App\Models\Enrollment;
use App\Models\Equipment;
use App\Models\Institution;
use App\Models\Manufacturer;
use App\Models\Training;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoInstitutionDashboardKpiTest extends TestCase
{
    use RefreshDatabase;

    public function test_institution_dashboard_includes_completion_and_by_equipment(): void
    {
        $inst = Institution::query()->create([
            'name' => 'H KPI',
            'cnpj' => '12.345.678/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $m = Manufacturer::query()->create([
            'name' => 'Fab',
            'slug' => 'fab-'.Str::random(6),
            'status' => 'active',
            'validation_status' => 'active',
        ]);

        $eq = Equipment::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $m->id,
            'name' => 'Vent',
            'model' => 'V1',
            'quantity' => 1,
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);

        $tr = Training::query()->create([
            'title' => 'Treino X',
            'institution_id' => $inst->id,
            'instructor_id' => $instructor->id,
            'equipment_id' => $eq->id,
            'status' => 'published',
            'type' => 'standard',
            'join_hash' => Str::random(12),
        ]);

        $u1 = User::factory()->create(['role' => 'trainee']);
        $u2 = User::factory()->create(['role' => 'trainee']);

        Enrollment::query()->create([
            'training_id' => $tr->id,
            'user_id' => $u1->id,
            'status' => 'completed',
            'score' => 80,
        ]);
        Enrollment::query()->create([
            'training_id' => $tr->id,
            'user_id' => $u2->id,
            'status' => 'joined',
            'score' => null,
        ]);

        $admin = User::factory()->create([
            'role' => 'institution_admin',
            'institution_id' => $inst->id,
        ]);
        $token = $admin->createToken('t')->plainTextToken;

        $res = $this->withToken($token)
            ->getJson('/api/institution/dashboard-summary');

        $res->assertOk();
        $res->assertJsonPath('completion_summary.total_enrollments', 2);
        $res->assertJsonPath('completion_summary.completed_count', 1);
        $this->assertEquals(50.0, (float) $res->json('completion_summary.completion_rate_percent'));
        $res->assertJsonPath('trainings_count', 1);
        $this->assertEquals(80.0, (float) $res->json('avg_score_completed'));
        $res->assertJsonCount(1, 'aggregated_by_equipment');
        $this->assertSame('Vent V1', $res->json('aggregated_by_equipment.0.label'));

        $csv = $this->withToken($token)
            ->get('/api/institution/dashboard-summary/export.csv');
        $csv->assertOk();
        $csv->assertHeader('content-type', 'text/csv; charset=UTF-8');
        $this->assertStringContainsString('Relatório agregado', $csv->getContent());
        $this->assertStringContainsString('Vent', $csv->getContent());
        $this->assertStringContainsString('Por equipamento', $csv->getContent());

        $pdf = $this->withToken($token)->get('/api/institution/dashboard-summary/export.pdf');
        $pdf->assertOk();
        $this->assertStringStartsWith('%PDF', $pdf->getContent());
        $this->assertStringContainsString('application/pdf', (string) $pdf->headers->get('content-type'));
    }

    public function test_institution_dashboard_csv_forbidden_for_non_gestor(): void
    {
        $u = User::factory()->create(['role' => 'trainee']);
        $this->withToken($u->createToken('t')->plainTextToken)
            ->get('/api/institution/dashboard-summary/export.csv')
            ->assertForbidden();
    }
}
