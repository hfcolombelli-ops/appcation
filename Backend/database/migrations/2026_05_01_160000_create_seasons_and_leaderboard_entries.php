<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('seasons', function (Blueprint $table) {
            $table->id();
            $table->foreignId('manufacturer_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->date('starts_at');
            $table->date('ends_at');
            $table->unsignedInteger('target_trainings')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index(['manufacturer_id', 'starts_at']);
        });

        Schema::create('leaderboard_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('season_id')->constrained()->cascadeOnDelete();
            $table->foreignId('instructor_id')->constrained('users')->cascadeOnDelete();
            $table->unsignedInteger('points')->default(0);
            $table->unsignedSmallInteger('rank')->nullable();
            $table->timestamp('last_computed_at')->nullable();
            $table->timestamps();

            $table->unique(['season_id', 'instructor_id']);
            $table->index(['season_id', 'rank']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('leaderboard_entries');
        Schema::dropIfExists('seasons');
    }
};
