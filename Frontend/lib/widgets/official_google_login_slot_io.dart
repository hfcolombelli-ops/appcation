import 'package:flutter/widgets.dart';

/// Só para satisfazer o import condicional em plataformas sem `dart.library.html` (nunca usado: `kIsWeb` é falso).
class OfficialGoogleWebLoginSlot extends StatelessWidget {
  const OfficialGoogleWebLoginSlot({
    super.key,
    required this.onIdToken,
    required this.loading,
  });

  final Future<void> Function(String idToken) onIdToken;
  final bool loading;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
