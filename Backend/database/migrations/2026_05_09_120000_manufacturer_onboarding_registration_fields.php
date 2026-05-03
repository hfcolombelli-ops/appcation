<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('manufacturers', function (Blueprint $table) {
            $table->string('registration_email_domain', 190)->nullable()->unique()->after('support_email');
            $table->string('trade_name', 180)->nullable()->after('name');
            $table->string('state_registration', 32)->nullable()->after('cnpj');
            $table->string('website', 255)->nullable();
            $table->string('commercial_phone', 32)->nullable();
            $table->string('address_postal_code', 16)->nullable();
            $table->string('address_street', 255)->nullable();
            $table->string('address_neighborhood', 120)->nullable();
            $table->string('address_city', 120)->nullable();
            $table->string('address_state', 2)->nullable();
            $table->string('legal_rep_full_name', 180)->nullable();
            $table->string('legal_rep_cpf', 14)->nullable();
            $table->string('legal_rep_role', 120)->nullable();
            $table->string('legal_rep_phone', 32)->nullable();
            $table->timestamp('declaration_accepted_at')->nullable();
            $table->string('validation_protocol', 32)->nullable()->unique();
            $table->timestamp('validation_submitted_at')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('manufacturers', function (Blueprint $table) {
            $table->dropColumn([
                'registration_email_domain',
                'trade_name',
                'state_registration',
                'website',
                'commercial_phone',
                'address_postal_code',
                'address_street',
                'address_neighborhood',
                'address_city',
                'address_state',
                'legal_rep_full_name',
                'legal_rep_cpf',
                'legal_rep_role',
                'legal_rep_phone',
                'declaration_accepted_at',
                'validation_protocol',
                'validation_submitted_at',
            ]);
        });
    }
};
