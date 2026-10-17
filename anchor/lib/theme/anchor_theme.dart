import 'package:flutter/material.dart';

import 'anchor_colors.dart';

ThemeData anchorTheme(Brightness brightness) {
  final c = brightness == Brightness.light ? AnchorColors.light : AnchorColors.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: c.accent,
    brightness: brightness,
  ).copyWith(
    primary: c.accent,
    onPrimary: c.onAccent,
    surface: c.surface,
    onSurface: c.text,
    error: c.danger,
    outline: c.border,
    outlineVariant: c.border,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness);
  final text = base.textTheme.apply(bodyColor: c.text, displayColor: c.text);
  final radius = BorderRadius.circular(16);

  return base.copyWith(
    scaffoldBackgroundColor: c.background,
    extensions: [c],
    textTheme: text.copyWith(
      headlineLarge: text.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.8),
      headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.4),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: text.labelSmall?.copyWith(color: c.textMuted, letterSpacing: 0.6),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: c.text,
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: c.border)),
    ),
    dividerTheme: DividerThemeData(color: c.border, space: 1, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: c.accent,
      foregroundColor: c.onAccent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceMuted,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: c.textMuted),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: c.surfaceMuted,
      selectedColor: c.accent,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: TextStyle(color: c.text, fontWeight: FontWeight.w500),
      secondaryLabelStyle: TextStyle(color: c.onAccent, fontWeight: FontWeight.w600),
      showCheckmark: false,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.accent : c.surfaceMuted,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.onAccent : c.text,
        ),
        side: const WidgetStatePropertyAll(BorderSide.none),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: c.accentSoft,
      elevation: 0,
      height: 68,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(color: s.contains(WidgetState.selected) ? c.accent : c.textMuted),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 12,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
          color: s.contains(WidgetState.selected) ? c.text : c.textMuted,
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: c.border,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
  );
}
