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
        'firmware_version',
        'serial_number',
        'sector',
        'technical_specs',
        'category',
        'image_stored_path',
        'manual_operator_stored_path',
        'manual_maintenance_stored_path',
        'datasheet_stored_path',
        'intro_video_url',
        'intro_video_stored_path',
        'default_training_hours',
        'default_passing_score_percent',
        'default_certificate_validity_months',
        'default_reassessment_days',
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

    public function trainings(): HasMany
    {
        return $this->hasMany(Training::class, 'equipment_id');
    }

    public function hasChildVersions(): bool
    {
        return $this->childVersions()->exists();
    }

    protected function casts(): array
    {
        return [
            'technical_specs' => 'array',
        ];
    }
}
