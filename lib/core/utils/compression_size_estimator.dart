import 'dart:math' as math;

import 'package:flutter_boilerplate/core/models/export_format_enum.dart';
import 'package:photo_manager/photo_manager.dart';

class CompressionSizeEstimator {
  // Compression ratio constants based on real-world data
  // These represent final size / original size ratios
  static const Map<ExportFormat, double> _baseCompressionRatios = {
    ExportFormat.jpeg: 0.25, // JPEG typically compresses to 20-30% of original
    ExportFormat.webp: 0.20, // WebP is ~20% more efficient than JPEG
    ExportFormat.png: 0.90, // PNG has poor compression for photos
    ExportFormat.original: 0.25, // Assume JPEG for original
  };

  // Quality impact on final size (these are multipliers, not absolute ratios)
  static const Map<int, double> _qualityMultipliers = {
    100: 1.4, // High quality = larger file
    90: 1.2,
    80: 1.0, // Base reference
    70: 0.8,
    60: 0.6,
    50: 0.45,
    40: 0.35,
    30: 0.25,
    20: 0.18,
    10: 0.12,
  };

  /// Estimates total compressed size without actual compression
  /// This is much faster as it only reads file metadata
  static Future<int> getEstimatedTotalSize({
    required List<AssetEntity> imageAssets,
    required double quality,
    required double dimension,
    required ExportFormat format,
  }) async {
    if (imageAssets.isEmpty) return 0;

    int totalEstimatedSize = 0;

    for (final image in imageAssets) {
      final estimatedSize = await _estimateImageSize(
        image: image,
        quality: quality,
        dimension: dimension,
        format: format,
      );
      totalEstimatedSize += estimatedSize;
    }

    return totalEstimatedSize;
  }

  /// Estimates compressed size for a single image
  static Future<int> _estimateImageSize({
    required AssetEntity image,
    required double quality,
    required double dimension,
    required ExportFormat format,
  }) async {
    try {
      // Get original size without loading the full image
      final originalSize = await _getOriginalSize(image);
      if (originalSize == 0) return 0;

      // Calculate estimated size
      return _calculateEstimatedSize(
        originalSize: originalSize,
        quality: quality,
        dimension: dimension,
        format: format,
        image: image,
      );
    } catch (e) {
      // Fallback estimation based on image dimensions
      return _fallbackEstimation(image, quality, dimension, format);
    }
  }

