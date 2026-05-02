<?php

namespace App\Mail;

use App\Models\Certificate;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class RecertificationReminder extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public Certificate $certificate,
        public int $daysBeforeExpiry,
    ) {
        $this->certificate->loadMissing(['user', 'training']);
    }

    public function build(): self
    {
        return $this->subject('App²cation: lembrete de recertificação do seu certificado')
            ->text('emails.recertification-reminder');
    }
}
