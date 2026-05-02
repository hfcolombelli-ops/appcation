import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config.dart';

/// Obtém um ID token para enviar a `POST /api/auth/google`.
Future<String?> obtainGoogleIdToken({bool forceAccountPicker = false}) async {
  final clientId = AppConfig.googleWebClientId.trim();
  if (clientId.isEmpty) {
    throw StateError(
      'Configure GOOGLE_WEB_CLIENT_ID (dart-define) igual ao OAuth Client ID Web no Google Cloud.',
    );
  }

  final google = GoogleSignIn(
    scopes: const ['email', 'profile'],
    clientId: kIsWeb ? clientId : null,
  );

  if (forceAccountPicker) {
    await google.signOut();
  }

  final account = await google.signIn();
  if (account == null) {
    return null;
  }

  final auth = await account.authentication;
  final token = auth.idToken;
  if (token == null || token.isEmpty) {
    throw StateError('Google não devolveu id_token. Verifique o Client ID Web e os scopes.');
  }

  return token;
}
