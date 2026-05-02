<?php

namespace App\Mail;

use App\Models\Manufacturer;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

/**
 * Opcional: enviado no registo de conta fabricante (e-mail + fila), se
 * MANUFACTURER_NOTIFY_ON_REGISTRATION=true e MANUFACTURER_REVIEWER_EMAILS definido.
 */
class NewManufacturerRegistered extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public function __construct(public Manufacturer $manufacturer) {}

    public function build(): self
    {
        return $this->subject('Fluxxo: nova conta de fabricante registada')
            ->text('emails.new-manufacturer-registered');
    }
}
