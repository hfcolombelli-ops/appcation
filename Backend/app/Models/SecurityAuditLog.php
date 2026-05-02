<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Http\Request;

class SecurityAuditLog extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'request_id',
        'action',
        'subject_type',
        'subject_id',
        'metadata',
        'ip_address',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'metadata' => 'array',
            'created_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * @param  array<string, mixed>  $metadata
     */
    public static function record(
        Request $request,
        string $action,
        ?string $subjectType = null,
        ?int $subjectId = null,
        array $metadata = [],
    ): void {
        self::query()->create([
            'user_id' => $request->user()?->id,
            'request_id' => $request->attributes->get('request_id'),
            'action' => $action,
            'subject_type' => $subjectType,
            'subject_id' => $subjectId,
            'metadata' => $metadata !== [] ? $metadata : null,
            'ip_address' => $request->ip(),
            'created_at' => now(),
        ]);
    }
}
