import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/custom_color_scheme.dart';
import 'package:flutter_boilerplate/core/theme/custom_theme.dart';

/// Custom light theme for project design
final class CustomDarkTheme implements CustomTheme {
  @override
  ThemeData get themeData => ThemeData(
        useMaterial3: true,
        colorScheme: CustomColorScheme.darkColorScheme,
        floatingActionButtonTheme: floatingActionButtonThemeData,
        appBarTheme: appBarTheme,
        cardTheme: cardThemeData,
        elevatedButtonTheme: elevatedButtonThemeData,
        textButtonTheme: textButtonThemeData,
        textTheme: textTheme,
        iconTheme: iconThemeData,
        switchTheme: switchThemeData,
        tabBarTheme: tabBarTheme,
      );

  @override
  final FloatingActionButtonThemeData floatingActionButtonThemeData =
      const FloatingActionButtonThemeData();
  @override
  AppBarTheme get appBarTheme => AppBarTheme(
        backgroundColor: CustomColorScheme.darkColorScheme.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme:
            IconThemeData(color: CustomColorScheme.darkColorScheme.onPrimary),
        titleTextStyle: TextStyle(
          color: CustomColorScheme.darkColorScheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );

  @override
  CardThemeData get cardThemeData => const CardThemeData();

  @override
  ElevatedButtonThemeData get elevatedButtonThemeData =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColorScheme.darkColorScheme.primary,
          foregroundColor: CustomColorScheme.darkColorScheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  @override
  IconThemeData get iconThemeData => const IconThemeData();

  @override
  TextButtonThemeData get textButtonThemeData => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CustomColorScheme.darkColorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  @override
  OutlinedButtonThemeData get outlinedButtonThemeData =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: CustomColorScheme.darkColorScheme.primary,
          foregroundColor: CustomColorScheme.darkColorScheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  @override
  TextTheme get textTheme => const TextTheme();

  @override
  SwitchThemeData get switchThemeData => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? CustomColorScheme.darkColorScheme.outline
                : CustomColorScheme.darkColorScheme.outline),
        trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? null : null),
        trackOutlineWidth: const WidgetStatePropertyAll(0.5),
      );

  @override
  TabBarTheme get tabBarTheme => TabBarTheme(
        labelColor: CustomColorScheme.darkColorScheme.onPrimary,
        // indicator: const UnderlineTabIndicator(
        //   borderSide: BorderSide(color: Colors.white, width: 2.0),
        // ),
      );
}
