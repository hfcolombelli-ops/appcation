import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'google_sign_in_helper.dart';

/// Estado global de autenticação (Sanctum token + usuário).
class AuthSession extends ChangeNotifier {
  AuthSession({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  static const _kToken = 'auth_token';
  static const _kUser = 'auth_user';

  String? _token;
  Map<String, dynamic>? _user;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  bool get isAuthenticated => _token != null && _user != null;

  /// Perfil API (`users.role`). Valores não-string ou vazios tratam-se como «sem perfil» → triagem.
  String? get role {
    final u = _user;
    if (u == null) return null;
    final raw = u['role'];
    if (raw == null) return null;
    if (raw is! String) return null;
    final s = raw.trim();
    return s.isEmpty ? null : s;
  }

  /// API: `needs_profile_gate` — conta Google (ou perfil inválido) ainda sem escolha em PATCH /api/me/role.
  ///
  /// Fallback: API antiga ou cache sem o campo — replica o critério Laravel (google_sub + sem
  /// `google_triage_completed_at` + papel treinando ou sem perfil) para não ir directo ao pré-registro.
  bool get needsProfileGate {
    final u = _user;
    if (u == null) return false;
    if (u['needs_profile_gate'] == true) return true;

    final subRaw = u['google_sub'];
    final hasGoogle = subRaw is String && subRaw.trim().isNotEmpty;
    if (!hasGoogle) return false;

    final triageAt = u['google_triage_completed_at'];
    final triageDone = switch (triageAt) {
      null => false,
      String s => s.trim().isNotEmpty,
      _ => true,
    };
    if (triageDone) return false;

    final r = role;
    return r == null || r == 'trainee';
  }

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kToken);
    final raw = prefs.getString(_kUser);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _user = decoded;
        }
      } catch (_) {
        _user = null;
      }
    }

    if (_token != null) {
      try {
        final me = await _api.getJson('/api/auth/me', token: _token);
        _user = me;
        await _persist();
      } on ApiException catch (e) {
        // Só 401 = não autenticado (Sanctum). 403 aqui seria “proibido”, não deve apagar o token.
        if (e.statusCode == 401) {
          await clear(notify: false);
        }
      } catch (_) {
        // falha de rede / parse: mantém sessão já persistida para uso offline
      }
    }

    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString(_kToken, _token!);
    } else {
      await prefs.remove(_kToken);
    }
    if (_user != null) {
      await prefs.setString(_kUser, jsonEncode(_user));
    } else {
      await prefs.remove(_kUser);
    }
  }

  Future<void> login(String identifierOrEmail, String password) async {
    final data = await _api.postJson('/api/auth/login', {
      'identifier': identifierOrEmail.trim(),
      'password': password,
    });
    final t = data['token'] as String?;
    final u = data['user'];
    if (t == null || u is! Map<String, dynamic>) {
      throw ApiException('', 500, reason: LocalizedApiReason.authInvalidLoginResponse);
    }
    _token = t;
    _user = u;
    await _persist();
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? manufacturerName,
    String? manufacturerCnpj,
  }) async {
    final data = await _api.postJson('/api/auth/register', {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'role': role,
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (role == 'manufacturer_admin') ...{
        if (manufacturerName != null && manufacturerName.trim().isNotEmpty)
          'manufacturer_name': manufacturerName.trim(),
        if (manufacturerCnpj != null && manufacturerCnpj.trim().isNotEmpty)
          'manufacturer_cnpj': manufacturerCnpj.trim(),
      },
    });
    final t = data['token'] as String?;
    final u = data['user'];
    if (t == null || u is! Map<String, dynamic>) {
      throw ApiException('', 500, reason: LocalizedApiReason.authInvalidRegisterResponse);
    }
    _token = t;
    _user = u;
    await _persist();
    notifyListeners();
  }

  /// Troca um ID token Google já obtido no cliente por sessão Sanctum (Web: botão GIS; mobile: após `authenticate`).
  /// Sem [role]: o servidor cria/vincula a sessão e deixa o perfil para a triagem (`ProfileGateScreen`).
  Future<void> loginWithGoogleIdToken(
    String idToken, {
    String? role,
    String? manufacturerName,
    String? manufacturerCnpj,
  }) async {
    final body = <String, dynamic>{'id_token': idToken};
    if (role != null) {
      body['role'] = role;
      if (role == 'manufacturer_admin') {
        if (manufacturerName != null && manufacturerName.trim().isNotEmpty) {
          body['manufacturer_name'] = manufacturerName.trim();
        }
        if (manufacturerCnpj != null && manufacturerCnpj.trim().isNotEmpty) {
          body['manufacturer_cnpj'] = manufacturerCnpj.trim();
        }
      }
    }

    final data = await _api.postJson('/api/auth/google', body);
    final t = data['token'] as String?;
    final u = data['user'];
    if (t == null || u is! Map<String, dynamic>) {
      throw ApiException('', 500, reason: LocalizedApiReason.authInvalidGoogleLoginResponse);
    }
    _token = t;
    _user = Map<String, dynamic>.from(u);
    // Garantir `role` null da BD (evita default DB / serialização) antes da triagem.
    try {
      final me = await _api.getJson('/api/auth/me', token: _token);
      _user = Map<String, dynamic>.from(me);
    } catch (_) {
      // mantém payload do POST se /me falhar
    }
    await _persist();
    notifyListeners();
  }

  Future<void> loginWithGoogle(
    BuildContext context, {
    bool forceAccountPicker = true,
    String? role,
    String? manufacturerName,
    String? manufacturerCnpj,
  }) async {
    final idToken = await obtainGoogleIdToken(
      context: context,
      forceAccountPicker: forceAccountPicker,
    );
    if (idToken == null) {
      throw ApiException('', 400, reason: LocalizedApiReason.authGoogleCancelled);
    }
    await loginWithGoogleIdToken(
      idToken,
      role: role,
      manufacturerName: manufacturerName,
      manufacturerCnpj: manufacturerCnpj,
    );
  }

  /// Digesto semanal de resumo agregado (gestor / fabricante).
  Future<void> setWeeklyDashboardDigest(bool enabled) async {
    if (_token == null) return;
    final data = await _api.patchJson(
      '/api/me/notification-preferences',
      {'weekly_dashboard_digest': enabled},
      token: _token,
    );
    _user = Map<String, dynamic>.from(data);
    await _persist();
    notifyListeners();
  }

  /// Quando o servidor não tem `role` mapeável: escolha única alinhada a `PATCH /api/me/role`.
  Future<void> claimInitialRole(
    String role, {
    String? manufacturerName,
    String? manufacturerCnpj,
  }) async {
    if (_token == null) return;
    final body = <String, dynamic>{'role': role};
    if (role == 'manufacturer_admin') {
      if (manufacturerName != null && manufacturerName.trim().isNotEmpty) {
        body['manufacturer_name'] = manufacturerName.trim();
      }
      if (manufacturerCnpj != null && manufacturerCnpj.trim().isNotEmpty) {
        body['manufacturer_cnpj'] = manufacturerCnpj.trim();
      }
    }
    final data = await _api.patchJson('/api/me/role', body, token: _token);
    _user = Map<String, dynamic>.from(data);
    await _persist();
    notifyListeners();
  }

  /// Gestor: vincula o perfil a uma instituição (API devolve o utilizador actualizado).
  Future<void> linkInstitution(int institutionId) async {
    if (_token == null) return;
    final data = await _api.patchJson(
      '/api/me/institution',
      {'institution_id': institutionId},
      token: _token,
    );
    _user = Map<String, dynamic>.from(data);
    await _persist();
    notifyListeners();
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await _api.postJson('/api/auth/logout', {}, token: _token);
      } catch (_) {
        // segue limpando sessão local
      }
    }
    await clear();
  }

  Future<void> clear({bool notify = true}) async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUser);
    if (notify) notifyListeners();
  }
}
