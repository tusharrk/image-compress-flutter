import 'package:flutter/material.dart';

class ThemeService {
  final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier(ThemeMode.dark);

  ThemeMode get themeMode => themeModeNotifier.value;

  void updateTheme(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }
}
