import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/app/app.locator.dart';
import 'package:flutter_boilerplate/services/storage_service.dart';

class ThemeService {
  final storageService = locator<StorageService>();
  late final ValueNotifier<ThemeMode> themeModeNotifier;

  ThemeService() {
    final theme =
        storageService.read<ThemeMode>("theme_mode") ?? ThemeMode.system;
    print(
        "ThemeService initialized with theme: ${storageService.read<ThemeMode>("theme_mode")}");
    themeModeNotifier = ValueNotifier<ThemeMode>(theme);
  }

  ThemeMode get themeMode => themeModeNotifier.value;

  void updateTheme(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }
}
