import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_boilerplate/core/models/export_format_enum.dart';
import 'package:flutter_boilerplate/core/utils/ImageCompressor.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';

class CancellationToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}

class CompressionCalculator {
  static CancellationToken? _currentToken;

  static Future<int> getTotalCompressedSize({
    required List<AssetEntity> imageAssets,
    required double quality,
    required double dimension,
    required ExportFormat format,
  }) async {
    // Cancel any existing operation
    _currentToken?.cancel();

    // Create new cancellation token
    final token = CancellationToken();
    _currentToken = token;

    try {
      int totalCompressedSize = 0;

      for (int i = 0; i < imageAssets.length; i++) {
        // Check if operation was cancelled
        if (token.isCancelled) {
          return 0; // Operation was cancelled
        }

        final image = imageAssets[i];
        final originalBytes = await image.originBytes;
        if (originalBytes == null) continue;

        // Check cancellation again before processing
        if (token.isCancelled) {
          return 0;
        }

        final compressedBytes = await _compressImageBytes(
          bytes: originalBytes,
          fileName: image.title ?? "image.${format.name}",
          quality: (quality * 100).toInt(),
          dimensionRatio: dimension,
          format: format,
          token: token,
        );

        // Check if compression was cancelled
        if (compressedBytes == null && token.isCancelled) {
          return 0;
        }

        final compressedSize = compressedBytes?.length ?? 0;
        final originalSize = originalBytes.length;

        totalCompressedSize +=
            compressedSize > 0 ? compressedSize : originalSize;
      }

      // Final check before returning result
      if (token.isCancelled) {
        return 0;
      }

      return totalCompressedSize;
    } finally {
      // Clear the current token if it's still the active one
      if (_currentToken == token) {
        _currentToken = null;
      }
    }
  }

  static Future<Uint8List?> _compressImageBytes({
    required Uint8List bytes,
    required String fileName,
    required int quality,
    required double dimensionRatio,
    required ExportFormat format,
    required CancellationToken token,
  }) async {
    // Check cancellation before starting compression
    if (token.isCancelled) {
      return null;
    }

    final formatEnum = ImageCompressor.getCompressFormat(format, fileName);

    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) return null;

    // Check cancellation before expensive operations
    if (token.isCancelled) {
      return null;
    }

    final newWidth = (decodedImage.width * dimensionRatio).toInt();
    final newHeight = (decodedImage.height * dimensionRatio).toInt();

    // Check cancellation one more time before compression
    if (token.isCancelled) {
      return null;
    }

    final compressedBytes = await FlutterImageCompress.compressWithList(
      bytes,
      quality: quality,
      format: formatEnum,
      minWidth: newWidth,
      minHeight: newHeight,
    );

    // Final check after compression
    if (token.isCancelled) {
      return null;
    }

    return compressedBytes;
  }

  // Method to manually cancel current operation
  static void cancelCurrentOperation() {
    _currentToken?.cancel();
  }

  // Method to check if there's an active operation
  static bool get hasActiveOperation =>
      _currentToken != null && !_currentToken!.isCancelled;
}
