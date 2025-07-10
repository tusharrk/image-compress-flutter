// enum ImageFormat { jpg, png, webp, heic }
enum ExportFormat {
  original,
  jpeg,
  png,
  webp;

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
