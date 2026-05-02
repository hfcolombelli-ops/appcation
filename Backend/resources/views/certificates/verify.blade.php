<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Validação de certificado — App²cation</title>
    <style>
        body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; background: #f8fafc; margin: 0; padding: 24px; color: #0f172a; }
        .card { max-width: 520px; margin: 40px auto; background: #fff; border-radius: 16px; padding: 28px 32px; box-shadow: 0 4px 24px rgba(15,23,42,.08); border: 1px solid #e2e8f0; }
        h1 { font-size: 1.35rem; margin: 0 0 8px; }
        .ok { color: #059669; }
        .bad { color: #dc2626; }
        dl { margin: 20px 0 0; }
        dt { font-size: 0.75rem; text-transform: uppercase; letter-spacing: .06em; color: #64748b; margin-top: 14px; }
        dd { margin: 4px 0 0; font-weight: 600; font-size: 1rem; }
        .code { font-family: ui-monospace, monospace; font-size: 0.95rem; word-break: break-all; }
        .exp { margin-top: 16px; padding: 10px 12px; border-radius: 8px; font-size: 0.9rem; }
        .exp.warn { background: #fffbeb; border: 1px solid #fcd34d; color: #92400e; }
    </style>
</head>
<body>
<div class="card">
    @if(!$valid)
        <h1 class="bad">Código não encontrado</h1>
        <p>O código indicado não corresponde a um certificado registado. Verifique o URL ou o código de validação.</p>
    @else
        <h1 class="ok">Certificado válido</h1>
        <p style="color:#64748b; margin:0;">Este código confirma a conclusão do treinamento indicado abaixo.</p>
        <dl>
            <dt>Código</dt>
            <dd class="code">{{ $certificate->certificate_code }}</dd>
            <dt>Nome</dt>
            <dd>{{ $certificate->user->name }}</dd>
            <dt>Treinamento</dt>
            <dd>{{ $certificate->training->title }}</dd>
            @if($certificate->training->institution)
            <dt>Instituição</dt>
            <dd>{{ $certificate->training->institution->name }}</dd>
            @endif
            <dt>Nota</dt>
            <dd>{{ $certificate->score !== null ? number_format((float) $certificate->score, 2, ',', '') : '—' }} / 10</dd>
            <dt>Emitido em</dt>
            <dd>{{ $certificate->issued_at?->timezone(config('app.timezone'))->format('d/m/Y H:i') ?? '—' }}</dd>
            <dt>Válido até</dt>
            <dd>{{ $certificate->expires_at?->timezone(config('app.timezone'))->format('d/m/Y') ?? '—' }}</dd>
        </dl>
        @if($certificate->expires_at && $certificate->expires_at->isPast())
            <div class="exp warn">Este certificado está fora do período de validade indicado.</div>
        @endif
    @endif
</div>
</body>
</html>
