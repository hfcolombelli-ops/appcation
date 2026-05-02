<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Training extends Model
{
    protected $fillable = [
        'institution_id',
        'manufacturer_id',
        'instructor_id',
        'equipment_id',
        'title',
        'type',
        'is_official_template',
        'status',
        'scheduled_at',
        'join_hash',
        'metadata',
        'command_seq',
        'last_command',
        'last_command_payload',
        'passing_score_percent',
    ];

    protected function casts(): array
    {
        return [
            'scheduled_at' => 'datetime',
            'metadata' => 'array',
            'last_command_payload' => 'array',
            'is_official_template' => 'boolean',
        ];
    }

    public function institution(): BelongsTo
    {
        return $this->belongsTo(Institution::class);
    }

    public function manufacturer(): BelongsTo
    {
        return $this->belongsTo(Manufacturer::class);
    }

    public function instructor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'instructor_id');
    }

    public function enrollments(): HasMany
    {
        return $this->hasMany(Enrollment::class);
    }

    public function trainingBlocks(): HasMany
    {
        return $this->hasMany(TrainingBlock::class);
    }
}
