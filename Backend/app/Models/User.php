<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['name', 'email', 'password', 'google_sub', 'google_triage_completed_at', 'role', 'phone', 'cpf', 'avatar_url', 'manufacturer_id', 'institution_id', 'weekly_dashboard_digest'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'weekly_dashboard_digest' => 'boolean',
            'google_triage_completed_at' => 'datetime',
        ];
    }

    /** @var list<string> */
    private const APP_MAPPED_ROLES = ['trainee', 'instructor', 'institution_admin', 'manufacturer_admin'];

    public function appRoleIsMapped(): bool
    {
        $role = $this->role;
        if ($role === null) {
            return false;
        }
        $r = trim((string) $role);

        return $r !== '' && in_array($r, self::APP_MAPPED_ROLES, true);
    }

    /**
     * Cliente (Flutter): mostrar ProfileGate antes de qualquer shell por papel.
     */
    public function needsProfileGateForApi(): bool
    {
        if (! $this->appRoleIsMapped()) {
            return true;
        }

        return $this->google_sub !== null && $this->google_triage_completed_at === null;
    }

    /**
     * @return array<string, mixed>
     */
    public function toApiArray(): array
    {
        $data = $this->toArray();
        $data['role'] = $this->role;
        $data['needs_profile_gate'] = $this->needsProfileGateForApi();
        $email = strtolower(trim((string) $this->email));
        $data['can_review_manufacturers'] = $email !== ''
            && in_array($email, config('manufacturer.reviewer_emails', []), true);

        return $data;
    }
}
