<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <style>
        @page { margin: 36px; }
        body {
            font-family: DejaVu Sans, sans-serif;
            font-size: 13px;
            color: #1a1a2e;
            margin: 0;
        }
        .frame {
            border: 3px solid #0f766e;
            border-radius: 12px;
            padding: 28px 32px;
            min-height: 480px;
            box-sizing: border-box;
        }
        .brand {
            font-size: 22px;
            font-weight: bold;
            color: #0f766e;
            letter-spacing: 0.5px;
        }
        .brand-sub { font-size: 11px; color: #64748b; margin-top: 4px; }
        h1 {
            text-align: center;
            font-size: 26px;
            margin: 28px 0 8px;
            color: #131b2e;
        }
        .subtitle {
            text-align: center;
            font-size: 12px;
            color: #64748b;
            margin-bottom: 24px;
        }
        .row { margin: 10px 0; }
        .label { color: #64748b; font-size: 11px; text-transform: uppercase; letter-spacing: 0.06em; }
        .value { font-size: 15px; font-weight: 600; margin-top: 2px; }
        .code-box {
            margin-top: 20px;
            padding: 14px 16px;
            background: #f0fdfa;
            border: 1px solid #99f6e4;
            border-radius: 8px;
            text-align: center;
        }
        .code { font-size: 18px; font-weight: bold; color: #0f766e; letter-spacing: 0.04em; }
        .footer {
            margin-top: 28px;
            display: table;
            width: 100%;
        }
        .footer-left { display: table-cell; vertical-align: top; width: 65%; font-size: 11px; color: #64748b; line-height: 1.5; }
        .footer-right { display: table-cell; vertical-align: top; text-align: right; width: 35%; }
        .qr { width: 140px; height: 140px; }
        .qr-cap { font-size: 9px; color: #94a3b8; margin-top: 6px; }
    </style>
</head>
<body>
<div class="frame">
    <div class="brand">App²cation</div>
    <div class="brand-sub">Certificado de conclusão de treinamento</div>

    <h1>Certificado</h1>
    <p class="subtitle">Concedido a</p>

    <div class="row">
        <div class="label">Nome</div>
        <div class="value">{{ $certificate->user->name }}</div>
    </div>
    <div class="row">
        <div class="label">Treinamento</div>
        <div class="value">{{ $certificate->training->title }}</div>
    </div>
    @if($certificate->training->institution)
    <div class="row">
        <div class="label">Instituição</div>
        <div class="value">{{ $certificate->training->institution->name }}</div>
    </div>
    @endif
    <div class="row">
        <div class="label">Nota final</div>
        <div class="value">{{ $certificate->score !== null ? number_format((float) $certificate->score, 2, ',', '') : '—' }} / 10</div>
    </div>
    <div class="row">
        <div class="label">Emitido em</div>
        <div class="value">{{ $certificate->issued_at?->timezone(config('app.timezone'))->format('d/m/Y H:i') ?? '—' }}</div>
    </div>
    <div class="row">
        <div class="label">Válido até</div>
        <div class="value">{{ $certificate->expires_at?->timezone(config('app.timezone'))->format('d/m/Y') ?? '—' }}</div>
    </div>

    <div class="code-box">
        <div class="label">Código de validação</div>
        <div class="code">{{ $certificate->certificate_code }}</div>
    </div>

    <div class="footer">
        <div class="footer-left">
            Valide este certificado digitalmente ao ler o código QR ou aceder ao URL de verificação.
            Documento gerado automaticamente — não requer assinatura manuscrita.
        </div>
        <div class="footer-right">
            @if(!empty($qrDataUri))
                <img class="qr" src="{{ $qrDataUri }}" alt="QR">
                <div class="qr-cap">Validar online</div>
            @endif
        </div>
    </div>
</div>
</body>
</html>
