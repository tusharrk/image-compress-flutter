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
        outlinedButtonTheme: outlinedButtonThemeData,
        textButtonTheme: textButtonThemeData,
        textTheme: textTheme,
        iconTheme: iconThemeData,
        switchTheme: switchThemeData,
        tabBarTheme: tabBarTheme,
      );

  @override
  FloatingActionButtonThemeData get floatingActionButtonThemeData =>
      FloatingActionButtonThemeData(
        backgroundColor: CustomColorScheme.lightColorScheme.primary,
        foregroundColor: CustomColorScheme.lightColorScheme.onPrimary,
      );

  @override
  AppBarTheme get appBarTheme => AppBarTheme(
        backgroundColor: CustomColorScheme.lightColorScheme.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: CustomColorScheme.lightColorScheme.onPrimary,
        ),
        titleTextStyle: TextStyle(
          color: CustomColorScheme.lightColorScheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );

  @override
  CardThemeData get cardThemeData => CardThemeData(
        color: CustomColorScheme.lightColorScheme.surface,
        elevation: 2,
        shadowColor: CustomColorScheme.lightColorScheme.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  ElevatedButtonThemeData get elevatedButtonThemeData =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColorScheme.lightColorScheme.primary,
          foregroundColor: CustomColorScheme.lightColorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  @override
  OutlinedButtonThemeData get outlinedButtonThemeData =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: CustomColorScheme.lightColorScheme.primary,
          side: BorderSide(color: CustomColorScheme.lightColorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  @override
  TextButtonThemeData get textButtonThemeData => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CustomColorScheme.lightColorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  @override
  TextTheme get textTheme => GoogleFonts.robotoTextTheme(
        const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
          labelLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  @override
  IconThemeData get iconThemeData => IconThemeData(
        color: CustomColorScheme.lightColorScheme.primary,
      );

  @override
  SwitchThemeData get switchThemeData => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? CustomColorScheme.lightColorScheme.primary
                : CustomColorScheme.lightColorScheme.outline),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? CustomColorScheme.lightColorScheme.primary.withOpacity(0.5)
                : CustomColorScheme.lightColorScheme.outlineVariant),
      );

  @override
  TabBarTheme get tabBarTheme => TabBarTheme(
        // TabBar background is primary blue - so texts must be light
        labelColor: CustomColorScheme.lightColorScheme.onPrimary, // white
        unselectedLabelColor:
            CustomColorScheme.lightColorScheme.onPrimary.withOpacity(0.7),
        // indicator: UnderlineTabIndicator(
        //   borderSide: BorderSide(
        //     color:
        //         CustomColorScheme.lightColorScheme.onPrimary, // white underline
        //     width: 2,
        //   ),
        // ),
        // Add background color for TabBar container if needed outside theme
      );
}
