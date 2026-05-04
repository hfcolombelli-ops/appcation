<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family: system-ui, sans-serif; line-height: 1.5;">
<p>Olá@if(!empty($invitedName)) {{ $invitedName }}@endif,</p>
<p>Foi convidado como <strong>{{ $roleLabel }}</strong> na plataforma App²cation.</p>
<p><a href="{{ $acceptUrl }}">Aceitar convite e definir palavra-passe</a></p>
<p style="color:#666;font-size:12px;">Se não esperava este e-mail, ignore.</p>
</body>
</html>
