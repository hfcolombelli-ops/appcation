<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Question extends Model
{
    protected $fillable = [
        'training_block_id',
        'type',
        'prompt',
        'sort_order',
        'is_required',
        'recovery_variant_group',
    ];

    public function trainingBlock(): BelongsTo
    {
        return $this->belongsTo(TrainingBlock::class);
    }

    public function options(): HasMany
    {
        return $this->hasMany(QuestionOption::class);
    }
}
