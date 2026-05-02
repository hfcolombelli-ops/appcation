<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Config;
use Tests\TestCase;

class FluxxoRealtimeClientConfigTest extends TestCase
{
    public function test_client_config_when_broadcasting_not_reverb(): void
    {
        Config::set('broadcasting.default', 'null');

        $this->getJson('/api/realtime/client-config')
            ->assertOk()
            ->assertJsonPath('enabled', false)
            ->assertJsonPath('reverb', null);
    }

    public function test_client_config_when_reverb_configured(): void
    {
        Config::set('broadcasting.default', 'reverb');
        Config::set('broadcasting.connections.reverb.key', 'test-app-key');

        $this->getJson('/api/realtime/client-config')
            ->assertOk()
            ->assertJsonPath('enabled', true)
            ->assertJsonPath('reverb.key', 'test-app-key')
            ->assertJsonStructure([
                'reverb' => [
                    'host',
                    'port',
                    'scheme',
                    'use_tls',
                ],
            ]);
    }

    public function test_client_config_uses_broadcasting_client_host(): void
    {
        Config::set('broadcasting.default', 'reverb');
        Config::set('broadcasting.connections.reverb.key', 'test-app-key');
        Config::set('broadcasting.connections.reverb.client_host', 'ws.public.example.test');

        $this->getJson('/api/realtime/client-config')
            ->assertOk()
            ->assertJsonPath('enabled', true)
            ->assertJsonPath('reverb.host', 'ws.public.example.test');
    }
}
