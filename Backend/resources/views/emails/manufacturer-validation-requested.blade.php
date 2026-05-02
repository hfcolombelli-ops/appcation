Pedido de validação Fluxxo (ArtMed / documento Roberto)

Fabricante: {{ $manufacturer->name }}
ID: {{ $manufacturer->id }}
CNPJ: {{ $manufacturer->cnpj ?? '—' }}
E-mail suporte: {{ $manufacturer->support_email ?? '—' }}

Revise na aplicação (área Revisão Fluxxo) ou via API PATCH /api/manufacturer/reviews/{{ $manufacturer->id }}
