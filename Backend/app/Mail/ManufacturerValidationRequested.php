<?php

namespace App\Mail;

use App\Models\Manufacturer;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class ManufacturerValidationRequested extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public function __construct(public Manufacturer $manufacturer) {}

    public function build(): self
    {
        return $this->subject('Fluxxo: pedido de validação de fabricante')
            ->text('emails.manufacturer-validation-requested');
    }
}
