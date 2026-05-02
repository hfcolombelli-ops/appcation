<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('recertification_reminder_sends', function (Blueprint $table) {
            $table->id();
            $table->foreignId('certificate_id')->constrained()->cascadeOnDelete();
            $table->unsignedSmallInteger('days_before_expiry');
            $table->timestamp('sent_at');
            $table->timestamps();

            $table->unique(['certificate_id', 'days_before_expiry']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('recertification_reminder_sends');
    }
};
