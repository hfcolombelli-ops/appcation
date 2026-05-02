<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('manufacturer_instructors', function (Blueprint $table) {
            $table->foreignId('endorsed_by_institution_id')
                ->nullable()
                ->after('fee_paid')
                ->constrained('institutions')
                ->nullOnDelete();
            $table->timestamp('endorsed_at')->nullable()->after('endorsed_by_institution_id');
        });
    }

    public function down(): void
    {
        Schema::table('manufacturer_instructors', function (Blueprint $table) {
            $table->dropConstrainedForeignId('endorsed_by_institution_id');
            $table->dropColumn('endorsed_at');
        });
    }
};
