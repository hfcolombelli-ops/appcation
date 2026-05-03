<?php

namespace App\Services;

use App\Mail\ManufacturerRegistrationApproved;
use App\Mail\ManufacturerValidationRequested;
use App\Mail\NewManufacturerRegistered;
use App\Models\Manufacturer;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

/**
 * E-mails para revisores Fluxxo (MANUFACTURER_REVIEWER_EMAILS), em fila quando o mailable implementa ShouldQueue.
 */
class ManufacturerReviewerNotifier
{
    public static function notifyValidationRequested(Manufacturer $manufacturer): void
    {
        $emails = config('manufacturer.reviewer_emails', []);
        if ($emails === []) {
            return;
        }

        try {
            Mail::to($emails)->send(new ManufacturerValidationRequested($manufacturer));
        } catch (\Throwable $e) {
            Log::warning('manufacturer.validation_requested_mail_failed', ['message' => $e->getMessage()]);
        }
    }

    public static function notifyNewRegistrationIfConfigured(Manufacturer $manufacturer): void
    {
        if (! config('manufacturer.notify_reviewers_on_registration', false)) {
            return;
        }

        $emails = config('manufacturer.reviewer_emails', []);
        if ($emails === []) {
            return;
        }

        try {
            Mail::to($emails)->send(new NewManufacturerRegistered($manufacturer));
        } catch (\Throwable $e) {
            Log::warning('manufacturer.registration_mail_failed', ['message' => $e->getMessage()]);
        }
    }

    public static function notifyManufacturerApproved(Manufacturer $manufacturer): void
    {
        $to = strtolower(trim((string) $manufacturer->support_email));
        if ($to === '') {
            return;
        }

        try {
            Mail::to($to)->send(new ManufacturerRegistrationApproved($manufacturer));
        } catch (\Throwable $e) {
            Log::warning('manufacturer.approved_mail_failed', ['message' => $e->getMessage()]);
        }
    }
}
