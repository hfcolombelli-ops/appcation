<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('equipment', function (Blueprint $table) {
            $table->string('firmware_version', 80)->nullable()->after('model');
            $table->string('serial_number', 120)->nullable()->after('firmware_version');
            $table->json('technical_specs')->nullable()->after('sector');
            $table->string('image_stored_path', 500)->nullable()->after('technical_specs');
            $table->string('manual_operator_stored_path', 500)->nullable()->after('image_stored_path');
            $table->string('manual_maintenance_stored_path', 500)->nullable()->after('manual_operator_stored_path');
            $table->string('datasheet_stored_path', 500)->nullable()->after('manual_maintenance_stored_path');
            $table->string('intro_video_url', 500)->nullable()->after('datasheet_stored_path');
            $table->string('intro_video_stored_path', 500)->nullable()->after('intro_video_url');
            $table->unsignedSmallInteger('default_training_hours')->nullable()->after('intro_video_stored_path');
            $table->unsignedTinyInteger('default_passing_score_percent')->nullable()->after('default_training_hours');
            $table->unsignedSmallInteger('default_certificate_validity_months')->nullable()->after('default_passing_score_percent');
            $table->unsignedSmallInteger('default_reassessment_days')->nullable()->after('default_certificate_validity_months');
        });
    }

    public function down(): void
    {
        Schema::table('equipment', function (Blueprint $table) {
            $table->dropColumn([
                'firmware_version',
                'serial_number',
                'technical_specs',
                'image_stored_path',
                'manual_operator_stored_path',
                'manual_maintenance_stored_path',
                'datasheet_stored_path',
                'intro_video_url',
                'intro_video_stored_path',
                'default_training_hours',
                'default_passing_score_percent',
                'default_certificate_validity_months',
                'default_reassessment_days',
            ]);
        });
    }
};
