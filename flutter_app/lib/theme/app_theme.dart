import 'package:flutter/material.dart';

abstract final class AppColors {
  static const blue = Color(0xFF006BFF);
  static const deepBlue = Color(0xFF0047C7);
  static const mint = Color(0xFF32E6B0);
  static const yellow = Color(0xFFFFD83D);
  static const navy = Color(0xFF071A3D);
  static const gray = Color(0xFF6B7280);
  static const softBackground = Color(0xFFF7FBFF);
  static const white = Colors.white;
  static const outline = Color(0xFFDCE7F5);
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.blue,
          onPrimary: AppColors.white,
          primaryContainer: const Color(0xFFE6F0FF),
          onPrimaryContainer: AppColors.deepBlue,
          secondary: AppColors.mint,
          onSecondary: AppColors.navy,
          secondaryContainer: const Color(0xFFD6FAEE),
          onSecondaryContainer: AppColors.navy,
          tertiary: AppColors.yellow,
          onTertiary: AppColors.navy,
          surface: AppColors.white,
          onSurface: AppColors.navy,
          onSurfaceVariant: AppColors.gray,
          surfaceContainerLowest: AppColors.white,
          surfaceContainerLow: AppColors.softBackground,
          surfaceContainer: const Color(0xFFEEF4FB),
          surfaceContainerHigh: const Color(0xFFE6F0FF),
          surfaceContainerHighest: const Color(0xFFDCE7F5),
          outline: AppColors.gray,
          outlineVariant: AppColors.outline,
          inverseSurface: AppColors.navy,
          onInverseSurface: AppColors.white,
          inversePrimary: const Color(0xFFA6CCFF),
          surfaceTint: AppColors.blue,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.softBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.softBackground,
        foregroundColor: AppColors.navy,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.blue
                : AppColors.gray,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.deepBlue
                : AppColors.gray,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: const TextStyle(color: AppColors.gray),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.blue, width: 2),
        ),
      ),
    );
  }
}
