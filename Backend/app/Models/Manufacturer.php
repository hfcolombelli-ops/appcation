<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Manufacturer extends Model
{
    protected $fillable = [
        'name',
        'slug',
        'cnpj',
        'support_email',
        'status',
        'validation_status',
    ];
}
