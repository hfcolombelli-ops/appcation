import 'api_client.dart';

/// Chamadas à API Laravel usadas no fluxo real (produção).
class ProductionApi {
  ProductionApi(this._http);

  final ApiClient _http;

  Future<Map<String, dynamic>> dashboardSummary(String token) =>
      _http.getJson('/api/instructor/dashboard-summary', token: token);

  Future<List<Map<String, dynamic>>> institutions(String token) async {
    final r = await _http.getJsonList('/api/institutions', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> createInstitution(
    String token, {
    required String name,
    required String cnpj,
  }) =>
      _http.postJson('/api/institutions', {'name': name, 'cnpj': cnpj}, token: token);

  Future<List<Map<String, dynamic>>> myTrainings(String token) async {
    final r = await _http.getJsonList('/api/trainings', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> createTraining(String token, Map<String, dynamic> body) =>
      _http.postJson('/api/trainings', body, token: token);

  Future<Map<String, dynamic>> updateTraining(String token, int id, Map<String, dynamic> body) =>
      _http.patchJson('/api/trainings/$id', body, token: token);

  Future<Map<String, dynamic>> trainingLiveState(String token, int trainingId) =>
      _http.getJson('/api/trainings/$trainingId/live-state', token: token);

  Future<Map<String, dynamic>> realtimeTrainingCommand(
    String token,
    int trainingId, {
    required String action,
    Map<String, dynamic>? payload,
  }) =>
      _http.postJson(
        '/api/realtime/trainings/$trainingId/command',
        {
          'action': action,
          if (payload != null && payload.isNotEmpty) 'payload': payload,
        },
        token: token,
      );

  Future<Map<String, dynamic>> syncQuestionnaire(
    String token,
    int trainingId,
    Map<String, dynamic> payload,
  ) =>
      _http.postJson('/api/trainings/$trainingId/questionnaire', payload, token: token);

  Future<Map<String, dynamic>> trainingParticipants(String token, int trainingId) =>
      _http.getJson('/api/trainings/$trainingId/enrollments', token: token);

  Future<Map<String, dynamic>> traineeState(String token) =>
      _http.getJson('/api/me/trainee-state', token: token);

  Future<Map<String, dynamic>> putTraineeProfile(String token, Map<String, dynamic> body) =>
      _http.putJson('/api/me/trainee-profile', body, token: token);

  Future<Map<String, dynamic>> joinTraining(String token, String joinHash) =>
      _http.postJson('/api/enrollments/join', {'join_hash': joinHash.trim()}, token: token);

  Future<Map<String, dynamic>> getEnrollment(String token, int id) =>
      _http.getJson('/api/enrollments/$id', token: token);

  Future<List<Map<String, dynamic>>> questionnaire(String token, int trainingId) async {
    final r = await _http.getJsonList('/api/trainings/$trainingId/questionnaire', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> submitAnswer(String token, Map<String, dynamic> body) =>
      _http.postJson('/api/questionnaire/answers', body, token: token);

  Future<Map<String, dynamic>> health() => _http.getJson('/api/health');

  Future<Map<String, dynamic>> lgpdPolicyMeta() => _http.getJson('/api/privacy/policy-meta');

  Future<Map<String, dynamic>> submitLgpdConsent(String token, {required bool accepted}) =>
      _http.postJson('/api/me/lgpd-consent', {'accepted': accepted}, token: token);

  Future<Map<String, dynamic>> exportPersonalData(String token) =>
      _http.getJson('/api/me/personal-data-export', token: token);

  Future<Map<String, dynamic>> requestAccountDeletion(
    String token, {
    String? password,
    String? idToken,
    required String confirmText,
  }) =>
      _http.postJson(
        '/api/me/request-account-deletion',
        {
          'confirm_text': confirmText,
          if (password != null && password.isNotEmpty) 'password': password,
          if (idToken != null && idToken.isNotEmpty) 'id_token': idToken,
        },
        token: token,
      );

  Future<Map<String, dynamic>> manufacturerProfile(String token) =>
      _http.getJson('/api/manufacturer/profile', token: token);

  Future<Map<String, dynamic>> updateManufacturerProfile(String token, Map<String, dynamic> body) =>
      _http.putJson('/api/manufacturer/profile', body, token: token);

  Future<List<Map<String, dynamic>>> manufacturerEquipmentList(String token) async {
    final r = await _http.getJsonList('/api/manufacturer/equipment', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> createManufacturerEquipment(
    String token, {
    required String name,
    required String model,
    String? sector,
    int? quantity,
    String? status,
  }) =>
      _http.postJson(
        '/api/manufacturer/equipment',
        {
          'name': name,
          'model': model,
          if (sector?.isNotEmpty ?? false) 'sector': sector,
          'quantity': ?quantity,
          if (status?.isNotEmpty ?? false) 'status': status,
        },
        token: token,
      );

  Future<Map<String, dynamic>> updateManufacturerEquipment(
    String token,
    int id,
    Map<String, dynamic> body,
  ) =>
      _http.putJson('/api/manufacturer/equipment/$id', body, token: token);

  Future<void> deleteManufacturerEquipment(String token, int id) =>
      _http.delete('/api/manufacturer/equipment/$id', token: token);
}
