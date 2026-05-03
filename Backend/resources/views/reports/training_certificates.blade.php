<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: DejaVu Sans, sans-serif; font-size: 10px; color: #222; }
    h1 { font-size: 16px; color: #00677D; margin: 0 0 4px 0; }
    h2 { font-size: 12px; margin: 12px 0 6px 0; color: #333; }
    .muted { color: #555; font-size: 9px; margin-bottom: 12px; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 6px; }
    th, td { border: 1px solid #ccc; padding: 4px 6px; text-align: left; word-break: break-word; }
    th { background: #f0f4f6; font-weight: bold; font-size: 9px; }
    .summary td:first-child { width: 38%; font-weight: bold; background: #f9fafb; }
  </style>
</head>
<body>
  <h1>App²cation — certificados por treino</h1>
  <p class="muted">
    Uso instrutor / auditoria — dados dos inscritos desta sessão.<br>
    Gerado em (UTC): {{ $generatedAt->toIso8601String() }}
  </p>

  <h2>Identificação do treino</h2>
  <table class="summary">
    <tr><td>Treino (id)</td><td>{{ $training->id }}</td></tr>
    <tr><td>Título</td><td>{{ $training->title }}</td></tr>
    <tr><td>Instituição</td><td>{{ $training->institution?->name ?? '—' }}</td></tr>
    <tr><td>Estado do treino</td><td>{{ $training->status }}</td></tr>
    <tr><td>Limiar aprovação (%)</td><td>{{ $training->passing_score_percent ?? 70 }}</td></tr>
  </table>

  <h2>Inscrições e certificados</h2>
  <table>
    <thead>
      <tr>
        <th>Participante</th>
        <th>Email</th>
        <th>Estado inscrição</th>
        <th>Nota (0–10)</th>
        <th>Código certificado</th>
        <th>Emitido (UTC)</th>
        <th>Válido até (UTC)</th>
      </tr>
    </thead>
    <tbody>
      @forelse($rows as $r)
        <tr>
          <td>{{ $r['participant'] }}</td>
          <td>{{ $r['email'] }}</td>
          <td>{{ $r['enrollment_status'] }}</td>
          <td>{{ $r['score'] !== '' ? $r['score'] : '—' }}</td>
          <td>{{ $r['certificate_code'] !== '' ? $r['certificate_code'] : '—' }}</td>
          <td>{{ $r['issued_at'] !== '' ? $r['issued_at'] : '—' }}</td>
          <td>{{ $r['expires_at'] !== '' ? $r['expires_at'] : '—' }}</td>
        </tr>
      @empty
        <tr><td colspan="7">Sem inscrições neste treino.</td></tr>
      @endforelse
    </tbody>
  </table>
</body>
</html>
