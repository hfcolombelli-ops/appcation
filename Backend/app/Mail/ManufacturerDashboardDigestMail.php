<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class ManufacturerDashboardDigestMail extends Mailable
{
    use Queueable, SerializesModels;

    /**
     * @param  array<string, mixed>  $data
     */
    public function __construct(
        public string $recipientName,
        public string $manufacturerName,
        public array $data,
        public string $frontendUrl,
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'App²cation — resumo agregado (fabricante)',
        );
    }

    public function content(): Content
    {
        return new Content(
            html: 'emails.manufacturer-dashboard-digest',
            text: 'emails.manufacturer-dashboard-digest-text',
        );
    }
}
