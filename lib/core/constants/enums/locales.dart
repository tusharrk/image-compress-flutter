import 'package:flutter/material.dart';

/// Project locale enum for operation and configuration
enum Locales {
  /// Deutsch locale
  de(Locale('de', 'DE')),

  ///hindi locale
  hi(Locale('hi', 'IN')),

  /// English locale
  en(Locale('en', 'US'));

  /// Locale value
  final Locale locale;

  const Locales(this.locale);
}
