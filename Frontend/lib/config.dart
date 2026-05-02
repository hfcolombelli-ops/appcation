/// URL base da API Laravel (sem barra final). O app chama rotas `/api/...` em cima disso.
/// Ex.: `flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000`
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  /// OAuth Client ID tipo Web (mesmo valor que `GOOGLE_CLIENT_ID` no Laravel).
  /// Sobrescreve com `--dart-define=GOOGLE_WEB_CLIENT_ID=...` noutro ambiente.
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '71104147877-c81cu1eda0r0n869n70jf686n1bs2v5t.apps.googleusercontent.com',
  );
}
