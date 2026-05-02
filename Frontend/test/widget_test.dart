import 'package:appcation/app_state.dart';
import 'package:appcation/l10n/app_localizations.dart';
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

  /// Não usar [MyApp] aqui: o tema chama `GoogleFonts.*` e falha em muitos CIs.
  testWidgets('login screen smoke test', (WidgetTester tester) async {
    final binding = TestWidgetsFlutterBinding.instance;
    await binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        theme: ThemeData(useMaterial3: true),
        home: const LoginUniversalScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const ValueKey('login-universal')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-submit')), findsOneWidget);
    final signIn = lookupAppLocalizations(const Locale('pt')).actionSignIn;
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('login-submit')),
        matching: find.text(signIn),
      ),
      findsOneWidget,
    );
  });
}
