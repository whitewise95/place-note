import 'package:flutter/material.dart';

class AppTheme {
  static const Color paper = Color(0xFFF6F2EA);
  static const Color paperDeep = Color(0xFFE8DDCE);
  static const Color surface = Color(0xFFFFFCF5);
  static const Color surfaceAlt = Color(0xFFF1E7D8);
  static const Color brown = Color(0xFF2F2923);
  static const Color acorn = Color(0xFF6B5542);
  static const Color caramel = Color(0xFFE08A32);
  static const Color sage = Color(0xFF6D8D70);
  static const Color ink = Color(0xFF211D19);
  static const Color muted = Color(0xFF75675A);
  static const Color line = Color(0xFFDCCBB7);
  static const Color elevatedSurface = surface;

  static const Color navy = brown;
  static const Color teal = sage;
  static const Color mint = surfaceAlt;
  static const Color amber = caramel;

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brown,
      primary: brown,
      secondary: caramel,
      tertiary: sage,
      surface: surface,
      error: const Color(0xFF9F3A2D),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: paper,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: CardThemeData(
        color: elevatedSurface,
        elevation: 1,
        shadowColor: const Color(0x1F2F2923),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: line),
        ),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1),
      tabBarTheme: const TabBarThemeData(
        labelColor: brown,
        unselectedLabelColor: muted,
        indicatorColor: caramel,
        dividerColor: line,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: const Color(0xFFFFE2B8),
        checkmarkColor: brown,
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: const TextStyle(
          color: ink,
          fontWeight: FontWeight.w700,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? const Color(0xFFFFE2B8)
                : surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected) ? brown : muted;
          }),
          side: WidgetStateProperty.all(const BorderSide(color: line)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: brown,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: surface,
          foregroundColor: brown,
          side: const BorderSide(color: line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: acorn,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brown,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: caramel, width: 2),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: caramel,
        linearTrackColor: paperDeep,
        circularTrackColor: paperDeep,
      ),
    );
  }
}
