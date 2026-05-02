<?php

namespace Tests\Feature;

use Tests\TestCase;

class ApiHealthTest extends TestCase
{
    public function test_health_returns_ok_and_database_check(): void
    {
        $response = $this->getJson('/api/health');

        $response->assertOk()
            ->assertJsonPath('status', 'ok')
            ->assertJsonPath('checks.database.ok', true)
            ->assertJsonStructure([
                'status',
                'app',
                'version',
                'environment',
                'time',
                'checks' => [
                    'database' => [
                        'ok',
                        'latency_ms',
                    ],
                ],
            ]);

        $this->assertNotEmpty($response->headers->get('X-Request-Id'));
    }
}
