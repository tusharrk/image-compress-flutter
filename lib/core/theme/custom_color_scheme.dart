import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/constants/app_colors.dart';

/// Project custom colors
final class CustomColorScheme {
  CustomColorScheme._();

  /// Light color scheme
  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.black,
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.primaryLight,
    onSecondaryContainer: AppColors.black,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.white,
    tertiaryContainer: AppColors.primary,
    onTertiaryContainer: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
    errorContainer: AppColors.errorLight,
    onErrorContainer: AppColors.errorDark,
    outline: AppColors.darkGray,
    surface: AppColors.offWhite,
    onSurface: AppColors.black,
    surfaceContainerHighest: AppColors.lightGray,
    onSurfaceVariant: AppColors.darkGray,
    inverseSurface: AppColors.black,
    onInverseSurface: AppColors.white,
    inversePrimary: AppColors.primaryLight,
    shadow: AppColors.shadow,
    surfaceTint: AppColors.primary,
    outlineVariant: AppColors.lightGray,
    scrim: AppColors.scrim,
  );

  /// Dark color scheme
  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.secondary,
    onPrimaryContainer: AppColors.white,
    secondary: AppColors.primary,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.tertiary,
    onSecondaryContainer: AppColors.white,
    tertiary: AppColors.secondary,
    onTertiary: AppColors.white,
    tertiaryContainer: AppColors.primaryDark,
    onTertiaryContainer: AppColors.white,
    error: AppColors.errorLight,
    onError: AppColors.errorDark,
    errorContainer: AppColors.error,
    onErrorContainer: AppColors.white,
    outline: AppColors.lightGray,
    surface: AppColors.black,
    onSurface: AppColors.white,
    surfaceContainerHighest: AppColors.darkGray,
    onSurfaceVariant: AppColors.lightGray,
    inverseSurface: AppColors.white,
    onInverseSurface: AppColors.black,
    inversePrimary: AppColors.primary,
    shadow: AppColors.shadow,
    surfaceTint: AppColors.primaryLight,
    outlineVariant: AppColors.mediumGray,
    scrim: AppColors.scrim,
  );
}
