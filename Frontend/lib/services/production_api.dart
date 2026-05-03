import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_client.dart';

/// Chamadas à API Laravel usadas no fluxo real (produção).
class ProductionApi {
  ProductionApi(this._http);

  final ApiClient _http;

  Future<Map<String, dynamic>> dashboardSummary(String token) =>
      _http.getJson('/api/instructor/dashboard-summary', token: token);

  /// Posições em temporadas de fabricantes (treinos com `manufacturer_id`).
  Future<List<Map<String, dynamic>>> instructorSeasonRanks(String token) async {
    final r = await _http.getJsonList('/api/instructor/season-ranks', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> institutions(String token) async {
    final r = await _http.getJsonList('/api/institutions', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Sem autenticação (cadastro de gestor).
  Future<List<Map<String, dynamic>>> publicInstitutionCatalog() async {
    final r = await _http.getJsonList('/api/public/institution-catalog');
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> updateMyInstitution(String token, int institutionId) =>
      _http.patchJson('/api/me/institution', {'institution_id': institutionId}, token: token);

  Future<List<Map<String, dynamic>>> institutionMyTrainings(String token) async {
    final r = await _http.getJsonList('/api/institution/my-trainings', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> institutionApprovedInstructors(String token) async {
    final r = await _http.getJsonList('/api/institution/approved-instructors', token: token);
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

  Future<List<Map<String, dynamic>>> manufacturerTemplates(String token) async {
    final r = await _http.getJsonList('/api/trainings?templates_only=1', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> officialTrainingTemplatesCatalog(String token) async {
    final r = await _http.getJsonList('/api/catalog/official-training-templates', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> instantiateTrainingFromTemplate(
    String token,
    int templateId, {
    required int institutionId,
    String? title,
    String? scheduledAt,
  }) =>
      _http.postJson(
        '/api/trainings/from-template/$templateId',
        {
          'institution_id': institutionId,
          if (title != null && title.isNotEmpty) 'title': title,
          if (scheduledAt != null && scheduledAt.isNotEmpty) 'scheduled_at': scheduledAt,
        },
        token: token,
      );

  Future<List<Map<String, dynamic>>> manufacturersCatalog(String token) async {
    final r = await _http.getJsonList('/api/catalog/manufacturers', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> credentialsMine(String token) =>
      _http.getJson('/api/credentials/me', token: token);

  Future<Map<String, dynamic>> applyCredentialInstitution(String token, int institutionId) =>
      _http.postJson('/api/credentials/institution', {'institution_id': institutionId}, token: token);

  Future<Map<String, dynamic>> applyCredentialManufacturer(String token, int manufacturerId) =>
      _http.postJson('/api/credentials/manufacturer', {'manufacturer_id': manufacturerId}, token: token);

  Future<List<Map<String, dynamic>>> credentialInstitutionQueue(String token) async {
    final r = await _http.getJsonList('/api/credentials/institution/queue', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> credentialInstitutionDecide(String token, int id, String status) =>
      _http.patchJson('/api/credentials/institution/$id', {'status': status}, token: token);

  Future<List<Map<String, dynamic>>> credentialManufacturerQueue(String token) async {
    final r = await _http.getJsonList('/api/credentials/manufacturer/queue', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> credentialManufacturerDecide(
    String token,
    int id, {
    required String status,
    bool? feePaid,
  }) =>
      _http.patchJson(
        '/api/credentials/manufacturer/$id',
        {
          'status': status,
          if (feePaid != null) 'fee_paid': feePaid,
        },
        token: token,
      );

  Future<List<Map<String, dynamic>>> institutionManufacturerEndorsementQueue(String token) async {
    final r = await _http.getJsonList('/api/institution/manufacturer-endorsement-queue', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> institutionManufacturerEndorse(String token, int id) =>
      _http.postJson('/api/institution/manufacturer-endorsements/$id/endorse', {}, token: token);

  Future<Map<String, dynamic>> trainingRequestOptions(String token) =>
      _http.getJson('/api/catalog/training-request-options', token: token);

  /// Treinando: unidades do parque da instituição do perfil (pré-registro). 422 se sem `institution_id` no perfil.
  Future<List<Map<String, dynamic>>> traineeInstitutionParkEquipment(String token) async {
    final r = await _http.getJsonList('/api/me/institution-park-equipment', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> createTrainingRequest(
    String token, {
    required int institutionId,
    required String reasonCode,
    int? equipmentId,
    String? priority,
    String? desiredDate,
    String? latestAcceptableDate,
    String? reason,
    String? notes,
  }) =>
      _http.postJson(
        '/api/training-requests',
        {
          'institution_id': institutionId,
          'reason_code': reasonCode,
          if (equipmentId != null) 'equipment_id': equipmentId,
          if (priority != null && priority.isNotEmpty) 'priority': priority,
          if (desiredDate != null && desiredDate.isNotEmpty) 'desired_date': desiredDate,
          if (latestAcceptableDate != null && latestAcceptableDate.isNotEmpty)
            'latest_acceptable_date': latestAcceptableDate,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        token: token,
      );

  Future<List<Map<String, dynamic>>> myTrainingRequests(String token) async {
    final r = await _http.getJsonList('/api/training-requests/mine', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> institutionDashboardSummary(String token) =>
      _http.getJson('/api/institution/dashboard-summary', token: token);

  /// CSV com os mesmos agregados do dashboard (LGPD — sem identificação individual).
  Future<Uint8List> institutionDashboardExportCsv(String token) =>
      _http.getBytes('/api/institution/dashboard-summary/export.csv', token: token);

  Future<Uint8List> institutionDashboardExportPdf(String token) =>
      _http.getBytes('/api/institution/dashboard-summary/export.pdf', token: token);

  Future<List<Map<String, dynamic>>> institutionTrainingRequests(String token) async {
    final r = await _http.getJsonList('/api/institution/training-requests', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> updateInstitutionTrainingRequest(
    String token,
    int id,
    Map<String, dynamic> body,
  ) =>
      _http.patchJson('/api/institution/training-requests/$id', body, token: token);

  Future<List<Map<String, dynamic>>> institutionEquipmentTemplates(
    String token, {
    String? category,
    String? search,
  }) async {
    final parts = <String>[];
    if (category != null && category.isNotEmpty) {
      parts.add('category=${Uri.encodeQueryComponent(category)}');
    }
    if (search != null && search.trim().isNotEmpty) {
      parts.add('search=${Uri.encodeQueryComponent(search.trim())}');
    }
    final q = parts.isEmpty ? '' : '?${parts.join('&')}';
    final r = await _http.getJsonList('/api/institution/equipment-templates$q', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> institutionEquipmentPark(
    String token, {
    String? status,
    String? category,
    String? search,
  }) async {
    final parts = <String>[];
    if (status != null && status.isNotEmpty) {
      parts.add('status=${Uri.encodeQueryComponent(status)}');
    }
    if (category != null && category.isNotEmpty) {
      parts.add('category=${Uri.encodeQueryComponent(category)}');
    }
    if (search != null && search.trim().isNotEmpty) {
      parts.add('search=${Uri.encodeQueryComponent(search.trim())}');
    }
    final q = parts.isEmpty ? '' : '?${parts.join('&')}';
    final r = await _http.getJsonList('/api/institution/equipment$q', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Imagem do modelo de catálogo (mesmo ficheiro enviado pelo fabricante).
  Future<Uint8List> downloadInstitutionCatalogEquipmentImage(String token, int catalogEquipmentId) =>
      _http.getBytes('/api/institution/catalog-equipment/$catalogEquipmentId/image', token: token);

  Future<Map<String, dynamic>> createInstitutionParkEquipment(
    String token, {
    required int catalogEquipmentId,
    String? sector,
    int? quantity,
    String? status,
  }) =>
      _http.postJson(
        '/api/institution/equipment',
        {
          'catalog_equipment_id': catalogEquipmentId,
          if (sector != null && sector.isNotEmpty) 'sector': sector,
          if (quantity != null) 'quantity': quantity,
          if (status != null && status.isNotEmpty) 'status': status,
        },
        token: token,
      );

  Future<Map<String, dynamic>> updateInstitutionParkEquipment(
    String token,
    int id,
    Map<String, dynamic> body,
  ) =>
      _http.putJson('/api/institution/equipment/$id', body, token: token);

  Future<void> deleteInstitutionParkEquipment(String token, int id) =>
      _http.delete('/api/institution/equipment/$id', token: token);

  Future<List<Map<String, dynamic>>> myCertificates(String token) async {
    final r = await _http.getJsonList('/api/me/certificates', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Uint8List> downloadMyCertificatePdf(String token, int id) =>
      _http.getBytes('/api/me/certificates/$id/pdf', token: token);

  /// PDF do certificado de um participante (instrutor dono do treino).
  Future<Uint8List> downloadTrainingParticipantCertificatePdf(String token, int trainingId, int certificateId) =>
      _http.getBytes('/api/trainings/$trainingId/certificates/$certificateId/pdf', token: token);

  Future<List<Map<String, dynamic>>> myFollowUpAssessments(String token) async {
    final r = await _http.getJsonList('/api/me/follow-up-assessments', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> followUpAssessmentDetail(String token, int id) =>
      _http.getJson('/api/me/follow-up-assessments/$id', token: token);

  Future<Map<String, dynamic>> submitFollowUpAssessment(
    String token,
    int id,
    Map<String, dynamic> responses,
  ) =>
      _http.postJson('/api/me/follow-up-assessments/$id/submit', {'responses': responses}, token: token);

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

  /// Instrutor: emissão manual quando a nota já cumpre o limiar e o certificado ainda falta (ou idempotente).
  Future<Map<String, dynamic>> issueTrainingEnrollmentCertificate(
    String token,
    int trainingId,
    int enrollmentId,
  ) =>
      _http.postJson(
        '/api/trainings/$trainingId/enrollments/$enrollmentId/certificate',
        {},
        token: token,
      );

  Future<Uint8List> downloadTrainingCertificatesReportCsv(String token, int trainingId) =>
      _http.getBytes('/api/trainings/$trainingId/certificates/export.csv', token: token);

  Future<Uint8List> downloadTrainingCertificatesReportPdf(String token, int trainingId) =>
      _http.getBytes('/api/trainings/$trainingId/certificates/export.pdf', token: token);

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

  Future<Map<String, dynamic>> manufacturerDashboardSummary(String token) =>
      _http.getJson('/api/manufacturer/dashboard-summary', token: token);

  Future<Uint8List> manufacturerDashboardExportCsv(String token) =>
      _http.getBytes('/api/manufacturer/dashboard-summary/export.csv', token: token);

  Future<Uint8List> manufacturerDashboardExportPdf(String token) =>
      _http.getBytes('/api/manufacturer/dashboard-summary/export.pdf', token: token);

  Future<Map<String, dynamic>> updateManufacturerProfile(String token, Map<String, dynamic> body) =>
      _http.putJson('/api/manufacturer/profile', body, token: token);

  Future<List<Map<String, dynamic>>> manufacturerSeasons(String token) async {
    final r = await _http.getJsonList('/api/manufacturer/seasons', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> createManufacturerSeason(
    String token, {
    required String name,
    required String startsAt,
    required String endsAt,
    int? targetTrainings,
    String? notes,
  }) =>
      _http.postJson(
        '/api/manufacturer/seasons',
        {
          'name': name,
          'starts_at': startsAt,
          'ends_at': endsAt,
          if (targetTrainings != null) 'target_trainings': targetTrainings,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        token: token,
      );

  Future<Map<String, dynamic>> manufacturerSeasonLeaderboard(String token, int seasonId) =>
      _http.getJson('/api/manufacturer/seasons/$seasonId/leaderboard', token: token);

  Future<Map<String, dynamic>> recomputeManufacturerSeason(String token, int seasonId) =>
      _http.postJson('/api/manufacturer/seasons/$seasonId/recompute', {}, token: token);

  Future<void> deleteManufacturerSeason(String token, int seasonId) =>
      _http.delete('/api/manufacturer/seasons/$seasonId', token: token);

  Future<List<Map<String, dynamic>>> manufacturerPrizes(String token) async {
    final r = await _http.getJsonList('/api/manufacturer/prizes', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> createManufacturerPrize(
    String token, {
    required String title,
    String? description,
    int? sortOrder,
  }) =>
      _http.postJson(
        '/api/manufacturer/prizes',
        {
          'title': title,
          if (description != null && description.isNotEmpty) 'description': description,
          if (sortOrder != null) 'sort_order': sortOrder,
        },
        token: token,
      );

  Future<Map<String, dynamic>> updateManufacturerPrize(
    String token,
    int id,
    Map<String, dynamic> body,
  ) =>
      _http.patchJson('/api/manufacturer/prizes/$id', body, token: token);

  Future<void> deleteManufacturerPrize(String token, int id) =>
      _http.delete('/api/manufacturer/prizes/$id', token: token);

  /// Catálogo público (sem auth) — registo descritivo, sem pagamento.
  Future<List<Map<String, dynamic>>> publicManufacturerPrizeCatalog(int manufacturerId) async {
    final r = await _http.getJsonList('/api/public/manufacturer-prizes?manufacturer_id=$manufacturerId');
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Fabricante: pede validação Fluxxo (`pending_validation`).
  Future<Map<String, dynamic>> requestManufacturerValidation(String token) =>
      _http.postJson('/api/manufacturer/request-validation', {}, token: token);

  /// Revisor Fluxxo: fila de fabricantes em `pending_validation`.
  Future<List<Map<String, dynamic>>> manufacturerReviewQueue(String token) async {
    final r = await _http.getJsonList('/api/manufacturer/review-queue', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Revisor Fluxxo: define `validation_status` do fabricante.
  Future<Map<String, dynamic>> patchManufacturerReview(
    String token,
    int manufacturerId, {
    required String validationStatus,
  }) =>
      _http.patchJson(
        '/api/manufacturer/reviews/$manufacturerId',
        {'validation_status': validationStatus},
        token: token,
      );

  Future<List<Map<String, dynamic>>> equipmentCategoriesCatalog(String token) async {
    final r = await _http.getJsonList('/api/catalog/equipment-categories', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> manufacturerEquipmentList(
    String token, {
    String? category,
    String? search,
    String? status,
  }) async {
    final parts = <String>[];
    if (category != null && category.isNotEmpty) {
      parts.add('category=${Uri.encodeQueryComponent(category)}');
    }
    if (search != null && search.trim().isNotEmpty) {
      parts.add('search=${Uri.encodeQueryComponent(search.trim())}');
    }
    if (status != null && status.isNotEmpty) {
      parts.add('status=${Uri.encodeQueryComponent(status)}');
    }
    final q = parts.isEmpty ? '' : '?${parts.join('&')}';
    final r = await _http.getJsonList('/api/manufacturer/equipment$q', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> createManufacturerEquipment(
    String token, {
    required String name,
    required String model,
    String? sector,
    String? category,
    int? quantity,
    String? status,
    int? parentEquipmentId,
    String? firmwareVersion,
    String? serialNumber,
    List<Map<String, String>>? technicalSpecs,
    String? introVideoUrl,
    int? defaultTrainingHours,
    int? defaultPassingScorePercent,
    int? defaultCertificateValidityMonths,
    int? defaultReassessmentDays,
  }) =>
      _http.postJson(
        '/api/manufacturer/equipment',
        {
          'name': name,
          'model': model,
          if (sector?.isNotEmpty ?? false) 'sector': sector,
          if (category != null && category.isNotEmpty) 'category': category,
          if (quantity != null) 'quantity': quantity,
          if (status?.isNotEmpty ?? false) 'status': status,
          if (parentEquipmentId != null) 'parent_equipment_id': parentEquipmentId,
          if (firmwareVersion?.isNotEmpty ?? false) 'firmware_version': firmwareVersion,
          if (serialNumber?.isNotEmpty ?? false) 'serial_number': serialNumber,
          if (technicalSpecs != null && technicalSpecs.isNotEmpty) 'technical_specs': technicalSpecs,
          if (introVideoUrl?.isNotEmpty ?? false) 'intro_video_url': introVideoUrl,
          if (defaultTrainingHours != null) 'default_training_hours': defaultTrainingHours,
          if (defaultPassingScorePercent != null) 'default_passing_score_percent': defaultPassingScorePercent,
          if (defaultCertificateValidityMonths != null)
            'default_certificate_validity_months': defaultCertificateValidityMonths,
          if (defaultReassessmentDays != null) 'default_reassessment_days': defaultReassessmentDays,
        },
        token: token,
      );

  /// Anexo do equipamento: `attachment_type` = image | operator_manual | maintenance_manual | datasheet | intro_video
  Future<Map<String, dynamic>> uploadManufacturerEquipmentAttachment(
    String token,
    int equipmentId, {
    required String attachmentType,
    required String filename,
    List<int>? fileBytes,
    String? filePath,
  }) async {
    if (fileBytes == null && filePath == null) {
      throw ApiException('', 0, reason: LocalizedApiReason.uploadMissingFileSource);
    }
    final http.MultipartFile file = fileBytes != null
        ? http.MultipartFile.fromBytes('file', fileBytes, filename: filename)
        : await http.MultipartFile.fromPath('file', filePath!, filename: filename);
    return _http.postMultipart(
      '/api/manufacturer/equipment/$equipmentId/attachments',
      [file],
      {'attachment_type': attachmentType},
      token: token,
    );
  }

  /// Descarrega anexo (ex.: `image`, `operator_manual`, …) — autenticado.
  Future<Uint8List> downloadManufacturerEquipmentAttachment(
    String token,
    int equipmentId,
    String attachmentType,
  ) =>
      _http.getBytes(
        '/api/manufacturer/equipment/$equipmentId/attachments/$attachmentType/download',
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

  Future<List<Map<String, dynamic>>> listManufacturerDocuments(String token) async {
    final r = await _http.getJsonList('/api/manufacturer/documents', token: token);
    return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> uploadManufacturerDocument(
    String token, {
    required String filename,
    List<int>? fileBytes,
    String? filePath,
    String? documentKind,
    String? notes,
  }) async {
    if (fileBytes == null && filePath == null) {
      throw ApiException('', 0, reason: LocalizedApiReason.uploadMissingFileSource);
    }
    final http.MultipartFile file = fileBytes != null
        ? http.MultipartFile.fromBytes('file', fileBytes, filename: filename)
        : await http.MultipartFile.fromPath('file', filePath!, filename: filename);
    final fields = <String, String>{};
    if (documentKind != null && documentKind.trim().isNotEmpty) {
      fields['document_kind'] = documentKind.trim();
    }
    if (notes != null && notes.trim().isNotEmpty) {
      fields['notes'] = notes.trim();
    }
    return _http.postMultipart('/api/manufacturer/documents', [file], fields, token: token);
  }

  Future<void> deleteManufacturerDocument(String token, int id) =>
      _http.delete('/api/manufacturer/documents/$id', token: token);

  Future<Uint8List> downloadManufacturerDocument(String token, int id) =>
      _http.getBytes('/api/manufacturer/documents/$id/download', token: token);

  /// Metadados Reverb/Pusher para WebSocket (sem autenticação).
  Future<Map<String, dynamic>> realtimeClientConfig() =>
      _http.getJson('/api/realtime/client-config');
}
