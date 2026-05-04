<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('institutions', function (Blueprint $table) {
            $table->foreignId('manufacturer_id')->nullable()->after('id')->constrained('manufacturers')->nullOnDelete();
        });

        Schema::create('invitations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('manufacturer_id')->constrained('manufacturers')->cascadeOnDelete();
            $table->foreignId('institution_id')->nullable()->constrained('institutions')->nullOnDelete();
            $table->foreignId('created_by_user_id')->constrained('users')->cascadeOnDelete();
            $table->string('invited_email', 190);
            $table->string('invited_name', 120)->nullable();
            $table->string('invited_cpf', 14)->nullable();
            $table->string('role', 32);
            $table->string('token_hash', 64)->unique();
            $table->timestamp('expires_at');
            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('revoked_at')->nullable();
            $table->timestamps();

            $table->index(['manufacturer_id', 'invited_email']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->string('cpf', 14)->nullable()->after('phone');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('cpf');
        });

        Schema::dropIfExists('invitations');

        Schema::table('institutions', function (Blueprint $table) {
            $table->dropConstrainedForeignId('manufacturer_id');
        });
    }
};
