// enum ImageFormat { jpg, png, webp, heic }
enum ExportFormat {
  // original,
  jpeg,
  png,
  webp;

  String get displayName {
    switch (this) {
      // case ImageFormat.original:
      //   return 'Original';
      case ExportFormat.jpeg:
        return 'JPEG';
      case ExportFormat.png:
        return 'PNG';
      case ExportFormat.webp:
        return 'WebP';
    }
  }
}
