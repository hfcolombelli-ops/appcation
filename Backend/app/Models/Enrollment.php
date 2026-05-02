<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Enrollment extends Model
{
    protected $fillable = [
        'training_id',
        'user_id',
        'status',
        'score',
        'joined_at',
        'completed_at',
    ];
}
