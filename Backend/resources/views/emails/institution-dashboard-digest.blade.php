<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: system-ui, -apple-system, sans-serif; font-size: 14px; color: #222; line-height: 1.45;">
  <p>Olá {{ $recipientName }},</p>
  <p>Segue o <strong>resumo agregado</strong> da instituição <strong>{{ $institutionName }}</strong> (dados sem identificação individual — LGPD).</p>

  @php $cs = $data['completion_summary'] ?? []; @endphp
  <table cellpadding="8" cellspacing="0" style="border-collapse: collapse; margin: 12px 0;">
    <tr style="background: #f0f4f6;"><th align="left">Indicador</th><th align="left">Valor</th></tr>
    <tr><td>Treinos (instituição)</td><td>{{ $data['trainings_count'] ?? '—' }}</td></tr>
    <tr><td>Pedidos pendentes</td><td>{{ $data['pending_training_requests'] ?? '—' }}</td></tr>
    <tr><td>Total inscrições</td><td>{{ $cs['total_enrollments'] ?? '—' }}</td></tr>
    <tr><td>Concluídas</td><td>{{ $cs['completed_count'] ?? '—' }}</td></tr>
    <tr><td>Taxa conclusão (%)</td><td>{{ $cs['completion_rate_percent'] ?? '—' }}</td></tr>
    <tr><td>Média notas (concluídos)</td><td>{{ $data['avg_score_completed'] ?? '—' }}</td></tr>
  </table>

  <p><a href="{{ $frontendUrl }}" style="color: #00677D;">Abrir App²cation</a> para exportar CSV/PDF ou ver detalhes.</p>
  <p style="font-size: 12px; color: #666;">Mensagem automática — não responda a este e-mail.</p>
</body>
</html>
