<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TrainingRequest extends Model
{
    protected $fillable = [
        'institution_id',
        'requested_by',
        'equipment_id',
        'desired_date',
        'latest_acceptable_date',
        'status',
        'reason',
        'reason_code',
        'priority',
        'notes',
        'assigned_instructor_id',
        'fulfilled_training_id',
    ];

    protected $appends = [
        'reason_label',
        'priority_label',
    ];

    protected function casts(): array
    {
        return [
            'desired_date' => 'date',
            'latest_acceptable_date' => 'date',
        ];
    }

    public function getReasonLabelAttribute(): ?string
    {
        if ($this->reason_code === null || $this->reason_code === '') {
            return null;
        }
        $hit = collect(config('training_requests.reason_codes', []))->firstWhere('id', $this->reason_code);

        return is_array($hit) ? (string) ($hit['label'] ?? $this->reason_code) : (string) $this->reason_code;
    }

    public function getPriorityLabelAttribute(): ?string
    {
        $p = $this->priority ?? 'normal';
        $hit = collect(config('training_requests.priorities', []))->firstWhere('id', $p);

        return is_array($hit) ? (string) ($hit['label'] ?? $p) : (string) $p;
    }

    public function institution(): BelongsTo
    {
        return $this->belongsTo(Institution::class);
    }

    public function requester(): BelongsTo
    {
        return $this->belongsTo(User::class, 'requested_by');
    }

    public function assignedInstructor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_instructor_id');
    }

    public function fulfilledTraining(): BelongsTo
    {
        return $this->belongsTo(Training::class, 'fulfilled_training_id');
    }

    /** Unidade do parque institucional (quando indicada no pedido). */
    public function equipment(): BelongsTo
    {
        return $this->belongsTo(Equipment::class, 'equipment_id');
    }
}
