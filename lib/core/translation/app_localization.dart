import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/constants/enums/locales.dart';
import 'package:get/get.dart';

@immutable

/// Product localization manager
final class AppLocalization extends EasyLocalization {
  /// ProductLocalization need to [child] for a wrap locale item
  AppLocalization({
    required super.child,
    super.key,
  }) : super(
          supportedLocales: _supportedItems,
          path: _translationPath,
          fallbackLocale: Locales.en.locale,
          useOnlyLangCode: true,
        );

  static final List<Locale> _supportedItems = [
    Locales.hi.locale,
    Locales.de.locale,
    Locales.en.locale,
  ];

  static const String _translationPath = 'assets/translations';

  /// Change project language by using [Locales]
  static Future<void> updateLanguage(
    BuildContext context,
    Locale value,
  ) async {
    context.setLocale(value);
    Get.updateLocale(value); // change `Get` locale direction
  }
}
