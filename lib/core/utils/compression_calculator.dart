import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';

// enum ImageFormat { jpg, png, webp, heic }
enum ExportFormat { jpg, png, webp, heic }

class CompressionCalculator {
  static Future<int> getTotalCompressedSize({
    required List<AssetEntity> imageAssets,
    required double quality,
    required double dimension,
    required ExportFormat format,
  }) async {
    int totalCompressedSize = 0;

    for (final image in imageAssets) {
      final originalBytes = await image.originBytes;
      if (originalBytes == null) continue;

      final compressedBytes = await _compressImageBytes(
        bytes: originalBytes,
        quality: (quality * 100).toInt(),
        dimensionRatio: dimension,
        format: format,
      );

      final compressedSize = compressedBytes?.length ?? 0;
      final originalSize = originalBytes.length;

      // Use whichever is smaller
      totalCompressedSize += compressedSize > 0 && compressedSize < originalSize
          ? compressedSize
          : originalSize;
    }

    return totalCompressedSize;
  }

  static Future<Uint8List?> _compressImageBytes({
    required Uint8List bytes,
    required int quality,
    required double dimensionRatio,
    required ExportFormat format,
  }) async {
    final formatEnum = _getCompressFormat(format);

    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) return null;

    final newWidth = (decodedImage.width * dimensionRatio).toInt();
    final newHeight = (decodedImage.height * dimensionRatio).toInt();

    final compressedBytes = await FlutterImageCompress.compressWithList(
      bytes,
      quality: quality,
      format: formatEnum,
      minWidth: newWidth,
      minHeight: newHeight,
    );

    return compressedBytes;
  }

  static CompressFormat _getCompressFormat(ExportFormat format) {
    switch (format) {
      case ExportFormat.jpg:
        return CompressFormat.jpeg;
      case ExportFormat.png:
        return CompressFormat.png;
      case ExportFormat.webp:
        return CompressFormat.webp;
      case ExportFormat.heic:
        return CompressFormat.heic;
    }
  }
}
