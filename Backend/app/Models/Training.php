<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Training extends Model
{
    protected $fillable = [
        'institution_id',
        'manufacturer_id',
        'instructor_id',
        'equipment_id',
        'title',
        'type',
        'status',
        'scheduled_at',
        'join_hash',
    ];
}
