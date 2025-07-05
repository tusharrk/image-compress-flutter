import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/common_imports/common_imports.dart';
import 'package:flutter_boilerplate/core/constants/app_strings.dart';
import 'package:flutter_boilerplate/core/constants/enums/enum_helper.dart';
import 'package:flutter_boilerplate/services/theme_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsViewModel extends CommonBaseViewmodel {
  // services
  final themeService = locator<ThemeService>();

  // Compression Settings
  double _compressionQuality = 0.8;
  ImageFormat _defaultImageFormat = ImageFormat.original;
  bool _removeMetadata = true;

  // Appearance Settings
  ThemeMode _themeMode = ThemeMode.system;
  String _selectedLanguage = 'en';

  // Notification Settings
  bool _notificationsEnabled = true;

  // Cache
  bool _isClearingCache = false;
  String _cacheSize = "Calculating...";
  String _appVersion = "1.0.0";

  // Getters
  double get compressionQuality => _compressionQuality;
  ImageFormat get defaultImageFormat => _defaultImageFormat;
  bool get removeMetadata => _removeMetadata;
  ThemeMode get themeMode => _themeMode;
  String get selectedLanguage => _selectedLanguage;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isClearingCache => _isClearingCache;
  String get cacheSize => _cacheSize;
  String get appVersion => _appVersion;

  // Available options
  List<ImageFormat> get imageFormats => ImageFormat.values;
  List<ThemeMode> get themeModes => ThemeMode.values;
  List<String> get availableLanguages => ['en', 'es', 'fr', 'de', 'zh', 'hi'];

  void initialise() {
    _loadSettings();
    _calculateCacheSize();
    _loadAppVersion();
  }

  // Compression Settings Methods
  void updateCompressionQuality(double value) {
    _compressionQuality = value;
    _saveCompressionQuality(value);
    notifyListeners();
  }

  void updateImageFormat(ImageFormat format) {
    _defaultImageFormat = format;
    _saveImageFormat(format);
    notifyListeners();
  }

  void toggleRemoveMetadata(bool value) {
    _removeMetadata = value;
    _saveRemoveMetadata(value);
    notifyListeners();
  }

  // Appearance Methods
  void updateThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemeMode(mode);
    themeService.updateTheme(_themeMode);
    notifyListeners();
  }

  void updateLanguage(String language) {
    _selectedLanguage = language;
    _saveLanguage(language);
    notifyListeners();
  }

  String getLanguageDisplayName(String languageCode) {
    const languageNames = {
      'en': 'English',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'zh': '中文',
      'hi': 'हिन्दी',
    };
    return languageNames[languageCode] ?? languageCode;
  }

  // Notification Methods
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    _saveNotificationsEnabled(value);
    notifyListeners();
  }

  // Cache Methods
  Future<void> clearCache() async {
    _isClearingCache = true;
    notifyListeners();

    try {
      // Implement cache clearing logic here
      await Future.delayed(const Duration(seconds: 2)); // Simulate clearing
      _cacheSize = "0 MB";

      // Show success message
      _showSnackBar("Cache cleared successfully");
    } catch (e) {
      _showSnackBar("Failed to clear cache: $e");
    } finally {
      _isClearingCache = false;
      notifyListeners();
    }
  }

  // External Actions
  void openPrivacyPolicy() {
    _launchUrl("https://yourapp.com/privacy");
  }

  void openTermsAndConditions() {
    _launchUrl("https://yourapp.com/terms");
  }

  void rateApp() {
    // Implement app store rating logic
    _launchUrl(
        "https://play.google.com/store/apps/details?id=your.package.name");
  }

  void shareApp() {
    if (Platform.isIOS) {
      SharePlus.instance.share(ShareParams(
          text:
              'Check out this amazing Image Compressor app: ${AppStrings.iosAppStoreUrl}'));
    } else {
      SharePlus.instance.share(ShareParams(
          text:
              'Check out this amazing Image Compressor app: ${AppStrings.androidPlaystoreUrl}'));
    }
  }

  void showAboutDeveloper() {
    // Show about developer dialog or navigate to developer page
    navigationService.navigateToHomeView();
  }

  // Private Methods
  Future<void> _loadSettings() async {
    // Load settings from SharedPreferences or secure storage
    try {
      _compressionQuality =
          storageService.read<double>("compression_quality") ?? 0.8;

      // _defaultImageFormat =
      //     storageService.read<ImageFormat>("default_image_format") ??
      //         ImageFormat.original;

      _defaultImageFormat = EnumHelper.fromString<ImageFormat>(
              storageService.read<String>("default_image_format"),
              ImageFormat.values) ??
          ImageFormat.original;

      _themeMode = EnumHelper.fromString<ThemeMode>(
              storageService.read<String>("theme_mode"), ThemeMode.values) ??
          ThemeMode.system;

      _removeMetadata = storageService.read<bool>("remove_metadata") ?? true;
      // _themeMode =
      //     storageService.read<ThemeMode>("theme_mode") ?? ThemeMode.system;
      _selectedLanguage = storageService.read<String>("language") ?? 'en';
      _notificationsEnabled =
          storageService.read<bool>("notifications_enabled") ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading settings: $e");
    }
  }

  Future<void> _saveCompressionQuality(double value) async {
    await storageService.write("compression_quality", value);
  }

  Future<void> _saveImageFormat(ImageFormat format) async {
    await storageService.write(
        "default_image_format", EnumHelper.enumToString(format));
  }

  Future<void> _saveRemoveMetadata(bool value) async {
    await storageService.write("remove_metadata", value);
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    await storageService.write("theme_mode", EnumHelper.enumToString(mode));

    //print("Theme mode saved: ${storageService.read<ThemeMode>("theme_mode")}");
  }

  Future<void> _saveLanguage(String language) async {
    await storageService.write("language", language);
  }

  Future<void> _saveNotificationsEnabled(bool value) async {
    await storageService.write("notifications_enabled", value);
  }

  Future<void> _calculateCacheSize() async {
    // try {
    //   final size = await _cacheService.getCacheSize();
    //   _cacheSize = _formatBytes(size);
    //   notifyListeners();
    // } catch (e) {
    //   _cacheSize = "Unknown";
    //   notifyListeners();
    // }
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
      notifyListeners();
    } catch (e) {
      _appVersion = "Unknown";
      notifyListeners();
    }
  }

  // String _formatBytes(int bytes) {
  //   if (bytes < 1024) return "$bytes B";
  //   if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
  //   return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  // }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Handle error - could show a snackbar or dialog
    }
  }

  void _showSnackBar(String message) {
    snackbarService.showSnackbar(
      message: message,
      duration: const Duration(seconds: 2),
    );
  }
}

// models/image_format.dart
enum ImageFormat {
  original,
  jpeg,
  png,
  webp;

  String get displayName {
    switch (this) {
      case ImageFormat.original:
        return 'Original';
      case ImageFormat.jpeg:
        return 'JPEG';
      case ImageFormat.png:
        return 'PNG';
      case ImageFormat.webp:
        return 'WebP';
    }
  }
}

// Extension for ThemeMode
extension ThemeModeExtension on ThemeMode {
  String get displayName {
    switch (this) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}
