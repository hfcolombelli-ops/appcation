<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserConsent extends Model
{
    protected $fillable = [
        'user_id',
        'consent_type',
        'policy_version',
        'ip_address',
        'user_agent',
        'given_at',
        'revoked_at',
    ];

    protected function casts(): array
    {
        return [
            'given_at' => 'datetime',
            'revoked_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public static function hasActive(User $user, string $consentType): bool
    {
        return static::query()
            ->where('user_id', $user->id)
            ->where('consent_type', $consentType)
            ->whereNull('revoked_at')
            ->exists();
    }
}
