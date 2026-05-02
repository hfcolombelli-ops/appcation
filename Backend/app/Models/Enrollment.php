<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Enrollment extends Model
{
    protected $fillable = [
        'training_id',
        'user_id',
        'status',
        'score',
        'joined_at',
        'completed_at',
        'repescage_round',
        'in_recovery',
        'recovery_question_ids',
    ];

    protected function casts(): array
    {
        return [
            'joined_at' => 'datetime',
            'completed_at' => 'datetime',
            'in_recovery' => 'boolean',
            'recovery_question_ids' => 'array',
        ];
    }

    public function training(): BelongsTo
    {
        return $this->belongsTo(Training::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function answers(): HasMany
    {
        return $this->hasMany(Answer::class);
    }

    public function followUps(): HasMany
    {
        return $this->hasMany(EnrollmentFollowUp::class);
    }
}
