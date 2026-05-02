import 'package:appcation/app_state.dart';
import 'package:appcation/main.dart';
import 'package:appcation/services/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    appAuth = AuthSession();
  });

  testWidgets('login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Acesse o App'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
