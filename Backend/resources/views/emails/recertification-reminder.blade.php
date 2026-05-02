Olá {{ $certificate->user->name }},

O seu certificado do treinamento «{{ $certificate->training->title }}» está prestes a expirar.

Código do certificado: {{ $certificate->certificate_code }}
Data de validade: {{ $certificate->expires_at?->timezone(config('app.timezone'))->format('d/m/Y') ?? '—' }}

Faltam cerca de {{ $daysBeforeExpiry }} dias para o fim da validade. Planeie a recertificação com a sua instituição ou fabricante, conforme o processo da sua organização.

Pode consultar os seus certificados na área de treinando da aplicação App²cation.

—
{{ config('app.name') }}
@if(config('app.url'))
{{ config('app.url') }}
@endif
