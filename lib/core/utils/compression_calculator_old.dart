import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photo_manager/photo_manager.dart';

enum ImageFormat { jpg, png, webp, heic }

class CompressionCalculator {
  /// Estimates final compressed size for single or multiple AssetEntity
  /// Returns total estimated size in bytes
  static Future<int> estimateFinalSize({
    required List<AssetEntity> imageAssets,
    required double quality, // 0.0 to 1.0
    required double dimension, // 0.0 to 1.0
    required ImageFormat format,
  }) async {
    const Map<ImageFormat, double> compressionRatios = {
      ImageFormat.jpg: 0.35, // More realistic: 35% of original size
      ImageFormat.png: 0.85, // PNG compresses less: 85% of original size
      ImageFormat.webp: 0.25, // WebP better than JPG: 25% of original size
      ImageFormat.heic: 0.20, // HEIC best compression: 20% of original size
    };

    int totalEstimatedSize = 0;

    for (AssetEntity asset in imageAssets) {
      try {
        final file = await asset.file;
        if (file == null) continue;

        final originalSize = await file.length();
        final dimensionFactor = dimension * dimension;
        final qualityFactor = format == ImageFormat.png
            ? 1.0
            : 0.6 + (quality * 0.8); // More realistic quality impact

        final estimatedSize = (originalSize *
                dimensionFactor *
                qualityFactor *
                (compressionRatios[format] ?? 0.1))
            .round();

        totalEstimatedSize += estimatedSize;
      } catch (e) {
        // Skip assets that can't be processed
        continue;
      }
    }

    return totalEstimatedSize;
  }

  static Future<int> getActualCompressedSize({
    required List<AssetEntity> imageAssets,
    required double quality, // 0.0 to 1.0
    required double dimension, // 0.0 to 1.0
    required ImageFormat format,
  }) async {
    int totalSize = 0;

    for (AssetEntity asset in imageAssets) {
      try {
        final file = await asset.file;
        if (file == null) continue;

        // Calculate new dimensions
        final newWidth = (asset.width * dimension).round();
        final newHeight = (asset.height * dimension).round();

        // Convert quality to 0-100 range
        final qualityInt = (quality * 100).round().clamp(1, 100);

        // Compress using actual plugin
        final Uint8List? compressedBytes =
            await FlutterImageCompress.compressWithFile(
          file.absolute.path,
          minWidth: newWidth,
          minHeight: newHeight,
          quality: qualityInt,
          format: _getCompressFormat(format),
        );

        if (compressedBytes != null) {
          totalSize += compressedBytes.length;
        }
      } catch (e) {
        continue;
      }
    }

    return totalSize;
  }

  static CompressFormat _getCompressFormat(ImageFormat format) {
    switch (format) {
      case ImageFormat.jpg:
        return CompressFormat.jpeg;
      case ImageFormat.png:
        return CompressFormat.png;
      case ImageFormat.webp:
        return CompressFormat.webp;
      case ImageFormat.heic:
        return CompressFormat.heic;
    }
  }
}
