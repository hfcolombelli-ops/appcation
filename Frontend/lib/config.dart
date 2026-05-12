/// URL base da API Laravel (sem barra final). O app chama rotas `/api/...` em cima disso.
/// Ex.: `flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000`
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}
