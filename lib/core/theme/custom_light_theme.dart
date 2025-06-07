import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/custom_color_scheme.dart';
import 'package:flutter_boilerplate/core/theme/custom_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom light theme for project design
final class CustomLightTheme implements CustomTheme {
  @override
  ThemeData get themeData => ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.roboto().fontFamily,
        colorScheme: CustomColorScheme.lightColorScheme,
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
  FloatingActionButtonThemeData get floatingActionButtonThemeData =>
      const FloatingActionButtonThemeData();

  @override
  AppBarTheme get appBarTheme => AppBarTheme(
        backgroundColor: CustomColorScheme.lightColorScheme.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme:
            IconThemeData(color: CustomColorScheme.lightColorScheme.onPrimary),
        titleTextStyle: TextStyle(
          color: CustomColorScheme.lightColorScheme.onPrimary,
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
          backgroundColor: CustomColorScheme.lightColorScheme.primary,
          foregroundColor: CustomColorScheme.lightColorScheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  @override
  IconThemeData get iconThemeData => const IconThemeData();

  @override
  TextButtonThemeData get textButtonThemeData => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CustomColorScheme.lightColorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  @override
  OutlinedButtonThemeData get outlinedButtonThemeData =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: CustomColorScheme.lightColorScheme.primary,
          foregroundColor: CustomColorScheme.lightColorScheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  @override
  TextTheme get textTheme => GoogleFonts.robotoTextTheme(
        const TextTheme(
          titleMedium: TextStyle(
            color: Colors.white,
          ),
        ),
      );
  @override
  SwitchThemeData get switchThemeData => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? null : null),
        trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? null : null),
        trackOutlineWidth: const WidgetStatePropertyAll(null),
      );

  @override
  TabBarTheme get tabBarTheme => TabBarTheme(
        labelColor: CustomColorScheme.lightColorScheme.onPrimary,
        // indicator: const UnderlineTabIndicator(
        //   borderSide: BorderSide(color: Colors.white, width: 2.0),
        // ),
      );
}
