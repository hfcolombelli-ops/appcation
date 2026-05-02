<?php

namespace App\Console\Commands;

use App\Mail\RecertificationReminder;
use App\Models\Certificate;
use App\Models\RecertificationReminderSend;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Mail;

class SendRecertificationReminders extends Command
{
    protected $signature = 'certificates:send-recertification-reminders {--dry-run : Apenas listar, sem enviar}';

    protected $description = 'Envia e-mails de lembrete de recertificação (dias antes da expiração configuráveis).';

    public function handle(): int
    {
        if (! config('app.recertification_reminders_enabled', true)) {
            $this->info('Lembretes desactivados (config).');

            return self::SUCCESS;
        }

        $daysList = config('app.recertification_reminder_days', [30, 7]);
        if ($daysList === [] || $daysList === null) {
            $daysList = [30, 7];
        }

        $dry = (bool) $this->option('dry-run');
        $sent = 0;

        foreach ($daysList as $days) {
            $days = (int) $days;
            if ($days <= 0) {
                continue;
            }

            $query = Certificate::query()
                ->whereNotNull('expires_at')
                ->where('expires_at', '>', now())
                ->whereDate('expires_at', now()->addDays($days))
                ->whereDoesntHave('recertificationReminderSends', function ($q) use ($days): void {
                    $q->where('days_before_expiry', $days);
                })
                ->with(['user', 'training']);

            $count = $query->count();
            if ($count === 0) {
                continue;
            }

            $this->info("Janela {$days} dias: {$count} certificado(s).");

            foreach ($query->cursor() as $certificate) {
                $email = $certificate->user?->email;
                if ($email === null || trim($email) === '') {
                    $this->warn("Certificado #{$certificate->id}: utilizador sem e-mail, ignorado.");

                    continue;
                }

                if ($dry) {
                    $this->line("  [dry-run] {$email} — {$certificate->certificate_code}");

                    continue;
                }

                Mail::to($email)->send(new RecertificationReminder($certificate, $days));

                RecertificationReminderSend::query()->create([
                    'certificate_id' => $certificate->id,
                    'days_before_expiry' => $days,
                    'sent_at' => now(),
                ]);
                $sent++;
            }
        }

        if (! $dry) {
            $this->info("Concluído. Envios registados: {$sent}.");
        }

        return self::SUCCESS;
    }
}
