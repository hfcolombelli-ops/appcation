// Heurísticas alinhadas ao LoginIdentityParser do URS (CPF, CNPJ, CRM, conta sistema).
// E-mail válido: tipo extra para login App²cation (API aceita e-mail como identificador).

enum LoginIdentityType {
  patientCpf,
  institutionCnpj,
  doctorCrm,
  systemAccount,
  email,
  unknown,
}

/// Remove caracteres que não sejam `0-9`, `A-Za-z`, `.`, `/`, `-`, `@`.
String normalizeIdentifierInput(String raw) {
  final buf = StringBuffer();
  for (final c in raw.runes) {
    final ch = String.fromCharCode(c);
    if (RegExp(r'[0-9A-Za-z./\-@]').hasMatch(ch)) {
      buf.write(ch);
    }
  }
  return buf.toString();
}

LoginIdentityType parseLoginIdentity(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return LoginIdentityType.unknown;

  // E-mail (extensão App²cation: backend aceita e-mail como identificador)
  if (trimmed.contains('@')) {
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
    return ok ? LoginIdentityType.email : LoginIdentityType.unknown;
  }

  final upper = trimmed.toUpperCase().replaceAll(RegExp(r'\s+'), '');

  // CPF: só dígitos, 11, verificadores, não repetido
  final onlyDigits = upper.replaceAll(RegExp(r'\D'), '');
  if (RegExp(r'^\d{11}$').hasMatch(onlyDigits)) {
    if (RegExp(r'^(\d)\1{10}$').hasMatch(onlyDigits)) return LoginIdentityType.unknown;
    if (_isCpfValid(onlyDigits)) return LoginIdentityType.patientCpf;
  }

  // CNPJ: 14 dígitos, verificadores
  if (RegExp(r'^\d{14}$').hasMatch(onlyDigits)) {
    if (RegExp(r'^(\d)\1{13}$').hasMatch(onlyDigits)) return LoginIdentityType.unknown;
    if (_isCnpjValid(onlyDigits)) return LoginIdentityType.institutionCnpj;
  }

  // CRM médico
  if (RegExp(r'^[0-9]{4,10}(-?[A-Z]{2})?$').hasMatch(upper)) {
    return LoginIdentityType.doctorCrm;
  }

  // Conta sistema / admin (minúsculas para regex)
  final lower = trimmed.toLowerCase();
  final onlyMask = RegExp(r'^[0-9./\-\s]+$').hasMatch(trimmed);
  if (!onlyMask && RegExp(r'^[a-z0-9._-]+$').hasMatch(lower) && lower.length >= 4) {
    return LoginIdentityType.systemAccount;
  }

  return LoginIdentityType.unknown;
}

bool _isCpfValid(String d11) {
  if (d11.length != 11) return false;
  int dv9(List<int> nine) {
    var sum = 0;
    for (var i = 0; i < 9; i++) {
      sum += nine[i] * (10 - i);
    }
    final r = sum % 11;
    return r < 2 ? 0 : 11 - r;
  }

  int dv10(List<int> ten) {
    var sum = 0;
    for (var i = 0; i < 10; i++) {
      sum += ten[i] * (11 - i);
    }
    final r = sum % 11;
    return r < 2 ? 0 : 11 - r;
  }

  final digits = d11.split('').map(int.parse).toList();
  final d1 = dv9(digits.sublist(0, 9));
  final d2 = dv10(digits.sublist(0, 10));
  return d1 == digits[9] && d2 == digits[10];
}

bool _isCnpjValid(String d14) {
  if (d14.length != 14) return false;
  int calc(List<int> base, List<int> weights) {
    var sum = 0;
    for (var i = 0; i < base.length; i++) {
      sum += base[i] * weights[i];
    }
    final r = sum % 11;
    return r < 2 ? 0 : 11 - r;
  }

  final digits = d14.split('').map(int.parse).toList();
  final w1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  final w2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  final d1 = calc(digits.sublist(0, 12), w1);
  final d2 = calc(digits.sublist(0, 13), w2);
  return d1 == digits[12] && d2 == digits[13];
}
