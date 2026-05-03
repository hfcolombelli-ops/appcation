<?php

namespace App\Mail;

use App\Models\Manufacturer;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class ManufacturerRegistrationApproved extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public function __construct(public Manufacturer $manufacturer) {}

    public function build(): self
    {
        return $this->subject('Cadastro aprovado — App²cation')
            ->text('emails.manufacturer-registration-approved');
    }
}
