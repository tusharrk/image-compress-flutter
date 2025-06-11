import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/custom_color_scheme.dart';
import 'package:flutter_boilerplate/core/theme/custom_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom light theme for project design
final class CustomDarkTheme implements CustomTheme {
  @override
  ThemeData get themeData => ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.roboto().fontFamily,
        colorScheme: CustomColorScheme.darkColorScheme,
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
        backgroundColor: CustomColorScheme.darkColorScheme.primary,
        foregroundColor: CustomColorScheme.darkColorScheme.onPrimary,
      );

  @override
  AppBarTheme get appBarTheme => AppBarTheme(
        backgroundColor: CustomColorScheme.darkColorScheme.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: CustomColorScheme.darkColorScheme.onPrimary,
        ),
        titleTextStyle: TextStyle(
          color: CustomColorScheme.darkColorScheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );

  @override
  CardThemeData get cardThemeData => CardThemeData(
        color: CustomColorScheme.darkColorScheme.surface,
        elevation: 2,
        shadowColor: CustomColorScheme.darkColorScheme.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  ElevatedButtonThemeData get elevatedButtonThemeData =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColorScheme.darkColorScheme.primary,
          foregroundColor: CustomColorScheme.darkColorScheme.onPrimary,
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
          foregroundColor: CustomColorScheme.darkColorScheme.primary,
          side: BorderSide(color: CustomColorScheme.darkColorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  @override
  TextButtonThemeData get textButtonThemeData => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CustomColorScheme.darkColorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  @override
  TextTheme get textTheme => GoogleFonts.robotoTextTheme(
        const TextTheme(
          titleLarge: TextStyle(color: Colors.white, fontSize: 20),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
          labelLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );

  @override
  IconThemeData get iconThemeData => IconThemeData(
        color: CustomColorScheme.darkColorScheme.primary,
      );

  @override
  SwitchThemeData get switchThemeData => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? CustomColorScheme.darkColorScheme.primary
                : CustomColorScheme.darkColorScheme.outline),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? CustomColorScheme.darkColorScheme.primary.withOpacity(0.5)
                : CustomColorScheme.darkColorScheme.outlineVariant),
      );

  @override
  TabBarTheme get tabBarTheme => TabBarTheme(
        labelColor: CustomColorScheme.darkColorScheme.onPrimary, // white
        unselectedLabelColor:
            CustomColorScheme.darkColorScheme.onPrimary.withOpacity(0.7),
        // indicator: UnderlineTabIndicator(
        //   borderSide: BorderSide(
        //     color:
        //         CustomColorScheme.darkColorScheme.onPrimary, // white underline
        //     width: 2,
        //   ),
        // ),
      );
}
