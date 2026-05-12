<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * O nome comercial pode repetir entre fabricantes; a unicidade fica no slug
 * e em registration_email_domain. O índice único em `name` gerava 500 silencioso
 * ao segundo registo com o mesmo nome de empresa.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('manufacturers', function (Blueprint $table) {
            $table->dropUnique(['name']);
        });
    }

    public function down(): void
    {
        Schema::table('manufacturers', function (Blueprint $table) {
            $table->unique('name');
        });
    }
};
