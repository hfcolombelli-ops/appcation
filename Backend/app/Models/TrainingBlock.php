<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TrainingBlock extends Model
{
    protected $fillable = [
        'training_id',
        'title',
        'sort_order',
        'is_released',
    ];

    protected function casts(): array
    {
        return [
            'is_released' => 'boolean',
        ];
    }

    public function training(): BelongsTo
    {
        return $this->belongsTo(Training::class);
    }

    public function questions(): HasMany
    {
        return $this->hasMany(Question::class);
    }
}
