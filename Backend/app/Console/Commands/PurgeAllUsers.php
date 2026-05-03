<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

/**
 * Apaga todos os utilizadores (`users`). Em bases com FK em cascata, remove também
 * inscrições, treinos (como instrutor), certificados, perfis, etc.
 *
 * Produção: exige ALLOW_PURGE_ALL_USERS=true no ambiente (além de --force).
 */
class PurgeAllUsers extends Command
{
    protected $signature = 'app:purge-all-users {--force : Não pedir confirmação interactiva}';

    protected $description = 'Apaga todos os utilizadores e tokens Sanctum (dados ligados em cascata).';

    public function handle(): int
    {
        if (config('app.env') === 'production' && ! filter_var(env('ALLOW_PURGE_ALL_USERS', false), FILTER_VALIDATE_BOOLEAN)) {
            $this->error('Em produção defina ALLOW_PURGE_ALL_USERS=true no serviço (Railway) antes de correr este comando.');

            return self::FAILURE;
        }

        if (! $this->option('force')) {
            if (! $this->confirm('Apagar TODOS os utilizadores e dados ligados (treinos, inscrições, certificados, …)?')) {
                $this->comment('Cancelado.');

                return self::FAILURE;
            }
        }

        $this->warn('A executar purge de utilizadores…');

        $deleted = 0;

        DB::transaction(function () use (&$deleted): void {
            DB::table('personal_access_tokens')
                ->where('tokenable_type', User::class)
                ->delete();

            DB::table('sessions')->delete();
            DB::table('password_reset_tokens')->delete();

            $deleted = User::query()->delete();
        });

        $this->info("Concluído. Utilizadores apagados: {$deleted}.");

        return self::SUCCESS;
    }
}
