import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config.dart';
import 'google_sign_in_errors.dart';

bool _googleSignInInitialized = false;

/// Expõe init partilhado (ecrã de login Web oficial + overlay re-auth).
Future<void> ensureGoogleSignInInitializedForPlatform() async {
  if (_googleSignInInitialized) {
    return;
  }
  final cid = AppConfig.googleWebClientId.trim();
  if (cid.isEmpty) {
    throw const GoogleSignInFailure(GoogleSignInFailureKind.webClientIdMissing);
  }
  await GoogleSignIn.instance.initialize(
    clientId: null,
    serverClientId: cid,
  );
  _googleSignInInitialized = true;
}

Future<void> _ensureGoogleSignInInitialized() => ensureGoogleSignInInitializedForPlatform();

/// Android / iOS / desktop: `authenticate` com scopeHint (openid).
Future<String?> obtainGoogleIdToken({
  BuildContext? context,
  bool forceAccountPicker = false,
}) async {
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
      throw const GoogleSignInFailure(GoogleSignInFailureKind.idTokenMissing);
    }
    return token;
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) {
      return null;
    }
    throw GoogleSignInFailure(
      GoogleSignInFailureKind.signInError,
      detail: e.description ?? e.toString(),
    );
  }
}
