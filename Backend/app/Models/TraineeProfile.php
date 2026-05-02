<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TraineeProfile extends Model
{
    protected $fillable = [
        'user_id',
        'sector',
        'institution_id',
        'equipment_label',
        'session_at',
    ];

    protected function casts(): array
    {
        return [
            'session_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function institution(): BelongsTo
    {
        return $this->belongsTo(Institution::class);
    }
}
