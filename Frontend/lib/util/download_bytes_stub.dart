import 'dart:typed_data';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:appcation/l10n/app_localizations.dart';

bool get downloadBytesSupported => false;

AppLocalizations _localizationsForPlatform() {
  final code = PlatformDispatcher.instance.locale.languageCode;
  final locale = code == 'pt' ? const Locale('pt') : const Locale('en');
  return lookupAppLocalizations(locale);
}

void downloadBytesAsFile(Uint8List bytes, String filename) {
  throw UnsupportedError(_localizationsForPlatform().utilDownloadWebOnly);
}
