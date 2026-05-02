<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class InstitutionDashboardDigestMail extends Mailable
{
    use Queueable, SerializesModels;

    /**
     * @param  array<string, mixed>  $data
     */
    public function __construct(
        public string $recipientName,
        public string $institutionName,
        public array $data,
        public string $frontendUrl,
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'App²cation — resumo agregado (instituição)',
        );
    }

    public function content(): Content
    {
        return new Content(
            html: 'emails.institution-dashboard-digest',
            text: 'emails.institution-dashboard-digest-text',
        );
    }
}
