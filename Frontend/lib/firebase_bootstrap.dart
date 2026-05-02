import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Inicializa o Firebase Web usando `--dart-define` (ideal para Railway / CI).
///
/// Valores no Firebase Console → Configurações do projeto → Teus apps → Web.
/// Local com FlutterFire: `dart pub global activate flutterfire_cli` e
/// `flutterfire configure` (gera `firebase_options.dart`; podes fundir com isto depois).
Future<void> initFirebaseWeb() async {
  if (!kIsWeb) {
    return;
  }

  const projectId = String.fromEnvironment(
    'FIREBASE_WEB_PROJECT_ID',
    defaultValue: '',
  );

  if (projectId.isEmpty) {
    debugPrint(
      'Firebase Web: omitido (define FIREBASE_WEB_PROJECT_ID e restantes FIREBASE_WEB_* no build).',
    );
    return;
  }

  const measurementId = String.fromEnvironment(
    'FIREBASE_WEB_MEASUREMENT_ID',
    defaultValue: '',
  );

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: const String.fromEnvironment('FIREBASE_WEB_API_KEY'),
      appId: const String.fromEnvironment('FIREBASE_WEB_APP_ID'),
      messagingSenderId: const String.fromEnvironment(
        'FIREBASE_WEB_MESSAGING_SENDER_ID',
      ),
      projectId: projectId,
      authDomain: const String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN'),
      storageBucket: const String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET'),
      measurementId: measurementId.isEmpty ? null : measurementId,
    ),
  );

  debugPrint('Firebase Web OK (projeto: $projectId)');
}
