import 'package:flutter/material.dart';

/// Tokens alinhados a `clinical_precision/DESIGN.md` e protótipos Stitch (Tailwind).
abstract final class ClinicalPrecisionColors {
  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color primaryContainer = Color(0xFF131B2E);
  static const Color onPrimaryContainer = Color(0xFF7C839B);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF45464D);
  static const Color outlineVariant = Color(0xFFC6C6CD);
  static const Color secondary = Color(0xFF00677D);
  static const Color secondaryContainer = Color(0xFF50D9FE);
  static const Color secondaryFixedDim = Color(0xFF4CD6FB);
  static const Color onSecondary = Color(0xFFFFFFFF);
}

abstract final class ClinicalPrecisionRadii {
  static const double cardHero = 32;
  static const double cardInner = 16;
  static const double button = 12;
}

abstract final class ClinicalPrecisionShadows {
  static List<BoxShadow> loginCard = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
      blurRadius: 40,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> ambientCard = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}
