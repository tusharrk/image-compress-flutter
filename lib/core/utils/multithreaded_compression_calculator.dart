import 'package:photo_manager/photo_manager.dart';

class CompressionEstimator {
  /// Estimates total compressed size (in bytes) for a list of images.
  static Future<int> estimateTotalCompressedSize({
    required List<AssetEntity> imageAssets,
    required double quality, // 0.0 - 1.0
    required double dimension, // 0.0 - 1.0
  }) async {
    if (imageAssets.isEmpty) return 0;

    int totalEstimatedSize = 0;

    for (final image in imageAssets) {
      final originBytes = await image.originBytes;
      if (originBytes == null) continue;

      final originalSize = originBytes.length;

      final dimensionFactor =
          dimension * dimension; // scaling both width and height

      final compressionFactor = _getFormatCompressionMultiplier(image);

      // Non-linear quality scaling (JPEG/WebP/HEIC compress better at lower qualities)
      final qualityFactor = (1 - (1 - quality) * 0.5);

      final estimatedSize =
          (originalSize * qualityFactor * dimensionFactor * compressionFactor)
              .toInt();
      totalEstimatedSize += estimatedSize;
    }

    return totalEstimatedSize;
  }

  /// Returns an estimated compression efficiency factor based on file format.
  static double _getFormatCompressionMultiplier(AssetEntity image) {
    final extension = (image.title ?? "").split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 0.5; // real-world tested for your data
      case 'png':
        return 1.2; // PNG is lossless and compresses poorly
      case 'webp':
        return 0.5; // better compression
      case 'heic':
        return 0.45; // very efficient
      default:
        return 0.6; // fallback
    }
  }
}
