<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ManufacturerInstructor extends Model
{
    protected $fillable = [
        'manufacturer_id',
        'instructor_id',
        'status',
        'fee_paid',
        'endorsed_by_institution_id',
        'endorsed_at',
    ];

    protected function casts(): array
    {
        return [
            'fee_paid' => 'boolean',
            'endorsed_at' => 'datetime',
        ];
    }

    public function endorsedByInstitution(): BelongsTo
    {
        return $this->belongsTo(Institution::class, 'endorsed_by_institution_id');
    }

    public function manufacturer(): BelongsTo
    {
        return $this->belongsTo(Manufacturer::class);
    }

    public function instructor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'instructor_id');
    }
}
