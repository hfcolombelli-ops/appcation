import 'package:flutter/material.dart';

import 'clinical_precision_tokens.dart';

/// Canvas único para miúdos do shell instrutor/gestor (alinhamento Stitch — passo 1).
Widget instructorShellScaffold({required Widget child}) {
  return ColoredBox(color: ClinicalPrecisionColors.surface, child: child);
}

/// Cartão plano com raio/borda alinhados à sala de comando.
Widget instructorShellCard({
  required Widget child,
  Color? color,
  EdgeInsetsGeometry? margin,
}) {
  final bg = color ?? ClinicalPrecisionColors.surfaceContainerLowest;
  final dark = bg.computeLuminance() < 0.35;
  return Card(
    margin: margin ?? EdgeInsets.zero,
    color: bg,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ClinicalPrecisionRadii.cardInner),
      side: BorderSide(
        color: dark ? Colors.white.withValues(alpha: 0.14) : ClinicalPrecisionColors.outlineVariant.withValues(alpha: 0.35),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
}
