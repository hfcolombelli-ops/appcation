import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/clinical_precision_tokens.dart';

/// Quando `role` da API não mapeia para um shell (evita mostrar o login com sessão ainda válida).
/// Alinhado ao nó “Sem Perfil” / falha de identificação do fluxograma em `docs/product/fluxo_app2cation.mermaid`.
class ProfileGateScreen extends StatelessWidget {
  const ProfileGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ClinicalPrecisionColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.manage_accounts_outlined, size: 48, color: ClinicalPrecisionColors.secondary.withValues(alpha: 0.85)),
                  const SizedBox(height: 18),
                  Text(
                    l.profileGateTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: ClinicalPrecisionColors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.profileGateBody,
                    style: const TextStyle(color: ClinicalPrecisionColors.onSurfaceVariant, height: 1.45, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l.profileGateDocHint,
                    style: TextStyle(fontSize: 12, color: ClinicalPrecisionColors.onSurfaceVariant.withValues(alpha: 0.85), height: 1.35),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () => appAuth.logout(),
                    style: FilledButton.styleFrom(
                      backgroundColor: ClinicalPrecisionColors.secondary,
                      foregroundColor: ClinicalPrecisionColors.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l.actionSignOut),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
