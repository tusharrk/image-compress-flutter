import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/constants/app_colors.dart';

/// Project custom colors
final class CustomColorScheme {
  CustomColorScheme._();

  /// Light color scheme set
  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    // Rich Blue as primary
    primary: AppColors.richBlue,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.lightBlue,
    onPrimaryContainer: AppColors.black,
    // Vibrant Blue as secondary
    secondary: AppColors.vibrantBlue,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.lightBlue,
    onSecondaryContainer: AppColors.black,
    // Deep Blue as tertiary
    tertiary: AppColors.deepBlue,
    onTertiary: AppColors.white,
    tertiaryContainer: AppColors.richBlue,
    onTertiaryContainer: AppColors.white,
    // Error colors
    error: AppColors.error,
    onError: AppColors.white,
    errorContainer: AppColors.errorLight,
    onErrorContainer: AppColors.errorDark,
    // Background and surface colors
    outline: AppColors.darkGray,
    surface: AppColors.offWhite,
    onSurface: AppColors.black,
    surfaceContainerHighest: AppColors.lightGray,
    onSurfaceVariant: AppColors.darkGray,
    inverseSurface: AppColors.black,
    onInverseSurface: AppColors.white,
    inversePrimary: AppColors.lightBlue,
    shadow: AppColors.shadow,
    surfaceTint: AppColors.richBlue,
    outlineVariant: AppColors.lightGray,
    scrim: AppColors.scrim,
  );

  /// Dark color scheme set
  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    // Light Blue as primary for dark theme
    primary: AppColors.lightBlue,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.vibrantBlue,
    onPrimaryContainer: AppColors.white,
    // Rich Blue as secondary
    secondary: AppColors.richBlue,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.deepBlue,
    onSecondaryContainer: AppColors.white,
    // Vibrant Blue as tertiary
    tertiary: AppColors.vibrantBlue,
    onTertiary: AppColors.white,
    tertiaryContainer: AppColors.deepBlue,
    onTertiaryContainer: AppColors.white,
    // Error colors
    error: AppColors.errorLight,
    onError: AppColors.errorDark,
    errorContainer: AppColors.error,
    onErrorContainer: AppColors.white,
    // Background and surface colors
    outline: AppColors.lightGray,
    surface: AppColors.black,
    onSurface: AppColors.white,
    surfaceContainerHighest: AppColors.darkGray,
    onSurfaceVariant: AppColors.lightGray,
    inverseSurface: AppColors.white,
    onInverseSurface: AppColors.black,
    inversePrimary: AppColors.richBlue,
    shadow: AppColors.shadow,
    surfaceTint: AppColors.lightBlue,
    outlineVariant: AppColors.mediumGray,
    scrim: AppColors.scrim,
  );
}
