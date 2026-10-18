import 'package:flutter/material.dart';

import '../data/models.dart';

/// Every colour in the app lives here.
///
/// Two bases — Ink (dark) and Mono (light) — and three mood accents layered on
/// top: violet when steady, tangerine when slipping, aqua when thriving. See
/// docs/PRODUCT.md for when each mood applies.
@immutable
class TallyColors extends ThemeExtension<TallyColors> {
  const TallyColors({
    required this.mood,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.skipped,
    required this.danger,
    required this.ringBackground,
    required this.ringSurface,
    required this.ringText,
    required this.ringTextMuted,
    required this.ringAccent,
    required this.ringAccentSoft,
  });

  final Mood mood;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color text;
  final Color textMuted;

  /// The mood colour: progress, primary buttons, tally strokes.
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color skipped;
  final Color danger;

  /// The ring screen is always Ink, so it reads the same at 6 AM in either theme.
  final Color ringBackground;
  final Color ringSurface;
  final Color ringText;
  final Color ringTextMuted;
  final Color ringAccent;
  final Color ringAccentSoft;

  /// Kept for older call sites: completion uses the mood accent.
  Color get done => accent;
  Color get doneSoft => accentSoft;

  static const _inkAccents = {
    Mood.steady: (Color(0xFF9D8CFF), Color(0xFF1E1A33)),
    Mood.slipping: (Color(0xFFFF8A4C), Color(0xFF2A1A12)),
    Mood.thriving: (Color(0xFF4FE3C1), Color(0xFF0F2A26)),
  };

  static const _monoAccents = {
    Mood.steady: (Color(0xFF6A4CFF), Color(0xFFEEEAFF)),
    Mood.slipping: (Color(0xFFE8540F), Color(0xFFFFEBDD)),
    Mood.thriving: (Color(0xFF0FA888), Color(0xFFDDF7F0)),
  };

  static TallyColors of(Brightness brightness, Mood mood) {
    final (ringAccent, ringSoft) = _inkAccents[mood]!;
    if (brightness == Brightness.dark) {
      return TallyColors(
        mood: mood,
        background: const Color(0xFF0B0B0F),
        surface: const Color(0xFF15151B),
        surfaceMuted: const Color(0xFF1E1E26),
        border: const Color(0xFF24242D),
        text: const Color(0xFFF5F5F7),
        textMuted: const Color(0xFF8A8A96),
        accent: ringAccent,
        onAccent: const Color(0xFF0B0B0F),
        accentSoft: ringSoft,
        skipped: const Color(0xFF5A5A66),
        danger: const Color(0xFFFF6B6B),
        ringBackground: const Color(0xFF07070A),
        ringSurface: const Color(0xFF16161D),
        ringText: const Color(0xFFF5F5F7),
        ringTextMuted: const Color(0xFF8A8A96),
        ringAccent: ringAccent,
        ringAccentSoft: ringSoft,
      );
    }
    final (accent, soft) = _monoAccents[mood]!;
    return TallyColors(
      mood: mood,
      background: const Color(0xFFFFFFFF),
      surface: const Color(0xFFF6F6F8),
      surfaceMuted: const Color(0xFFEDEDF1),
      border: const Color(0xFFE6E6EB),
      text: const Color(0xFF0A0A0A),
      textMuted: const Color(0xFF8E8E93),
      accent: accent,
      onAccent: const Color(0xFFFFFFFF),
      accentSoft: soft,
      skipped: const Color(0xFFC7C7CC),
      danger: const Color(0xFFE5484D),
      ringBackground: const Color(0xFF07070A),
      ringSurface: const Color(0xFF16161D),
      ringText: const Color(0xFFF5F5F7),
      ringTextMuted: const Color(0xFF8A8A96),
      ringAccent: ringAccent,
      ringAccentSoft: ringSoft,
    );
  }

  @override
  TallyColors copyWith() => this;

  /// Lets the accent glide between moods instead of snapping.
  @override
  TallyColors lerp(TallyColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return TallyColors(
      mood: t < 0.5 ? mood : other.mood,
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceMuted: l(surfaceMuted, other.surfaceMuted),
      border: l(border, other.border),
      text: l(text, other.text),
      textMuted: l(textMuted, other.textMuted),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      accentSoft: l(accentSoft, other.accentSoft),
      skipped: l(skipped, other.skipped),
      danger: l(danger, other.danger),
      ringBackground: l(ringBackground, other.ringBackground),
      ringSurface: l(ringSurface, other.ringSurface),
      ringText: l(ringText, other.ringText),
      ringTextMuted: l(ringTextMuted, other.ringTextMuted),
      ringAccent: l(ringAccent, other.ringAccent),
      ringAccentSoft: l(ringAccentSoft, other.ringAccentSoft),
    );
  }
}

extension TallyColorsX on BuildContext {
  TallyColors get colors => Theme.of(this).extension<TallyColors>()!;
}
