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

    public function test_templates_list_rejects_invalid_sort(): void
    {
        [, $token] = $this->manufacturerAdminWithToken();

        $this->withToken($token)
            ->getJson('/api/trainings?templates_only=1&sort=invalid')
            ->assertStatus(422);
    }

    public function test_templates_list_rejects_invalid_status(): void
    {
        [, $token] = $this->manufacturerAdminWithToken();

        $this->withToken($token)
            ->getJson('/api/trainings?templates_only=1&status=archived')
            ->assertStatus(422);
    }

    public function test_templates_list_search_by_title(): void
    {
        [, $token] = $this->manufacturerAdminWithToken();

        $this->withToken($token)->postJson('/api/trainings', [
            'title' => 'Ventilação básica',
            'type' => 'official',
            'is_official_template' => true,
            'passing_score_percent' => 70,
            'status' => 'draft',
        ])->assertCreated();

        $this->withToken($token)->postJson('/api/trainings', [
            'title' => 'Outro curso',
            'type' => 'official',
            'is_official_template' => true,
            'passing_score_percent' => 70,
            'status' => 'draft',
        ])->assertCreated();

        $this->withToken($token)
            ->getJson('/api/trainings?templates_only=1&search=ventila')
            ->assertOk()
            ->assertJsonCount(1)
            ->assertJsonFragment(['title' => 'Ventilação básica']);
    }

    public function test_templates_list_rejects_search_too_long(): void
    {
        [, $token] = $this->manufacturerAdminWithToken();
        $long = str_repeat('x', 121);
        $this->withToken($token)
            ->getJson('/api/trainings?templates_only=1&search='.urlencode($long))
            ->assertStatus(422);
    }

    public function test_templates_list_sort_title_asc(): void
    {
        [, $token] = $this->manufacturerAdminWithToken();

        $this->withToken($token)->postJson('/api/trainings', [
            'title' => 'Zebra',
            'type' => 'official',
            'is_official_template' => true,
            'passing_score_percent' => 70,
            'status' => 'draft',
        ])->assertCreated();

        $this->withToken($token)->postJson('/api/trainings', [
            'title' => 'Alpha',
            'type' => 'official',
            'is_official_template' => true,
            'passing_score_percent' => 70,
            'status' => 'draft',
        ])->assertCreated();

        $titles = collect(
            $this->withToken($token)
                ->getJson('/api/trainings?templates_only=1&sort=title_asc')
                ->assertOk()
                ->json()
        )->pluck('title')->all();

        $this->assertSame('Alpha', $titles[0] ?? null);
        $this->assertContains('Zebra', $titles);
    }

    public function test_templates_list_filter_by_status(): void
    {
        [, $token] = $this->manufacturerAdminWithToken();

        $this->withToken($token)->postJson('/api/trainings', [
            'title' => 'Rascunho',
            'type' => 'official',
            'is_official_template' => true,
            'passing_score_percent' => 70,
            'status' => 'draft',
        ])->assertCreated();

        $this->withToken($token)->postJson('/api/trainings', [
            'title' => 'Agendado',
            'type' => 'official',
            'is_official_template' => true,
            'passing_score_percent' => 70,
            'status' => 'scheduled',
            'scheduled_at' => now()->addDay()->toIso8601String(),
        ])->assertCreated();

        $this->withToken($token)
            ->getJson('/api/trainings?templates_only=1&status=draft')
            ->assertOk()
            ->assertJsonCount(1)
            ->assertJsonFragment(['title' => 'Rascunho']);
    }

    public function test_manufacturer_can_get_questionnaire_for_own_template(): void
    {
        [, $token] = $this->manufacturerAdminWithToken();

        $tid = $this->withToken($token)->postJson('/api/trainings', [
            'title' => 'Template Q',
            'type' => 'official',
            'is_official_template' => true,
            'passing_score_percent' => 70,
            'status' => 'draft',
        ])->assertCreated()->json('id');

        $this->withToken($token)
            ->getJson('/api/trainings/'.$tid.'/questionnaire')
            ->assertOk()
            ->assertJsonCount(0);
    }

    public function test_questionnaire_sync_accepts_more_than_four_options(): void
    {
        [, $token] = $this->manufacturerAdminWithToken();

        $tid = $this->withToken($token)->postJson('/api/trainings', [
            'title' => 'Multi-option template',
            'type' => 'official',
            'is_official_template' => true,
            'passing_score_percent' => 70,
            'status' => 'draft',
        ])->assertCreated()->json('id');

        $options = [];
        foreach (range(1, 6) as $i) {
            $options[] = [
                'label' => 'Opt '.$i,
                'is_correct' => $i === 3,
                'sort_order' => $i,
            ];
        }

        $this->withToken($token)
            ->postJson('/api/trainings/'.$tid.'/questionnaire', [
                'blocks' => [
                    [
                        'title' => 'Bloco',
                        'sort_order' => 1,
                        'questions' => [
                            [
                                'prompt' => 'Escolha uma',
                                'sort_order' => 1,
                                'options' => $options,
                            ],
                        ],
                    ],
                ],
            ])
            ->assertOk();

        $show = $this->withToken($token)->getJson('/api/trainings/'.$tid.'/questionnaire');
        $show->assertOk();
        $first = $show->json('0');
        $this->assertSame('Escolha uma', $first['prompt']);
        $this->assertCount(6, $first['options']);
    }

    public function test_manufacturer_questionnaire_get_orders_by_block_then_question(): void
    {
        [, $token] = $this->manufacturerAdminWithToken();

        $tid = $this->withToken($token)->postJson('/api/trainings', [
            'title' => 'Multi-block template',
            'type' => 'official',
            'is_official_template' => true,
            'passing_score_percent' => 70,
            'status' => 'draft',
        ])->assertCreated()->json('id');

        $this->withToken($token)->postJson("/api/trainings/{$tid}/questionnaire", [
            'blocks' => [
                [
                    'title' => 'Primeiro bloco',
                    'sort_order' => 1,
                    'questions' => [
                        [
                            'prompt' => 'Q1',
                            'sort_order' => 1,
                            'options' => [
                                ['label' => 'A', 'is_correct' => true, 'sort_order' => 1],
                                ['label' => 'B', 'is_correct' => false, 'sort_order' => 2],
                            ],
                        ],
                    ],
                ],
                [
                    'title' => 'Segundo bloco',
                    'sort_order' => 2,
                    'questions' => [
                        [
                            'prompt' => 'Q2',
                            'sort_order' => 1,
                            'options' => [
                                ['label' => 'X', 'is_correct' => true, 'sort_order' => 1],
                                ['label' => 'Y', 'is_correct' => false, 'sort_order' => 2],
                            ],
                        ],
                    ],
                ],
            ],
        ])->assertOk();

        $show = $this->withToken($token)->getJson("/api/trainings/{$tid}/questionnaire");
        $show->assertOk();
        $show->assertJsonCount(2);
        $show->assertJsonPath('0.prompt', 'Q1');
        $show->assertJsonPath('0.training_block.title', 'Primeiro bloco');
        $show->assertJsonPath('1.prompt', 'Q2');
        $show->assertJsonPath('1.training_block.title', 'Segundo bloco');
    }
}
