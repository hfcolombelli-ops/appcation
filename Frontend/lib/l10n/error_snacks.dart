import 'package:flutter/material.dart';

import '../services/api_client.dart';
import 'api_exception_localizations.dart';
import 'app_localizations.dart';

/// Snackbars for common API / connectivity failures (avoid duplicating long `ScaffoldMessenger` blocks).
extension ErrorSnacks on BuildContext {
  void showErrApiConnectionSnack() {
    if (!mounted) return;
    final l = AppLocalizations.of(this);
    ScaffoldMessenger.maybeOf(this)?.showSnackBar(
      SnackBar(content: Text(l.errApiConnection)),
    );
  }

  void showLocalizedApiExceptionSnack(ApiException e) {
    if (!mounted) return;
    final l = AppLocalizations.of(this);
    ScaffoldMessenger.maybeOf(this)?.showSnackBar(
      SnackBar(content: Text(localizedApiMessage(l, e))),
    );
  }
}
