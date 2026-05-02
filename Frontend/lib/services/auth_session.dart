import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

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

  String? get role => _user?['role'] as String?;

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
        if (e.statusCode == 401 || e.statusCode == 403) {
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

  Future<void> login(String email, String password) async {
    final data = await _api.postJson('/api/auth/login', {
      'email': email.trim(),
      'password': password,
    });
    final t = data['token'] as String?;
    final u = data['user'];
    if (t == null || u is! Map<String, dynamic>) {
      throw ApiException('Resposta de login inválida.', 500);
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
  }) async {
    final data = await _api.postJson('/api/auth/register', {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'role': role,
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
    });
    final t = data['token'] as String?;
    final u = data['user'];
    if (t == null || u is! Map<String, dynamic>) {
      throw ApiException('Resposta de cadastro inválida.', 500);
    }
    _token = t;
    _user = u;
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
