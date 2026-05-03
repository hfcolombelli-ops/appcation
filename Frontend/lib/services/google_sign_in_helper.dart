import 'package:flutter/widgets.dart';

import 'google_sign_in_token_io.dart' if (dart.library.html) 'google_sign_in_token_web.dart' as token;

/// Garante `GoogleSignIn.instance.initialize` uma vez (login Web com botão GIS, mobile, overlay).
Future<void> ensureGoogleSignInInitialized() =>
    token.ensureGoogleSignInInitializedForPlatform();

/// Obtém um ID token para `POST /api/auth/google`.
///
/// Em **Web** o `google_sign_in` 7.x não implementa `authenticate()`; usamos o botão GIS
/// (`renderButton`) num overlay. Passa sempre um [context] com overlay (ex.: ecrã de login).
///
/// Em **Android / iOS / desktop** usa `authenticate` com scopes openid.
Future<String?> obtainGoogleIdToken({
  BuildContext? context,
  bool forceAccountPicker = false,
}) =>
    token.obtainGoogleIdToken(context: context, forceAccountPicker: forceAccountPicker);
