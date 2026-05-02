<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('enrollment_follow_ups', function (Blueprint $table) {
            $table->id();
            $table->foreignId('enrollment_id')->constrained()->cascadeOnDelete();
            $table->unsignedSmallInteger('days_offset');
            $table->timestamp('due_at');
            $table->string('status', 24)->default('pending');
            $table->json('responses')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->index(['enrollment_id', 'status']);
            $table->unique(['enrollment_id', 'days_offset']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('enrollment_follow_ups');
    }
};
