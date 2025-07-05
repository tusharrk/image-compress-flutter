import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/app/app.locator.dart';
import 'package:flutter_boilerplate/core/constants/enums/enum_helper.dart';
import 'package:flutter_boilerplate/services/storage_service.dart';

class ThemeService {
  final storageService = locator<StorageService>();
  late final ValueNotifier<ThemeMode> themeModeNotifier;

  ThemeService() {
    final theme = EnumHelper.fromString<ThemeMode>(
            storageService.read<String>("theme_mode"), ThemeMode.values) ??
        ThemeMode.system;
    print("ThemeService initialized with theme: $theme");
    themeModeNotifier = ValueNotifier<ThemeMode>(theme);
  }

  ThemeMode get themeMode => themeModeNotifier.value;

  void updateTheme(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }
}
