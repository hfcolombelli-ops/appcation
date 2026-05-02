<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TrainingBlock extends Model
{
    protected $fillable = [
        'training_id',
        'title',
        'sort_order',
        'is_released',
    ];
}
