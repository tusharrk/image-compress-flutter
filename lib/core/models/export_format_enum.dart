// enum ImageFormat { jpg, png, webp, heic }
import 'dart:io';

enum ExportFormat {
  original,
  jpeg,
  png,
  webp,
  heic;

  String get displayName {
    switch (this) {
      case ExportFormat.original:
        return 'Original';
      case ExportFormat.jpeg:
        return 'JPEG';
      case ExportFormat.png:
        return 'PNG';
      case ExportFormat.webp:
        return 'WebP';
      case ExportFormat.heic:
        return 'HEIC';
    }
  }

  static List<ExportFormat> get availableFormats {
    if (Platform.isIOS) {
      return ExportFormat.values;
    } else {
      return ExportFormat.values
          .where((format) => format != ExportFormat.heic)
          .toList();
    }
  }
}

enum SimpleImageQuality {
  small,
  medium,
  large;

  String get displayName {
    switch (this) {
      case SimpleImageQuality.small:
        return 'Small';
      case SimpleImageQuality.medium:
        return 'Medium';
      case SimpleImageQuality.large:
        return 'Large';
    }
  }
}
