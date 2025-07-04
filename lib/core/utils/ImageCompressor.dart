import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_boilerplate/core/utils/compression_calculator.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

typedef CompressionProgressCallback = void Function({
  required String currentName,
  required int currentIndex,
  required int total,
});

class ImageCompressor {
  // static Future<List<File>> compressAndSaveImages({
  //   required List<AssetEntity> imageAssets,
  //   required double quality,
  //   required double dimension,
  //   required ExportFormat format,
  //   required CompressionProgressCallback onProgress,
  //   required String folderName,
  // }) async {
  //   final List<File> compressedFiles = [];
  //   final total = imageAssets.length;

  //   final Directory saveDir = await _getSaveDirectory(folderName);

  //   for (int i = 0; i < imageAssets.length; i++) {
  //     final image = imageAssets[i];
  //     final name = "compressed_${image.title ?? "image_$i"}";

  //     final originalBytes = await image.originBytes;
  //     if (originalBytes == null) continue;

  //     final compressedBytes = await _compressImageBytes(
  //       bytes: originalBytes,
  //       quality: (quality * 100).toInt(),
  //       dimensionRatio: dimension,
  //       format: format,
  //     );
  //     final finalBytes = compressedBytes ?? originalBytes;

  //     final String fileExt = _getExtension(format);
  //     final File file = File(p.join(saveDir.path, "$name.$fileExt"));

  //     await file.writeAsBytes(finalBytes);
  //     compressedFiles.add(file);
  //     // Progress callback
  //     onProgress(
  //       currentName: name,
  //       currentIndex: i + 1,
  //       total: total,
  //     );
  //   }

  //   return compressedFiles;
  // }

  static Future<List<File>> compressAndSaveImages({
    required List<AssetEntity> imageAssets,
    required double quality,
    required double dimension,
    required ExportFormat format,
    required CompressionProgressCallback onProgress,
    required String folderName,
  }) async {
    final List<File> compressedFiles = [];
    final total = imageAssets.length;

    // Create temporary directory for processing
    final Directory tempDir = await getTemporaryDirectory();
    final Directory processingDir =
        Directory(p.join(tempDir.path, 'compressed_images'));
    if (!await processingDir.exists()) {
      await processingDir.create(recursive: true);
    }

    for (int i = 0; i < imageAssets.length; i++) {
      final image = imageAssets[i];
      final name = "compressed_${image.title ?? "image_$i"}";

      final originalBytes = await image.originBytes;
      if (originalBytes == null) continue;

      final compressedBytes = await _compressImageBytes(
        bytes: originalBytes,
        quality: (quality * 100).toInt(),
        dimensionRatio: dimension,
        format: format,
      );
      final finalBytes = compressedBytes ?? originalBytes;

      final String fileExt = _getExtension(format);

      // Save to temporary location first
      final File tempFile = File(p.join(processingDir.path, "$name.$fileExt"));
      await tempFile.writeAsBytes(finalBytes);

      try {
        // Save to gallery with album name
        await Gal.putImage(
          tempFile.path,
          album: folderName, // This creates/uses the album
        );

        // Keep reference to temp file
        compressedFiles.add(tempFile);
      } catch (e) {
        print('Error saving to gallery: $e');
        // Fallback: save to app directory
        final Directory saveDir = await _getSaveDirectory(folderName);
        final File fallbackFile = File(p.join(saveDir.path, "$name.$fileExt"));
        await fallbackFile.writeAsBytes(finalBytes);
        compressedFiles.add(fallbackFile);
      }

      // Progress callback
      onProgress(
        currentName: name,
        currentIndex: i + 1,
        total: total,
      );
    }

    return compressedFiles;
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

  static String _getExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.jpg:
        return "jpg";
      case ExportFormat.png:
        return "png";
      case ExportFormat.webp:
        return "webp";
      case ExportFormat.heic:
        return "heic";
    }
  }

  static Future<Directory> _getSaveDirectory(String folderName) async {
    Directory baseDir;

    if (Platform.isAndroid) {
      // Android: use public Pictures folder
      baseDir = Directory('/storage/emulated/0/Pictures/$folderName');
    } else {
      // iOS: use app documents directory
      baseDir = await getApplicationDocumentsDirectory();
      baseDir = Directory(p.join(baseDir.path, folderName));
    }

    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    return baseDir;
  }
}
