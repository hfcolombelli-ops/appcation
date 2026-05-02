<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('trainee_profiles', function (Blueprint $table) {
            $table->string('equipment_label')->nullable()->after('institution_id');
            $table->dateTime('session_at')->nullable()->after('equipment_label');
        });
    }

    public function down(): void
    {
        Schema::table('trainee_profiles', function (Blueprint $table) {
            $table->dropColumn(['equipment_label', 'session_at']);
        });
    }
};
