import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config.dart';

bool _googleSignInInitialized = false;

Future<void> _ensureGoogleSignInInitialized() async {
  if (_googleSignInInitialized) {
    return;
  }
  final cid = AppConfig.googleWebClientId.trim();
  if (cid.isEmpty) {
    throw StateError(
      'Configure GOOGLE_WEB_CLIENT_ID (dart-define) igual ao OAuth Client ID Web no Google Cloud.',
    );
  }
  await GoogleSignIn.instance.initialize(
    clientId: kIsWeb ? cid : null,
    serverClientId: cid,
  );
  _googleSignInInitialized = true;
}

/// Obtém um ID token para enviar a `POST /api/auth/google`.
/// Usa a API do `google_sign_in` 7.x (`authenticate` + `scopeHint` com openid).
Future<String?> obtainGoogleIdToken({bool forceAccountPicker = false}) async {
  await _ensureGoogleSignInInitialized();

  if (forceAccountPicker) {
    await GoogleSignIn.instance.signOut();
  }

  try {
    final account = await GoogleSignIn.instance.authenticate(
      scopeHint: const ['openid', 'email', 'profile'],
    );
    final token = account.authentication.idToken;
    if (token == null || token.isEmpty) {
      throw StateError('Google não devolveu id_token. Verifique o Client ID Web e as APIs no Google Cloud.');
    }
    return token;
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) {
      return null;
    }
    throw StateError(e.description ?? e.toString());
  }
}
