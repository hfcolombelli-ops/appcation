<?php

namespace Tests\Feature;

use App\Models\Enrollment;
use App\Models\Equipment;
use App\Models\Institution;
use App\Models\Manufacturer;
use App\Models\Training;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
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
        $res->assertJsonCount(1, 'completed_by_month');
        $this->assertSame(1, (int) collect($res->json('completed_by_month'))->sum('completed_count'));
        $res->assertJsonCount(1, 'enrollments_by_month');
        $this->assertSame(1, (int) collect($res->json('enrollments_by_month'))->sum('enrollment_count'));
        $res->assertJsonCount(1, 'monthly_trend');
        $trendRow = collect($res->json('monthly_trend'))->first();
        $this->assertSame(1, (int) $trendRow['enrollment_count']);
        $this->assertSame(1, (int) $trendRow['completed_count']);

        $csv = $this->withToken($token)->get('/api/manufacturer/dashboard-summary/export.csv');
        $csv->assertOk();
        $csv->assertHeader('content-type', 'text/csv; charset=UTF-8');
        $this->assertStringContainsString('Inst Fab', $csv->getContent());
        $this->assertStringContainsString('Por instituição', $csv->getContent());
        $this->assertStringContainsString('Tendência mensal combinada', $csv->getContent());

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

    public function test_manufacturer_dashboard_completed_by_month_series(): void
    {
        $manufacturer = Manufacturer::query()->create([
            'name' => 'Fab Month',
            'slug' => 'fab-mo-'.Str::lower(Str::random(6)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $manufacturer->id,
        ]);

        $inst = Institution::query()->create([
            'name' => 'Inst Month',
            'cnpj' => '55.666.777/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee1 = User::factory()->create(['role' => 'trainee']);
        $trainee2 = User::factory()->create(['role' => 'trainee']);

        $tr = Training::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $manufacturer->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino m',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);

        $e1 = Enrollment::query()->create([
            'training_id' => $tr->id,
            'user_id' => $trainee1->id,
            'status' => 'completed',
            'score' => 7.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);
        $e2 = Enrollment::query()->create([
            'training_id' => $tr->id,
            'user_id' => $trainee2->id,
            'status' => 'completed',
            'score' => 8.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        DB::table('enrollments')->where('id', $e1->id)->update(['completed_at' => '2024-01-10 12:00:00']);
        DB::table('enrollments')->where('id', $e2->id)->update(['completed_at' => '2024-02-15 12:00:00']);

        $token = $admin->createToken('m')->plainTextToken;

        $res = $this->withToken($token)->getJson('/api/manufacturer/dashboard-summary');
        $res->assertOk();
        $res->assertJsonCount(2, 'completed_by_month');
        $by = collect($res->json('completed_by_month'))->keyBy('period');
        $this->assertSame(1, (int) $by->get('2024-01')['completed_count']);
        $this->assertSame(1, (int) $by->get('2024-02')['completed_count']);
    }

    public function test_manufacturer_dashboard_enrollments_by_month_series(): void
    {
        $manufacturer = Manufacturer::query()->create([
            'name' => 'Fab Enr Month',
            'slug' => 'fab-em-'.Str::lower(Str::random(6)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $manufacturer->id,
        ]);

        $inst = Institution::query()->create([
            'name' => 'Inst Enr',
            'cnpj' => '66.777.888/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee1 = User::factory()->create(['role' => 'trainee']);
        $trainee2 = User::factory()->create(['role' => 'trainee']);

        $tr = Training::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $manufacturer->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino enr',
            'type' => 'official',
            'status' => 'published',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);

        $e1 = Enrollment::query()->create([
            'training_id' => $tr->id,
            'user_id' => $trainee1->id,
            'status' => 'joined',
            'score' => null,
            'joined_at' => null,
            'completed_at' => null,
        ]);
        $e2 = Enrollment::query()->create([
            'training_id' => $tr->id,
            'user_id' => $trainee2->id,
            'status' => 'joined',
            'score' => null,
            'joined_at' => null,
            'completed_at' => null,
        ]);

        DB::table('enrollments')->where('id', $e1->id)->update([
            'created_at' => '2023-11-01 10:00:00',
            'updated_at' => '2023-11-01 10:00:00',
        ]);
        DB::table('enrollments')->where('id', $e2->id)->update([
            'created_at' => '2023-12-05 10:00:00',
            'updated_at' => '2023-12-05 10:00:00',
        ]);

        $token = $admin->createToken('m')->plainTextToken;

        $res = $this->withToken($token)->getJson('/api/manufacturer/dashboard-summary');
        $res->assertOk();
        $res->assertJsonCount(2, 'enrollments_by_month');
        $by = collect($res->json('enrollments_by_month'))->keyBy('period');
        $this->assertSame(1, (int) $by->get('2023-11')['enrollment_count']);
        $this->assertSame(1, (int) $by->get('2023-12')['enrollment_count']);
    }

    public function test_manufacturer_dashboard_monthly_trend_unions_enrollment_and_completion_months(): void
    {
        $manufacturer = Manufacturer::query()->create([
            'name' => 'Fab Trend Union',
            'slug' => 'fab-tu-'.Str::lower(Str::random(6)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $manufacturer->id,
        ]);

        $inst = Institution::query()->create([
            'name' => 'Inst Trend',
            'cnpj' => '77.888.999/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee1 = User::factory()->create(['role' => 'trainee']);
        $trainee2 = User::factory()->create(['role' => 'trainee']);

        $tr = Training::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $manufacturer->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino trend',
            'type' => 'official',
            'status' => 'published',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);

        $eJoined = Enrollment::query()->create([
            'training_id' => $tr->id,
            'user_id' => $trainee1->id,
            'status' => 'joined',
            'score' => null,
            'joined_at' => null,
            'completed_at' => null,
        ]);
        $eDone = Enrollment::query()->create([
            'training_id' => $tr->id,
            'user_id' => $trainee2->id,
            'status' => 'completed',
            'score' => 8.0,
            'joined_at' => null,
            'completed_at' => '2024-02-10 12:00:00',
        ]);

        DB::table('enrollments')->where('id', $eJoined->id)->update([
            'created_at' => '2023-11-01 10:00:00',
            'updated_at' => '2023-11-01 10:00:00',
        ]);
        DB::table('enrollments')->where('id', $eDone->id)->update([
            'created_at' => '2024-02-01 10:00:00',
            'updated_at' => '2024-02-01 10:00:00',
        ]);

        $token = $admin->createToken('m')->plainTextToken;

        $res = $this->withToken($token)->getJson('/api/manufacturer/dashboard-summary');
        $res->assertOk();
        $res->assertJsonCount(2, 'monthly_trend');
        $by = collect($res->json('monthly_trend'))->keyBy('period');
        $this->assertSame(1, (int) $by->get('2023-11')['enrollment_count']);
        $this->assertSame(0, (int) $by->get('2023-11')['completed_count']);
        $this->assertSame(1, (int) $by->get('2024-02')['enrollment_count']);
        $this->assertSame(1, (int) $by->get('2024-02')['completed_count']);
    }

    public function test_manufacturer_dashboard_institution_query_filter(): void
    {
        $manufacturer = Manufacturer::query()->create([
            'name' => 'Fab Filter Inst',
            'slug' => 'fab-fi-'.Str::lower(Str::random(6)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $manufacturer->id,
        ]);

        $instA = Institution::query()->create([
            'name' => 'Inst A',
            'cnpj' => '11.222.333/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);
        $instB = Institution::query()->create([
            'name' => 'Inst B',
            'cnpj' => '22.333.444/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $trA = Training::query()->create([
            'institution_id' => $instA->id,
            'manufacturer_id' => $manufacturer->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino A',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);
        $trB = Training::query()->create([
            'institution_id' => $instB->id,
            'manufacturer_id' => $manufacturer->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino B',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);

        Enrollment::query()->create([
            'training_id' => $trA->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 7.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);
        Enrollment::query()->create([
            'training_id' => $trB->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 9.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $token = $admin->createToken('m')->plainTextToken;

        $this->withToken($token)->getJson('/api/manufacturer/dashboard-summary')->assertOk()
            ->assertJsonPath('trainings_count', 2)
            ->assertJsonPath('completion_summary.total_enrollments', 2);

        $this->withToken($token)
            ->getJson('/api/manufacturer/dashboard-summary?institution_id='.$instA->id)
            ->assertOk()
            ->assertJsonPath('trainings_count', 1)
            ->assertJsonPath('completion_summary.total_enrollments', 1)
            ->assertJsonPath('aggregated_by_institution.0.label', 'Inst A');
    }

    public function test_manufacturer_dashboard_training_created_date_filter(): void
    {
        $manufacturer = Manufacturer::query()->create([
            'name' => 'Fab Filter Date',
            'slug' => 'fab-fd-'.Str::lower(Str::random(6)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $manufacturer->id,
        ]);

        $inst = Institution::query()->create([
            'name' => 'Inst Date',
            'cnpj' => '33.444.555/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $trOld = Training::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $manufacturer->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino velho',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);
        $trNew = Training::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $manufacturer->id,
            'instructor_id' => $instructor->id,
            'title' => 'Treino novo',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);

        DB::table('trainings')->where('id', $trOld->id)->update(['created_at' => '2019-06-01 10:00:00']);

        Enrollment::query()->create([
            'training_id' => $trOld->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 6.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);
        Enrollment::query()->create([
            'training_id' => $trNew->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 8.0,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $token = $admin->createToken('m')->plainTextToken;

        $res = $this->withToken($token)
            ->getJson('/api/manufacturer/dashboard-summary?training_created_from=2024-01-01');
        $res->assertOk()
            ->assertJsonPath('trainings_count', 1)
            ->assertJsonPath('completion_summary.total_enrollments', 1);
        $this->assertEquals(8.0, (float) $res->json('avg_score_completed'));
    }

    public function test_manufacturer_dashboard_invalid_equipment_returns_422(): void
    {
        $manufacturer = Manufacturer::query()->create([
            'name' => 'Fab Bad Eq',
            'slug' => 'fab-be-'.Str::lower(Str::random(6)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $manufacturer->id,
        ]);

        $token = $admin->createToken('m')->plainTextToken;

        $this->withToken($token)
            ->getJson('/api/manufacturer/dashboard-summary?equipment_id=999999999')
            ->assertStatus(422);
    }

    public function test_manufacturer_dashboard_invalid_date_format_returns_422(): void
    {
        $manufacturer = Manufacturer::query()->create([
            'name' => 'Fab Bad Date',
            'slug' => 'fab-bd-'.Str::lower(Str::random(6)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $manufacturer->id,
        ]);

        $token = $admin->createToken('m')->plainTextToken;

        $this->withToken($token)
            ->getJson('/api/manufacturer/dashboard-summary?training_created_from=01-02-2024')
            ->assertStatus(422);
    }

    public function test_manufacturer_dashboard_equipment_query_filter(): void
    {
        $manufacturer = Manufacturer::query()->create([
            'name' => 'Fab Filter Eq',
            'slug' => 'fab-fe-'.Str::lower(Str::random(6)),
            'status' => 'active',
        ]);

        $admin = User::factory()->create([
            'role' => 'manufacturer_admin',
            'manufacturer_id' => $manufacturer->id,
        ]);

        $inst = Institution::query()->create([
            'name' => 'Inst Eq',
            'cnpj' => '44.555.666/0001-'.Str::upper(Str::random(2)),
            'status' => 'active',
        ]);

        $eqVent = Equipment::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $manufacturer->id,
            'name' => 'Vent',
            'model' => 'V1',
            'quantity' => 1,
            'status' => 'active',
        ]);
        $eqPump = Equipment::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $manufacturer->id,
            'name' => 'Pump',
            'model' => 'P2',
            'quantity' => 1,
            'status' => 'active',
        ]);

        $instructor = User::factory()->create(['role' => 'instructor']);
        $trainee = User::factory()->create(['role' => 'trainee']);

        $trVent = Training::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $manufacturer->id,
            'instructor_id' => $instructor->id,
            'equipment_id' => $eqVent->id,
            'title' => 'Treino vent',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);
        $trPump = Training::query()->create([
            'institution_id' => $inst->id,
            'manufacturer_id' => $manufacturer->id,
            'instructor_id' => $instructor->id,
            'equipment_id' => $eqPump->id,
            'title' => 'Treino pump',
            'type' => 'official',
            'status' => 'finished',
            'join_hash' => Str::lower(Str::random(12)),
            'is_official_template' => false,
        ]);

        Enrollment::query()->create([
            'training_id' => $trVent->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 7.5,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);
        Enrollment::query()->create([
            'training_id' => $trPump->id,
            'user_id' => $trainee->id,
            'status' => 'completed',
            'score' => 8.5,
            'joined_at' => now(),
            'completed_at' => now(),
        ]);

        $token = $admin->createToken('m')->plainTextToken;

        $this->withToken($token)
            ->getJson('/api/manufacturer/dashboard-summary?equipment_id='.$eqVent->id)
            ->assertOk()
            ->assertJsonPath('trainings_count', 1)
            ->assertJsonPath('completion_summary.total_enrollments', 1)
            ->assertJsonPath('avg_score_completed', 7.5);
    }
}
