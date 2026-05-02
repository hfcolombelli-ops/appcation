<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Institution extends Model
{
    protected $fillable = [
        'name',
        'legal_name',
        'cnpj',
        'email',
        'phone',
        'city',
        'state',
        'status',
    ];
}
