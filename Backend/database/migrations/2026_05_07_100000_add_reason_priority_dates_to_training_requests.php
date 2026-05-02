<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('training_requests', function (Blueprint $table) {
            $table->string('reason_code', 48)->nullable()->after('reason');
            $table->string('priority', 24)->default('normal')->after('reason_code');
            $table->date('latest_acceptable_date')->nullable()->after('desired_date');
        });
    }

    public function down(): void
    {
        Schema::table('training_requests', function (Blueprint $table) {
            $table->dropColumn(['reason_code', 'priority', 'latest_acceptable_date']);
        });
    }
};
