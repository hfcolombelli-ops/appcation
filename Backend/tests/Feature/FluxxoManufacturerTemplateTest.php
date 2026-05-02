<?php

namespace Tests\Feature;

use App\Models\Manufacturer;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class FluxxoManufacturerTemplateTest extends TestCase
{
    use RefreshDatabase;

    /**
     * @return array{0: User, 1: string}
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

        return [$user, $user->createToken('test')->plainTextToken];
    }

    public function test_manufacturer_lists_templates_and_can_sync_questionnaire(): void
    {
        [, $token] = $this->manufacturerAdminWithToken();

        $this->withToken($token)
            ->getJson('/api/trainings?templates_only=1')
            ->assertOk()
            ->assertJsonCount(0);

        $create = $this->withToken($token)->postJson('/api/trainings', [
            'title' => 'Ventilação básica',
            'type' => 'official',
            'is_official_template' => true,
            'passing_score_percent' => 70,
            'status' => 'draft',
        ]);

        $create->assertCreated();
        $tid = $create->json('id');
        $this->assertNotNull($tid);

        $this->withToken($token)
            ->getJson('/api/trainings?templates_only=1')
            ->assertOk()
            ->assertJsonCount(1);

        $payload = [
            'blocks' => [
                [
                    'title' => 'Conteúdo oficial',
                    'sort_order' => 1,
                    'questions' => [
                        [
                            'prompt' => 'Pergunta 1?',
                            'sort_order' => 1,
                            'options' => [
                                ['label' => 'A', 'is_correct' => false, 'sort_order' => 1],
                                ['label' => 'B', 'is_correct' => true, 'sort_order' => 2],
                            ],
                        ],
                    ],
                ],
            ],
        ];

        $this->withToken($token)
            ->postJson("/api/trainings/{$tid}/questionnaire", $payload)
            ->assertOk();

        $show = $this->withToken($token)->getJson("/api/trainings/{$tid}/questionnaire");
        $show->assertOk();
        $show->assertJsonCount(1);
        $first = $show->json('0');
        $this->assertSame('Pergunta 1?', $first['prompt']);
        $opts = $first['options'];
        $this->assertCount(2, $opts);
        $b = collect($opts)->firstWhere('label', 'B');
        $this->assertNotNull($b);
        $this->assertTrue($b['is_correct']);
    }
}
