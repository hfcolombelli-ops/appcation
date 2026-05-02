Olá {{ $recipientName }},

Resumo agregado — {{ $institutionName }} (LGPD, sem identificação individual).

Treinos: {{ $data['trainings_count'] ?? '—' }}
Pedidos pendentes: {{ $data['pending_training_requests'] ?? '—' }}
@php $cs = $data['completion_summary'] ?? []; @endphp
Total inscrições: {{ $cs['total_enrollments'] ?? '—' }}
Concluídas: {{ $cs['completed_count'] ?? '—' }}
Taxa conclusão (%): {{ $cs['completion_rate_percent'] ?? '—' }}
Média notas: {{ $data['avg_score_completed'] ?? '—' }}

App: {{ $frontendUrl }}
