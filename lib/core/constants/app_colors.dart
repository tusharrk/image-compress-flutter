import 'package:flutter/material.dart';

const Color kcPrimaryColor = Color(0xFF9600FF);
const Color kcPrimaryColorDark = Color(0xFF300151);
const Color kcDarkGreyColor = Color(0xFF1A1B1E);
const Color kcMediumGrey = Color(0xFF474A54);
const Color kcLightGrey = Color.fromARGB(255, 187, 187, 187);
const Color kcVeryLightGrey = Color(0xFFE3E3E3);
const Color kcBackgroundColor = kcDarkGreyColor;

class AppColors {
  AppColors._(); // Prevent instantiation

  // Core neutrals
  static const black = Color(0xFF1C1C1C);
  static const darkGray = Color(0xFF2F2F2F);
  static const mediumGray = Color(0xFF636363);
  static const lightGray = Color(0xFFD9D9D9);
  static const offWhite = Color(0xFFF6F6F6);
  static const white = Color(0xFFFFFFFF);

  // Primary (Rich modern blue)
  static const primary = Color(0xFF4E54F1); // Main accent

  // Complementary shades
  static const primaryDark = Color(0xFF3D43D1); // For hover/dark containers
  static const primaryLight = Color(0xFF7F8AFF); // For light containers

  // Secondary (less saturated variant of primary or subtle purple hint)
  static const secondary = Color(0xFF6D73E0);

  // Tertiary (could be a subtle warm/cool neutral)
  static const tertiary = Color(0xFFB8A08E); // Optional bronze-ish contrast

  // Error states
  static const error = Color(0xFFB22222);
  static const errorLight = Color(0xFFC96464);
  static const errorDark = Color(0xFF8B0000);

  // Shadows
  static const shadow = Color(0xFF000000);
  static const scrim = Color(0xFF000000);
}

//colors to consider
//#1b63f6 blue
//#154FC4 dark version of above blue

//#1E1E1E greyish color

//#C4F35F yellow green to test

//#2D3A6E purple blue

//#4E54F1 new blue modern fresh
