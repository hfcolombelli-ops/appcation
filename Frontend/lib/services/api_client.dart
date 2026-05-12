import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config.dart';

/// Reasons for messages produced by the HTTP client (not the API JSON body).
enum LocalizedApiReason {
  networkUnreachable,
  invalidHttpBody,
  responseNotList,
  operationIncomplete,
  authInvalidLoginResponse,
  authInvalidRegisterResponse,
  uploadMissingFileSource,
}

class ApiException implements Exception {
  ApiException(
    this.message,
    this.statusCode, {
    this.body,
    this.reason,
    this.detail,
  });

  final String message;
  final int statusCode;
  final Map<String, dynamic>? body;
  final LocalizedApiReason? reason;
  final String? detail;

  @override
  String toString() => message.isNotEmpty ? message : (reason?.name ?? '');
}

String? _tryServerMessage(Map<String, dynamic> map) {
  final m = map['message'];
  if (m is String && m.isNotEmpty) return m;
  final errs = map['errors'];
  if (errs is Map) {
    for (final v in errs.values) {
      if (v is List && v.isNotEmpty) return v.first.toString();
      if (v is String && v.isNotEmpty) return v;
    }
  }
  return null;
}

Never _throwHttpClientError(Map<String, dynamic> map, int statusCode) {
  final msg = _tryServerMessage(map);
  if (msg != null) {
    throw ApiException(msg, statusCode, body: map);
  }
  throw ApiException('', statusCode, body: map, reason: LocalizedApiReason.operationIncomplete);
}

class ApiClient {
  ApiClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) {
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Uri _uriWithQuery(String path, Map<String, String>? query) {
    final u = _uri(path);
    if (query == null || query.isEmpty) return u;
    final merged = Map<String, String>.from(u.queryParameters);
    for (final e in query.entries) {
      if (e.value.isNotEmpty) {
        merged[e.key] = e.value;
      }
    }
    return u.replace(queryParameters: merged);
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
      throw ApiException('', 0, reason: LocalizedApiReason.networkUnreachable, detail: e.message);
    }
    final raw = res.body.trim();
    late final Map<String, dynamic> map;
    try {
      final decoded = raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw);
      map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      throw ApiException(
        '',
        res.statusCode,
        reason: LocalizedApiReason.invalidHttpBody,
      );
    }
    if (res.statusCode >= 400) {
      _throwHttpClientError(map, res.statusCode);
    }
    return map;
  }

  Future<Map<String, dynamic>> getJson(String path, {String? token, Map<String, String>? query}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final res = await _client.get(_uriWithQuery(path, query), headers: headers);
    final raw = res.body.trim();
    final decoded = raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw);
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (res.statusCode >= 400) {
      _throwHttpClientError(map, res.statusCode);
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
      _throwHttpClientError(map, res.statusCode);
    }
    if (decoded is! List<dynamic>) {
      throw ApiException('', res.statusCode, reason: LocalizedApiReason.responseNotList);
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
      _throwHttpClientError(map, res.statusCode);
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
      _throwHttpClientError(map, res.statusCode);
    }
    return map;
  }

  /// POST multipart/form-data; resposta JSON (201/200).
  Future<Map<String, dynamic>> postMultipart(
    String path,
    List<http.MultipartFile> files,
    Map<String, String> fields, {
    String? token,
  }) async {
    final uri = _uri(path);
    final req = http.MultipartRequest('POST', uri);
    req.headers['Accept'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $token';
    }
    for (final e in fields.entries) {
      req.fields[e.key] = e.value;
    }
    for (final f in files) {
      req.files.add(f);
    }
    late final http.Response res;
    try {
      final streamed = await _client.send(req);
      res = await http.Response.fromStream(streamed);
    } on http.ClientException catch (e) {
      throw ApiException('', 0, reason: LocalizedApiReason.networkUnreachable, detail: e.message);
    }
    final raw = res.body.trim();
    late final Map<String, dynamic> map;
    try {
      final decoded = raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw);
      map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      throw ApiException(
        '',
        res.statusCode,
        reason: LocalizedApiReason.invalidHttpBody,
      );
    }
    if (res.statusCode >= 400) {
      _throwHttpClientError(map, res.statusCode);
    }
    return map;
  }

  Future<Uint8List> getBytes(String path, {String? token, Map<String, String>? query}) async {
    final headers = <String, String>{
      'Accept': '*/*',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final res = await _client.get(_uriWithQuery(path, query), headers: headers);
    if (res.statusCode >= 400) {
      final raw = res.body.trim();
      Map<String, dynamic> map = {};
      try {
        final decoded = raw.isEmpty ? null : jsonDecode(raw);
        if (decoded is Map<String, dynamic>) map = decoded;
      } on FormatException {
        throw ApiException('', res.statusCode, reason: LocalizedApiReason.invalidHttpBody);
      }
      _throwHttpClientError(map, res.statusCode);
    }
    return res.bodyBytes;
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
      _throwHttpClientError(map, res.statusCode);
    }
  }

  void close() => _client.close();
}
