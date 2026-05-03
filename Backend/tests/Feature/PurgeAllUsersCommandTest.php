<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\PersonalAccessToken;
use Tests\TestCase;

class PurgeAllUsersCommandTest extends TestCase
{
    use RefreshDatabase;

    public function test_purge_all_users_removes_users_and_tokens(): void
    {
        $u = User::factory()->create();
        $u->createToken('test')->plainTextToken;

        $this->assertSame(1, User::query()->count());
        $this->assertGreaterThan(0, PersonalAccessToken::query()->count());

        $this->artisan('app:purge-all-users', ['--force' => true])
            ->assertSuccessful();

        $this->assertSame(0, User::query()->count());
        $this->assertSame(0, PersonalAccessToken::query()->count());
    }
}
