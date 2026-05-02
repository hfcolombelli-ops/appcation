import '../services/google_sign_in_errors.dart';
import 'app_localizations.dart';

String localizedGoogleSignInFailure(AppLocalizations l, GoogleSignInFailure e) {
  switch (e.kind) {
    case GoogleSignInFailureKind.webClientIdMissing:
      return l.errGoogleClientId;
    case GoogleSignInFailureKind.idTokenMissing:
      return l.errGoogleNoIdToken;
    case GoogleSignInFailureKind.signInError:
      return l.errGoogleSignInFailed(e.detail ?? '');
  }
}
