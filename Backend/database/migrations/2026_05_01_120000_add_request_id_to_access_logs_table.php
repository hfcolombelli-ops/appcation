<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Correção de ordem: corre depois de create_access_logs em instalações antigas
 * em que esta migração correu antes da tabela existir. Idempotente.
 */
return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('access_logs')) {
            return;
        }

        if (Schema::hasColumn('access_logs', 'request_id')) {
            return;
        }

        Schema::table('access_logs', function (Blueprint $table) {
            $table->uuid('request_id')->nullable()->after('id');
            $table->index('request_id');
        });
    }

    public function down(): void
    {
        if (! Schema::hasTable('access_logs') || ! Schema::hasColumn('access_logs', 'request_id')) {
            return;
        }

        Schema::table('access_logs', function (Blueprint $table) {
            $table->dropIndex(['request_id']);
            $table->dropColumn('request_id');
        });
    }
};
