<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Em Postgres/MySQL um DEFAULT 'trainee' (ou NOT NULL com default) faz novos utilizadores
 * Google ficarem treinando mesmo quando a API envia role=null — a triagem nunca aparece.
 */
return new class extends Migration
{
    public function up(): void
    {
        $driver = Schema::getConnection()->getDriverName();

        if ($driver === 'pgsql') {
            DB::statement('ALTER TABLE users ALTER COLUMN role DROP DEFAULT');
            DB::statement('ALTER TABLE users ALTER COLUMN role DROP NOT NULL');

            return;
        }

        if ($driver === 'mysql') {
            try {
                DB::statement('ALTER TABLE users ALTER COLUMN role DROP DEFAULT');
            } catch (Throwable) {
                // já sem default ou motor antigo
            }
            DB::statement('ALTER TABLE users MODIFY COLUMN role VARCHAR(255) NULL DEFAULT NULL');

            return;
        }

        // sqlite (CI): já coberto por migrações anteriores; sem operações raw portáveis aqui.
    }

    public function down(): void
    {
        // Sem reversão automática segura entre motores (evita voltar NOT NULL com dados null).
    }
};
