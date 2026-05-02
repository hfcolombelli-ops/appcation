<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('institution_id')->nullable()->after('manufacturer_id')->constrained()->nullOnDelete();
        });

        Schema::create('institution_instructors', function (Blueprint $table) {
            $table->id();
            $table->foreignId('institution_id')->constrained()->cascadeOnDelete();
            $table->foreignId('instructor_id')->constrained('users')->cascadeOnDelete();
            $table->string('status')->default('pending');
            $table->timestamps();
            $table->unique(['institution_id', 'instructor_id']);
        });

        Schema::create('manufacturer_instructors', function (Blueprint $table) {
            $table->id();
            $table->foreignId('manufacturer_id')->constrained()->cascadeOnDelete();
            $table->foreignId('instructor_id')->constrained('users')->cascadeOnDelete();
            $table->string('status')->default('pending');
            $table->boolean('fee_paid')->default(false);
            $table->timestamps();
            $table->unique(['manufacturer_id', 'instructor_id']);
        });

        Schema::create('certificates', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('enrollment_id')->unique()->constrained()->cascadeOnDelete();
            $table->foreignId('training_id')->constrained()->cascadeOnDelete();
            $table->decimal('score', 5, 2)->nullable();
            $table->string('certificate_code')->unique();
            $table->timestamp('issued_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();
        });

        Schema::table('enrollments', function (Blueprint $table) {
            $table->unsignedTinyInteger('repescage_round')->default(0)->after('score');
            $table->boolean('in_recovery')->default(false)->after('repescage_round');
        });

        Schema::table('manufacturers', function (Blueprint $table) {
            $table->string('validation_status')->default('active')->after('status');
        });

        Schema::table('training_requests', function (Blueprint $table) {
            $table->text('notes')->nullable()->after('reason');
            $table->foreignId('assigned_instructor_id')->nullable()->after('requested_by')->constrained('users')->nullOnDelete();
            $table->foreignId('fulfilled_training_id')->nullable()->after('assigned_instructor_id')->constrained('trainings')->nullOnDelete();
        });

        Schema::table('trainings', function (Blueprint $table) {
            $table->boolean('is_official_template')->default(false)->after('type');
            $table->unsignedSmallInteger('passing_score_percent')->default(70)->after('status');
        });

        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            Schema::table('trainings', function (Blueprint $table) {
                $table->dropForeign(['institution_id']);
            });
        }

        Schema::table('trainings', function (Blueprint $table) {
            $table->unsignedBigInteger('institution_id')->nullable()->change();
        });

        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            Schema::table('trainings', function (Blueprint $table) {
                $table->foreign('institution_id')->references('id')->on('institutions')->nullOnDelete();
            });
        }
    }

    public function down(): void
    {
        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            Schema::table('trainings', function (Blueprint $table) {
                $table->dropForeign(['institution_id']);
            });
        }

        Schema::table('trainings', function (Blueprint $table) {
            $table->unsignedBigInteger('institution_id')->nullable(false)->change();
        });

        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            Schema::table('trainings', function (Blueprint $table) {
                $table->foreign('institution_id')->references('id')->on('institutions')->cascadeOnDelete();
            });
        }

        Schema::table('trainings', function (Blueprint $table) {
            $table->dropColumn(['is_official_template', 'passing_score_percent']);
        });

        Schema::table('training_requests', function (Blueprint $table) {
            $table->dropConstrainedForeignId('fulfilled_training_id');
            $table->dropConstrainedForeignId('assigned_instructor_id');
            $table->dropColumn('notes');
        });

        Schema::table('manufacturers', function (Blueprint $table) {
            $table->dropColumn('validation_status');
        });

        Schema::table('enrollments', function (Blueprint $table) {
            $table->dropColumn(['repescage_round', 'in_recovery']);
        });

        Schema::dropIfExists('certificates');
        Schema::dropIfExists('manufacturer_instructors');
        Schema::dropIfExists('institution_instructors');

        Schema::table('users', function (Blueprint $table) {
            $table->dropConstrainedForeignId('institution_id');
        });
    }
};
