import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as gsi_web;

import '../config.dart';
import '../services/google_sign_in_helper.dart';

/// Botão oficial Google Identity Services (GIS) no ecrã de login Web.
class OfficialGoogleWebLoginSlot extends StatefulWidget {
  const OfficialGoogleWebLoginSlot({
    super.key,
    required this.onIdToken,
    required this.loading,
  });

  final Future<void> Function(String idToken) onIdToken;
  final bool loading;

  @override
  State<OfficialGoogleWebLoginSlot> createState() => _OfficialGoogleWebLoginSlotState();
}

class _OfficialGoogleWebLoginSlotState extends State<OfficialGoogleWebLoginSlot> {
  StreamSubscription<GoogleSignInAuthenticationEvent>? _sub;
  Future<void>? _ready;
  Object? _initError;

  @override
  void initState() {
    super.initState();
    _ready = _prepare();
  }

  Future<void> _prepare() async {
    try {
      await ensureGoogleSignInInitialized();
      if (!mounted) return;
      _sub = GoogleSignIn.instance.authenticationEvents.listen(
        _onAuthEvent,
        onError: _onAuthError,
      );
    } catch (e, st) {
      _initError = e;
      debugPrint('OfficialGoogleWebLoginSlot init: $e\n$st');
    }
    if (mounted) setState(() {});
  }

  void _onAuthEvent(GoogleSignInAuthenticationEvent event) {
    if (event is! GoogleSignInAuthenticationEventSignIn) {
      return;
    }
    final raw = event.user.authentication.idToken;
    if (raw == null || raw.isEmpty) {
      return;
    }
    unawaited(widget.onIdToken(raw));
  }

  void _onAuthError(Object error, StackTrace stackTrace) {
    debugPrint('Google authenticationEvents error: $error');
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppConfig.googleWebClientId.trim().isEmpty) {
      return Text(
        'Configure GOOGLE_WEB_CLIENT_ID',
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
      );
    }

    if (_initError != null) {
      return Text(
        'Google Sign-In: $_initError',
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
      );
    }

    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 48,
            child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        if (_initError != null) {
          return const SizedBox.shrink();
        }
        return Opacity(
          opacity: widget.loading ? 0.55 : 1,
          child: AbsorbPointer(
            absorbing: widget.loading,
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: gsi_web.renderButton(
                  configuration: gsi_web.GSIButtonConfiguration(
                    type: gsi_web.GSIButtonType.standard,
                    theme: gsi_web.GSIButtonTheme.outline,
                    size: gsi_web.GSIButtonSize.large,
                    text: gsi_web.GSIButtonText.continueWith,
                    shape: gsi_web.GSIButtonShape.rectangular,
                    minimumWidth: 320,
                    locale: Localizations.localeOf(context).toLanguageTag(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
