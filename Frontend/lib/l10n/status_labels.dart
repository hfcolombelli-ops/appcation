import 'app_localizations.dart';

/// Maps API training lifecycle status codes to UI strings.
String localizedTrainingLifecycleStatus(AppLocalizations l, String? raw) {
  final s = raw?.trim();
  if (s == null || s.isEmpty) return l.trainReqDashNone;
  switch (s) {
    case 'draft':
      return l.trainLifecycleDraft;
    case 'scheduled':
      return l.trainLifecycleScheduled;
    case 'in_progress':
      return l.trainLifecycleInProgress;
    case 'finished':
      return l.trainLifecycleFinished;
    default:
      return s;
  }
}

/// Maps API enrollment.status codes to UI strings.
String localizedEnrollmentStatus(AppLocalizations l, String? raw) {
  final s = raw?.trim();
  if (s == null || s.isEmpty) return l.trainReqDashNone;
  switch (s) {
    case 'waiting':
      return l.enrollmentStatusWaiting;
    case 'active':
      return l.enrollmentStatusActive;
    case 'completed':
      return l.enrollmentStatusCompleted;
    default:
      return s;
  }
}

/// Follow-up assessment row status (`pending` | `completed`).
String localizedFollowUpStatus(AppLocalizations l, String? raw) {
  final s = raw?.trim();
  if (s == null || s.isEmpty) return l.trainReqDashNone;
  switch (s) {
    case 'pending':
      return l.trainReqStatusPending;
    case 'completed':
      return l.trainReqStatusFulfilled;
    default:
      return s;
  }
}

/// Institution training request status (same vocabulary as instructor UI).
String localizedTrainingRequestStatus(AppLocalizations l, String? raw) {
  final s = raw?.trim();
  if (s == null || s.isEmpty) return l.trainReqDashNone;
  switch (s) {
    case 'pending':
      return l.trainReqStatusPending;
    case 'approved':
      return l.trainReqStatusApproved;
    case 'scheduled':
      return l.trainReqStatusScheduled;
    case 'rejected':
      return l.trainReqStatusRejected;
    case 'fulfilled':
      return l.trainReqStatusFulfilled;
    default:
      return s;
  }
}

/// Manufacturer.validation_status (`pending_info`, `pending_validation`, `active`, `rejected`).
String localizedManufacturerValidationStatus(AppLocalizations l, String? raw) {
  final s = raw?.trim();
  if (s == null || s.isEmpty) return l.trainReqDashNone;
  switch (s) {
    case 'pending_info':
      return l.mfgValStatusPendingInfo;
    case 'pending_validation':
      return l.mfgValStatusPendingValidation;
    case 'active':
      return l.mfgValStatusActive;
    case 'rejected':
      return l.mfgValStatusRejected;
    default:
      return s;
  }
}

/// Credential queue / endorsement (`pending`, `approved`, `rejected`).
String localizedCredentialQueueStatus(AppLocalizations l, String? raw) {
  final s = raw?.trim();
  if (s == null || s.isEmpty) return l.trainReqDashNone;
  switch (s) {
    case 'pending':
      return l.credStatusPending;
    case 'approved':
      return l.credStatusApproved;
    case 'rejected':
      return l.credStatusRejected;
    default:
      return s;
  }
}

/// Institution park equipment (`pending`, `active`).
String localizedParkEquipmentStatus(AppLocalizations l, String? raw) {
  final s = raw?.trim() ?? '';
  switch (s) {
    case 'pending':
      return l.parkStatusPending;
    case 'active':
      return l.parkStatusActive;
    default:
      return s.isEmpty ? l.trainReqDashNone : s;
  }
}
