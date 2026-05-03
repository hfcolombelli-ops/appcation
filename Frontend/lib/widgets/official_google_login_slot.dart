import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'official_google_login_slot_io.dart' if (dart.library.html) 'official_google_login_slot_web.dart' as impl;

/// Na **Web** mostra o botão oficial GIS; noutras plataformas mostra [fallback] (ex.: `FilledButton` App²cation).
class OfficialGoogleLoginSlot extends StatelessWidget {
  const OfficialGoogleLoginSlot({
    super.key,
    required this.fallback,
    required this.onWebGoogleToken,
    this.loading = false,
  });

  final Widget fallback;
  final Future<void> Function(String idToken) onWebGoogleToken;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return impl.OfficialGoogleWebLoginSlot(
        onIdToken: onWebGoogleToken,
        loading: loading,
      );
    }
    return fallback;
  }
}
