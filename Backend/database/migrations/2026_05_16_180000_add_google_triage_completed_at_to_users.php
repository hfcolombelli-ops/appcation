<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Triagem Google: até o utilizador escolher perfil em PATCH /api/me/role,
 * a app mostra ProfileGate. Contas antigas ficam marcadas como já triadas.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->timestamp('google_triage_completed_at')->nullable()->after('google_sub');
        });

        DB::table('users')->update(['google_triage_completed_at' => now()]);

        // Google + «trainee» sem triagem explícita na BD: voltar a mostrar o cartão de escolha de perfil na app.
        DB::table('users')
            ->whereNotNull('google_sub')
            ->where('role', 'trainee')
            ->update(['google_triage_completed_at' => null]);
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('google_triage_completed_at');
        });
    }
};
