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
}
