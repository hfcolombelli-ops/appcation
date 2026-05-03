<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: DejaVu Sans, sans-serif; font-size: 11px; color: #222; }
    h1 { font-size: 18px; color: #00677D; margin: 0 0 4px 0; }
    h2 { font-size: 13px; margin: 16px 0 8px 0; color: #333; }
    .muted { color: #555; font-size: 10px; margin-bottom: 16px; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 8px; }
    th, td { border: 1px solid #ccc; padding: 6px 8px; text-align: left; }
    th { background: #f0f4f6; font-weight: bold; }
    .summary td:first-child { width: 42%; font-weight: bold; background: #f9fafb; }
  </style>
</head>
<body>
  <h1>App²cation — relatório agregado (fabricante)</h1>
  <p class="muted">Fabricante: <strong>{{ $manufacturerName }}</strong><br>
    Gerado em (UTC): {{ $generatedAt->toIso8601String() }}<br>
    Dados agregados — sem identificação de participantes (LGPD).@if(!empty($filterCaption))<br>
    <strong>Filtros:</strong> {{ $filterCaption }}@endif</p>

  @php
    $cs = $data['completion_summary'] ?? [];
  @endphp

  <h2>Resumo</h2>
  <table class="summary">
    <tr><td>Treinos (total)</td><td>{{ $data['trainings_count'] ?? '—' }}</td></tr>
    <tr><td>Treinos encerrados</td><td>{{ $data['finished_trainings_count'] ?? '—' }}</td></tr>
    <tr><td>Total inscrições</td><td>{{ $cs['total_enrollments'] ?? '—' }}</td></tr>
    <tr><td>Inscrições concluídas</td><td>{{ $cs['completed_count'] ?? '—' }}</td></tr>
    <tr><td>Taxa conclusão (%)</td><td>{{ $cs['completion_rate_percent'] ?? '—' }}</td></tr>
    <tr><td>Média notas (concluídos)</td><td>{{ $data['avg_score_completed'] ?? '—' }}</td></tr>
  </table>

  <h2>Por instituição</h2>
  <table>
    <thead>
      <tr>
        <th>Instituição</th>
        <th>Treinos</th>
        <th>Inscrições</th>
        <th>Concluídas</th>
        <th>Taxa conclusão (%)</th>
        <th>Média notas</th>
      </tr>
    </thead>
    <tbody>
      @forelse(($data['aggregated_by_institution'] ?? []) as $row)
        @php $r = is_array($row) ? $row : (array) $row; @endphp
        <tr>
          <td>{{ $r['label'] ?? '—' }}</td>
          <td>{{ $r['trainings_count'] ?? '—' }}</td>
          <td>{{ $r['total_enrollments'] ?? '—' }}</td>
          <td>{{ $r['completed_count'] ?? '—' }}</td>
          <td>{{ $r['completion_rate_percent'] ?? '—' }}</td>
          <td>{{ $r['avg_score'] ?? '—' }}</td>
        </tr>
      @empty
        <tr><td colspan="6">Sem dados por instituição.</td></tr>
      @endforelse
    </tbody>
  </table>

  <h2>Por equipamento</h2>
  <table>
    <thead>
      <tr>
        <th>Equipamento</th>
        <th>Treinos</th>
        <th>Inscrições</th>
        <th>Concluídas</th>
        <th>Taxa conclusão (%)</th>
        <th>Média notas</th>
      </tr>
    </thead>
    <tbody>
      @forelse(($data['aggregated_by_equipment'] ?? []) as $row)
        @php $r = is_array($row) ? $row : (array) $row; @endphp
        <tr>
          <td>{{ $r['label'] ?? '—' }}</td>
          <td>{{ $r['trainings_count'] ?? '—' }}</td>
          <td>{{ $r['total_enrollments'] ?? '—' }}</td>
          <td>{{ $r['completed_count'] ?? '—' }}</td>
          <td>{{ $r['completion_rate_percent'] ?? '—' }}</td>
          <td>{{ $r['avg_score'] ?? '—' }}</td>
        </tr>
      @empty
        <tr><td colspan="6">Sem dados por equipamento.</td></tr>
      @endforelse
    </tbody>
  </table>

  <h2>Tendência mensal combinada (UTC)</h2>
  <p class="muted">Inscrições: COALESCE(joined_at, created_at). Conclusões: completed_at.</p>
  <table>
    <thead>
      <tr>
        <th>Mês (AAAA-MM)</th>
        <th>Inscrições</th>
        <th>Concluídas</th>
      </tr>
    </thead>
    <tbody>
      @forelse(($data['monthly_trend'] ?? []) as $row)
        @php $r = is_array($row) ? $row : (array) $row; @endphp
        <tr>
          <td>{{ $r['period'] ?? '—' }}</td>
          <td>{{ $r['enrollment_count'] ?? '—' }}</td>
          <td>{{ $r['completed_count'] ?? '—' }}</td>
        </tr>
      @empty
        <tr><td colspan="3">Sem dados mensais agregados.</td></tr>
      @endforelse
    </tbody>
  </table>
</body>
</html>
