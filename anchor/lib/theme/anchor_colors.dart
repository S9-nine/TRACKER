import 'package:flutter/material.dart';

/// Every colour in the app lives here. Colours are placeholders for now —
/// change them in this file and the whole app follows.
@immutable
class AnchorColors extends ThemeExtension<AnchorColors> {
  const AnchorColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.done,
    required this.doneSoft,
    required this.skipped,
    required this.danger,
    required this.ringBackground,
    required this.ringText,
  });

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color done;
  final Color doneSoft;
  final Color skipped;
  final Color danger;
  final Color ringBackground;
  final Color ringText;

  static const light = AnchorColors(
    background: Color(0xFFF7F7F8),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF0F0F2),
    border: Color(0xFFE6E6EA),
    text: Color(0xFF111114),
    textMuted: Color(0xFF6E6E78),
    accent: Color(0xFF4F46E5),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFEEEDFC),
    done: Color(0xFF16A34A),
    doneSoft: Color(0xFFE7F6EC),
    skipped: Color(0xFFA1A1AA),
    danger: Color(0xFFDC2626),
    ringBackground: Color(0xFF111114),
    ringText: Color(0xFFFFFFFF),
  );

  static const dark = AnchorColors(
    background: Color(0xFF0E0E10),
    surface: Color(0xFF18181B),
    surfaceMuted: Color(0xFF232327),
    border: Color(0xFF2A2A2F),
    text: Color(0xFFF4F4F5),
    textMuted: Color(0xFF9F9FA9),
    accent: Color(0xFF818CF8),
    onAccent: Color(0xFF0E0E10),
    accentSoft: Color(0xFF25234A),
    done: Color(0xFF4ADE80),
    doneSoft: Color(0xFF15301F),
    skipped: Color(0xFF71717A),
    danger: Color(0xFFF87171),
    ringBackground: Color(0xFF000000),
    ringText: Color(0xFFFFFFFF),
  );

  @override
  AnchorColors copyWith() => this;

  @override
  AnchorColors lerp(AnchorColors? other, double t) => t < 0.5 ? this : other ?? this;
}

extension AnchorColorsX on BuildContext {
  AnchorColors get colors => Theme.of(this).extension<AnchorColors>()!;
}
