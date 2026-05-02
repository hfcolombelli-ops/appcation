import '../services/api_client.dart';
import 'app_localizations.dart';

/// User-facing text for [ApiException], including client-generated reasons.
String localizedApiMessage(AppLocalizations l, ApiException e) {
  switch (e.reason) {
    case LocalizedApiReason.networkUnreachable:
      return l.errApiNetworkUnreachable(e.detail ?? '');
    case LocalizedApiReason.invalidHttpBody:
      return l.errApiInvalidHttpBody(e.statusCode);
    case LocalizedApiReason.responseNotList:
      return l.errApiResponseNotList;
    case LocalizedApiReason.operationIncomplete:
      return l.errApiOperationIncomplete;
    case LocalizedApiReason.authInvalidLoginResponse:
      return l.errAuthInvalidLoginResponse;
    case LocalizedApiReason.authInvalidRegisterResponse:
      return l.errAuthInvalidRegisterResponse;
    case LocalizedApiReason.authGoogleCancelled:
      return l.errAuthGoogleCancelled;
    case LocalizedApiReason.authInvalidGoogleLoginResponse:
      return l.errAuthInvalidGoogleLoginResponse;
    case LocalizedApiReason.uploadMissingFileSource:
      return l.errApiUploadMissingFileSource;
    case null:
      return e.message;
  }
}
