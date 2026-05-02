import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

class ApiException implements Exception {
  ApiException(this.message, this.statusCode, {this.body});

  final String message;
  final int statusCode;
  final Map<String, dynamic>? body;

  @override
  String toString() => message;
}

String extractApiMessage(Map<String, dynamic> map) {
  final m = map['message'];
  if (m is String && m.isNotEmpty) return m;
  final errs = map['errors'];
  if (errs is Map) {
    for (final v in errs.values) {
      if (v is List && v.isNotEmpty) return v.first.toString();
      if (v is String && v.isNotEmpty) return v;
    }
  }
  return 'Não foi possível concluir a operação.';
}

class ApiClient {
  ApiClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) {
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final http.Response res;
    try {
      res = await _client.post(_uri(path), headers: headers, body: jsonEncode(body));
    } on http.ClientException catch (e) {
      throw ApiException('Sem ligação ao servidor. Verifique a rede e a URL da API. (${e.message})', 0);
    }
    final raw = res.body.trim();
    late final Map<String, dynamic> map;
    try {
      final decoded = raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw);
      map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      throw ApiException(
        'Resposta inválida do servidor (HTTP ${res.statusCode}).',
        res.statusCode,
      );
    }
    if (res.statusCode >= 400) {
      throw ApiException(extractApiMessage(map), res.statusCode, body: map);
    }
    return map;
  }

  Future<Map<String, dynamic>> getJson(String path, {String? token}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final res = await _client.get(_uri(path), headers: headers);
    final raw = res.body.trim();
    final decoded = raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw);
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (res.statusCode >= 400) {
      throw ApiException(extractApiMessage(map), res.statusCode, body: map);
    }
    return map;
  }

  Future<List<dynamic>> getJsonList(String path, {String? token}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final res = await _client.get(_uri(path), headers: headers);
    final raw = res.body.trim();
    final decoded = raw.isEmpty ? null : jsonDecode(raw);
    if (res.statusCode >= 400) {
      final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      throw ApiException(extractApiMessage(map), res.statusCode, body: map);
    }
    if (decoded is! List<dynamic>) {
      throw ApiException('Resposta não é uma lista.', res.statusCode);
    }
    return decoded;
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final res = await _client.put(_uri(path), headers: headers, body: jsonEncode(body));
    final raw = res.body.trim();
    final decoded = raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw);
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (res.statusCode >= 400) {
      throw ApiException(extractApiMessage(map), res.statusCode, body: map);
    }
    return map;
  }

  Future<Map<String, dynamic>> patchJson(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final res = await _client.patch(_uri(path), headers: headers, body: jsonEncode(body));
    final raw = res.body.trim();
    final decoded = raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw);
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (res.statusCode >= 400) {
      throw ApiException(extractApiMessage(map), res.statusCode, body: map);
    }
    return map;
  }

  Future<void> delete(String path, {String? token}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final res = await _client.delete(_uri(path), headers: headers);
    final raw = res.body.trim();
    if (res.statusCode >= 400) {
      final decoded = raw.isEmpty ? null : jsonDecode(raw);
      final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      throw ApiException(extractApiMessage(map), res.statusCode, body: map);
    }
  }

  void close() => _client.close();
}
