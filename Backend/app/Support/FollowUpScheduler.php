<?php

namespace App\Support;

use App\Models\Enrollment;
use App\Models\EnrollmentFollowUp;
use App\Models\Training;

class FollowUpScheduler
{
    public static function schedule(Enrollment $enrollment): void
    {
        if ($enrollment->status !== 'completed' || $enrollment->completed_at === null) {
            return;
        }

        if (EnrollmentFollowUp::query()->where('enrollment_id', $enrollment->id)->exists()) {
            return;
        }

        $training = $enrollment->relationLoaded('training')
            ? $enrollment->training
            : Training::query()->find($enrollment->training_id);

        if ($training === null) {
            return;
        }

        $days = FollowUpDefinition::daysForTraining($training);
        if ($days === []) {
            return;
        }

        $base = $enrollment->completed_at->copy()->timezone(config('app.timezone'))->startOfDay();

        foreach ($days as $d) {
            $d = (int) $d;
            EnrollmentFollowUp::query()->create([
                'enrollment_id' => $enrollment->id,
                'days_offset' => $d,
                'due_at' => $base->copy()->addDays($d)->setTime(9, 0),
                'status' => 'pending',
            ]);
        }
    }
}
