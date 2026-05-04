<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Institution extends Model
{
    protected $fillable = [
        'manufacturer_id',
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
