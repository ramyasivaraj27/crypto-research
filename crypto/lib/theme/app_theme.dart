import 'package:flutter/material.dart';

/// Dark CoinGecko-style theme from the reference design.
class AppColors {
  static const background = Color(0xFF121214);
  static const card = Color(0xFF2A2A2E);
  static const cardPressed = Color(0xFF333338);
  static const rankBadge = Color(0xFF1C1C1F);
  static const gain = Color(0xFF5DBB63);
  static const loss = Color(0xFFE05252);
  static const chartLine = Color(0xFF7DFF7A);
  static const muted = Color(0xFF9E9EA3);
  static const selectedPill = Color(0xFF3A3A3F);
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.selectedPill,
      shape: const StadiumBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      hintStyle: const TextStyle(color: AppColors.muted),
      labelStyle: const TextStyle(color: AppColors.muted),
      floatingLabelStyle: const TextStyle(color: AppColors.chartLine),
      prefixIconColor: AppColors.muted,
      suffixIconColor: AppColors.muted,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.cardPressed),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.chartLine, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.loss),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.loss, width: 1.5),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.chartLine,
      selectionColor: Color(0x667DFF7A),
      selectionHandleColor: AppColors.chartLine,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF3A3A3F), thickness: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.chartLine,
    ),
    textTheme: base.textTheme.apply(
      displayColor: Colors.white,
      bodyColor: Colors.white,
    ),
  );
}
