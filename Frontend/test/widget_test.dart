import 'package:appcation/app_state.dart';
import 'package:appcation/main.dart';
import 'package:appcation/services/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    appAuth = AuthSession();
  });

  /// Não usar [MyApp] aqui: o tema chama `GoogleFonts.*` e falha em muitos CIs
  /// mesmo com `allowRuntimeFetching: false`. Isto só valida o ecrã de login.
  testWidgets('login screen smoke test', (WidgetTester tester) async {
    final binding = TestWidgetsFlutterBinding.instance;
    await binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const LoginUniversalScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const ValueKey('login-universal')), findsOneWidget);

    final entrar = find.text('Entrar');
    await tester.scrollUntilVisible(entrar, 400);
    expect(entrar, findsOneWidget);
  });
}
