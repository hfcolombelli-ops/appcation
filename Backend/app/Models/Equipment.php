<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Equipment extends Model
{
    protected $table = 'equipment';

    protected $fillable = [
        'institution_id',
        'manufacturer_id',
        'parent_equipment_id',
        'catalog_equipment_id',
        'name',
        'model',
        'sector',
        'category',
        'quantity',
        'status',
    ];

    public function manufacturer(): BelongsTo
    {
        return $this->belongsTo(Manufacturer::class);
    }

    public function institution(): BelongsTo
    {
        return $this->belongsTo(Institution::class);
    }

    /** Modelo do catálogo do fabricante (institution_id nulo no registo referenciado). */
    public function catalogTemplate(): BelongsTo
    {
        return $this->belongsTo(self::class, 'catalog_equipment_id');
    }

    public function parent(): BelongsTo
    {
        return $this->belongsTo(self::class, 'parent_equipment_id');
    }

    public function childVersions(): HasMany
    {
        return $this->hasMany(self::class, 'parent_equipment_id');
    }

    public function hasChildVersions(): bool
    {
        return $this->childVersions()->exists();
    }
}
