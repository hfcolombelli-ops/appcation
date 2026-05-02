Olá {{ $recipientName }},

Resumo agregado — fabricante {{ $manufacturerName }}.

Treinos: {{ $data['trainings_count'] ?? '—' }}
Encerrados: {{ $data['finished_trainings_count'] ?? '—' }}
@php $cs = $data['completion_summary'] ?? []; @endphp
Total inscrições: {{ $cs['total_enrollments'] ?? '—' }}
Concluídas: {{ $cs['completed_count'] ?? '—' }}
Taxa conclusão (%): {{ $cs['completion_rate_percent'] ?? '—' }}
Média notas: {{ $data['avg_score_completed'] ?? '—' }}

App: {{ $frontendUrl }}
