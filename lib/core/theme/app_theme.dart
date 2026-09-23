import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Material is only used for structure (Scaffold, TextField). Its visual
/// defaults are switched off: no ripple, no elevation tint, no purple seed.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppFonts.dmSans,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      secondary: AppColors.accentSoft,
      surface: AppColors.bg,
      onSurface: AppColors.ink,
      error: AppColors.errorInk,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.accent,
      selectionColor: AppColors.spinnerTrack,
      selectionHandleColor: AppColors.accent,
    ),
  );
}
