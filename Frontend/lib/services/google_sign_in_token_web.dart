import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as gsi_web;

import '../app_navigator.dart';
import '../config.dart';
import '../l10n/app_localizations.dart';
import 'google_sign_in_errors.dart';

bool _googleSignInInitialized = false;

/// Expõe init partilhado (botão GIS no login + overlay re-auth).
Future<void> ensureGoogleSignInInitializedForPlatform() async {
  if (_googleSignInInitialized) {
    return;
  }
  final cid = AppConfig.googleWebClientId.trim();
  if (cid.isEmpty) {
    throw const GoogleSignInFailure(GoogleSignInFailureKind.webClientIdMissing);
  }
  // Web: `serverClientId` não é suportado (assert no plugin); o id_token usa `aud` = clientId Web.
  await GoogleSignIn.instance.initialize(
    clientId: cid,
    serverClientId: null,
  );
  _googleSignInInitialized = true;
}

Future<void> _ensureGoogleSignInInitialized() => ensureGoogleSignInInitializedForPlatform();

/// Web: GIS exige o botão oficial (`renderButton`); `authenticate` não está implementado no plugin Web.
Future<String?> obtainGoogleIdToken({
  BuildContext? context,
  bool forceAccountPicker = false,
}) async {
  await _ensureGoogleSignInInitialized();

  if (forceAccountPicker) {
    await GoogleSignIn.instance.signOut();
  }

  final BuildContext? overlayCtx = context ?? appNavigatorKey.currentContext;
  if (overlayCtx == null || !overlayCtx.mounted) {
    throw const GoogleSignInFailure(
      GoogleSignInFailureKind.signInError,
      detail: 'Contexto indisponível para Google Sign-In na Web.',
    );
  }

  final overlay = Overlay.maybeOf(overlayCtx, rootOverlay: true);
  if (overlay == null) {
    throw const GoogleSignInFailure(
      GoogleSignInFailureKind.signInError,
      detail: 'Overlay indisponível para Google Sign-In na Web.',
    );
  }

  final completer = Completer<String?>();
  StreamSubscription<GoogleSignInAuthenticationEvent>? sub;
  late final OverlayEntry entry;
  var cleaned = false;

  Future<void> cleanup() async {
    if (cleaned) return;
    cleaned = true;
    await sub?.cancel();
    if (entry.mounted) {
      entry.remove();
    }
  }

  final lang = AppLocalizations.of(overlayCtx);

  entry = OverlayEntry(
    builder: (ctx) {
      return Positioned.fill(
        child: Material(
          color: Colors.black54,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(ctx).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        lang.googleContinue,
                        style: Theme.of(ctx).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: gsi_web.renderButton(
                          configuration: gsi_web.GSIButtonConfiguration(
                            theme: gsi_web.GSIButtonTheme.filledBlue,
                            size: gsi_web.GSIButtonSize.large,
                            text: gsi_web.GSIButtonText.continueWith,
                            minimumWidth: 320,
                            locale: Localizations.localeOf(overlayCtx).toLanguageTag(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () async {
                          await cleanup();
                          if (!completer.isCompleted) completer.complete(null);
                        },
                        child: Text(lang.mfgBtnCancel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  sub = GoogleSignIn.instance.authenticationEvents.listen(
    (GoogleSignInAuthenticationEvent event) async {
      if (event is! GoogleSignInAuthenticationEventSignIn) {
        return;
      }
      final raw = event.user.authentication.idToken;
      await cleanup();
      if (completer.isCompleted) return;
      if (raw == null || raw.isEmpty) {
        completer.completeError(const GoogleSignInFailure(GoogleSignInFailureKind.idTokenMissing));
      } else {
        completer.complete(raw);
      }
    },
    onError: (Object error, StackTrace stack) async {
      await cleanup();
      if (completer.isCompleted) return;
      if (error is GoogleSignInException) {
        if (error.code == GoogleSignInExceptionCode.canceled) {
          completer.complete(null);
          return;
        }
        completer.completeError(
          GoogleSignInFailure(
            GoogleSignInFailureKind.signInError,
            detail: error.description ?? error.toString(),
          ),
        );
        return;
      }
      completer.completeError(
        GoogleSignInFailure(
          GoogleSignInFailureKind.signInError,
          detail: error.toString(),
        ),
      );
    },
  );

  overlay.insert(entry);

  try {
    return await completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () async {
        await cleanup();
        return null;
      },
    );
  } finally {
    await cleanup();
  }
}
