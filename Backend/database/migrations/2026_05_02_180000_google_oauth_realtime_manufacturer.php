<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('manufacturers', function (Blueprint $table) {
            $table->string('cnpj', 20)->nullable()->after('slug');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->string('password')->nullable()->change();
            $table->string('google_sub')->nullable()->unique()->after('password');
            $table->foreignId('manufacturer_id')->nullable()->after('role')->constrained()->nullOnDelete();
        });

        Schema::table('trainings', function (Blueprint $table) {
            $table->unsignedBigInteger('command_seq')->default(0)->after('metadata');
            $table->string('last_command')->nullable()->after('command_seq');
            $table->json('last_command_payload')->nullable()->after('last_command');
        });
    }

    public function down(): void
    {
        Schema::table('trainings', function (Blueprint $table) {
            $table->dropColumn(['command_seq', 'last_command', 'last_command_payload']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropConstrainedForeignId('manufacturer_id');
            $table->dropColumn('google_sub');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->string('password')->nullable(false)->change();
        });

        Schema::table('manufacturers', function (Blueprint $table) {
            $table->dropColumn('cnpj');
        });
    }
};