  /// Get original file size efficiently
  static Future<int> _getOriginalSize(AssetEntity image) async {
    try {
      // Try to get size from metadata first (fastest)
      final file = await image.file;
      if (file != null) {
        final stat = await file.stat();
        return stat.size;
      }

      // Fallback to loading bytes if file access fails
      final bytes = await image.originBytes;
      return bytes?.length ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Calculate estimated compressed size
  static int _calculateEstimatedSize({
    required int originalSize,
    required double quality,
    required double dimension,
    required ExportFormat format,
    required AssetEntity image,
  }) {
    // Base compression ratio for the format
    double compressionRatio = _baseCompressionRatios[format] ?? 0.15;

    // Apply quality multiplier
    final qualityMultiplier = _getQualityMultiplier(quality);
    compressionRatio *= qualityMultiplier;

    // Apply dimension scaling (area scaling)
    final dimensionMultiplier = dimension * dimension;
    compressionRatio *= dimensionMultiplier;

    // Apply image type adjustments
    compressionRatio *= _getImageTypeMultiplier(image);

    // Apply size-based adjustments
    compressionRatio *= _getSizeMultiplier(originalSize);

    // Calculate final size
    final estimatedSize = (originalSize * compressionRatio).toInt();

    // Apply calibration factor
    final calibratedSize = (estimatedSize * _calibrationFactor).toInt();

    // Ensure minimum size (compressed files have overhead)
    final minSize = _getMinimumSize(format);

    return math.max(calibratedSize, minSize);
  }

  /// Get quality multiplier based on quality setting
  static double _getQualityMultiplier(double quality) {
    final qualityPercent = (quality * 100).toInt();

    // Find the closest quality level
    int closestQuality = 50;
    int minDiff = 100;

    for (final q in _qualityMultipliers.keys) {
      final diff = (q - qualityPercent).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestQuality = q;
      }
    }

    return _qualityMultipliers[closestQuality] ?? 0.25;
  }

  /// Adjust compression ratio based on image type
  static double _getImageTypeMultiplier(AssetEntity image) {
    final title = image.title?.toLowerCase() ?? '';

    // Screenshots and simple graphics compress better
    if (title.contains('screenshot') || title.contains('screen')) {
      return 0.8; // Better compression
    }

    // Photos with lots of detail compress less
    if (title.contains('photo') || title.contains('img')) {
      return 1.1; // Slightly worse compression
    }

    // PNG images being converted to JPEG/WebP
    if (title.endsWith('.png')) {
      return 0.6; // Better compression when converting from PNG
    }

    // Already compressed formats
    if (title.endsWith('.jpg') || title.endsWith('.jpeg')) {
      return 1.0; // Already compressed, similar size expected
    }

    return 1.0; // Default multiplier
  }

  /// Adjust compression ratio based on original file size
  static double _getSizeMultiplier(int originalSize) {
    // Very small images don't compress as well relatively
    if (originalSize < 100 * 1024) {
      // < 100KB
      return 1.3;
    }

    // Medium images compress well
    if (originalSize < 1024 * 1024) {
      // < 1MB
      return 1.0;
    }

    // Large images compress slightly better
    if (originalSize < 5 * 1024 * 1024) {
      // < 5MB
      return 0.95;
    }

    // Very large images compress well
    return 0.9;
  }

  /// Get minimum file size for format (compressed files have overhead)
  static int _getMinimumSize(ExportFormat format) {
    switch (format) {
      case ExportFormat.jpeg:
      case ExportFormat.original:
        return 8192; // 8KB minimum for JPEG
      case ExportFormat.webp:
        return 6144; // 6KB minimum for WebP
      case ExportFormat.png:
        return 4096; // 4KB minimum for PNG
      default:
        return 4096;
    }
  }

  /// Fallback estimation when we can't get original size
  static int _fallbackEstimation(
    AssetEntity image,
    double quality,
    double dimension,
    ExportFormat format,
  ) {
    // Estimate based on image dimensions
    final width = image.width;
    final height = image.height;

    if (width == 0 || height == 0) return 50 * 1024; // 50KB default

    // Rough estimation: 3 bytes per pixel for uncompressed
    final pixelCount = width * height;
    final uncompressedSize = pixelCount * 3;

    // Apply compression estimation
    return _calculateEstimatedSize(
      originalSize: uncompressedSize,
      quality: quality,
      dimension: dimension,
      format: format,
      image: image,
    );
  }

  /// Get detailed estimation breakdown (useful for debugging)
  static Future<Map<String, dynamic>> getEstimationBreakdown({
    required AssetEntity image,
    required double quality,
    required double dimension,
    required ExportFormat format,
  }) async {
    final originalSize = await _getOriginalSize(image);
    final baseRatio = _baseCompressionRatios[format] ?? 0.15;
    final qualityMultiplier = _getQualityMultiplier(quality);
    final dimensionMultiplier = dimension * dimension;
    final imageTypeMultiplier = _getImageTypeMultiplier(image);
    final sizeMultiplier = _getSizeMultiplier(originalSize);

    final finalRatio = baseRatio *
        qualityMultiplier *
        dimensionMultiplier *
        imageTypeMultiplier *
        sizeMultiplier;

    final estimatedSize = (originalSize * finalRatio).toInt();
    final minSize = _getMinimumSize(format);
    final finalSize = math.max(estimatedSize, minSize);

    return {
      'originalSize': originalSize,
      'estimatedSize': finalSize,
      'compressionRatio': finalRatio,
      'savings': originalSize - finalSize,
      'savingsPercent': originalSize > 0
          ? ((originalSize - finalSize) / originalSize * 100).toStringAsFixed(1)
          : '0.0',
      'breakdown': {
        'baseRatio': baseRatio,
        'qualityMultiplier': qualityMultiplier,
        'dimensionMultiplier': dimensionMultiplier,
        'imageTypeMultiplier': imageTypeMultiplier,
        'sizeMultiplier': sizeMultiplier,
      }
    };
  }

  /// Quick estimation for UI display (returns human-readable string)
  static Future<String> getQuickEstimate({
    required List<AssetEntity> imageAssets,
    required double quality,
    required double dimension,
    required ExportFormat format,
  }) async {
    final estimatedBytes = await getEstimatedTotalSize(
      imageAssets: imageAssets,
      quality: quality,
      dimension: dimension,
      format: format,
    );

    return _formatFileSize(estimatedBytes);
  }

  /// Format file size in human-readable format
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Calibrate estimation based on actual compression results
  /// Call this with actual vs estimated results to improve accuracy
  static double _calibrationFactor = 1.0;

  static void calibrateEstimation({
    required int actualCompressedSize,
    required int estimatedSize,
  }) {
    if (estimatedSize > 0) {
      final newFactor = actualCompressedSize / estimatedSize;
      // Apply exponential moving average for stability
      _calibrationFactor = (_calibrationFactor * 0.7) + (newFactor * 0.3);
    }
  }

  /// Get current calibration factor (useful for debugging)
  static double getCalibrationFactor() => _calibrationFactor;

  /// Reset calibration to default
  static void resetCalibration() => _calibrationFactor = 1.0;

  /// Test estimation against actual compression
  /// Use this to validate and improve estimation accuracy
  static Future<Map<String, dynamic>> testEstimation({
    required AssetEntity image,
    required double quality,
    required double dimension,
    required ExportFormat format,
    required int actualCompressedSize,
  }) async {
    final estimatedSize = await _estimateImageSize(
      image: image,
      quality: quality,
      dimension: dimension,
      format: format,
    );

    final error =
        ((estimatedSize - actualCompressedSize) / actualCompressedSize * 100)
            .abs();
    final ratio = actualCompressedSize / estimatedSize;

    return {
      'originalSize': await _getOriginalSize(image),
      'estimatedSize': estimatedSize,
      'actualSize': actualCompressedSize,
      'errorPercent': error.toStringAsFixed(1),
      'ratio': ratio.toStringAsFixed(3),
      'status': error < 20
          ? 'Good'
          : error < 40
              ? 'Fair'
              : 'Poor',
    };
  }
}
