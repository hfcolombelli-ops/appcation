<?php

namespace App\Support;

use App\Models\Training;

class FollowUpDefinition
{
    /**
     * @return list<int>
     */
    public static function daysForTraining(Training $training): array
    {
        $meta = ($training->metadata ?? [])['follow_up'] ?? [];
        if (array_key_exists('enabled', $meta) && $meta['enabled'] === false) {
            return [];
        }
        if (! empty($meta['days']) && is_array($meta['days'])) {
            $d = array_values(array_unique(array_filter(
                array_map(static fn ($v): int => (int) $v, $meta['days']),
                static fn (int $v): bool => $v > 0
            )));
            sort($d);

            return $d;
        }
        $defaults = config('follow_up.default_days', []);
        if (! is_array($defaults)) {
            return [];
        }
        $d = array_values(array_unique(array_filter(
            array_map(static fn ($v): int => (int) $v, $defaults),
            static fn (int $v): bool => $v > 0
        )));
        sort($d);

        return $d;
    }

    /**
     * @return list<array<string, mixed>>
     */
    public static function questionsForTraining(Training $training): array
    {
        $meta = ($training->metadata ?? [])['follow_up'] ?? [];
        if (! empty($meta['questions']) && is_array($meta['questions'])) {
            return array_values($meta['questions']);
        }

        $q = config('follow_up.default_questions', []);

        return is_array($q) ? array_values($q) : [];
    }
}
