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

  testWidgets('login screen smoke test', (WidgetTester tester) async {
    final binding = TestWidgetsFlutterBinding.instance;
    await binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 8));

    expect(find.byKey(const ValueKey('login-universal')), findsOneWidget);

    final entrar = find.text('Entrar');
    await tester.scrollUntilVisible(entrar, 400);
    expect(entrar, findsOneWidget);
  });
}
