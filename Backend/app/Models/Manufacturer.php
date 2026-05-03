<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Manufacturer extends Model
{
    protected $fillable = [
        'name',
        'trade_name',
        'slug',
        'cnpj',
        'state_registration',
        'website',
        'commercial_phone',
        'support_email',
        'registration_email_domain',
        'address_postal_code',
        'address_street',
        'address_neighborhood',
        'address_city',
        'address_state',
        'legal_rep_full_name',
        'legal_rep_cpf',
        'legal_rep_role',
        'legal_rep_phone',
        'declaration_accepted_at',
        'validation_protocol',
        'validation_submitted_at',
        'status',
        'validation_status',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'declaration_accepted_at' => 'datetime',
            'validation_submitted_at' => 'datetime',
        ];
    }

    public function documents(): HasMany
    {
        return $this->hasMany(ManufacturerDocument::class);
    }
}
