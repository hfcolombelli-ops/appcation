<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ManufacturerDocument extends Model
{
    protected $fillable = [
        'manufacturer_id',
        'stored_path',
        'original_filename',
        'mime_type',
        'size_bytes',
        'document_kind',
        'notes',
    ];

    public function manufacturer(): BelongsTo
    {
        return $this->belongsTo(Manufacturer::class);
    }
}
