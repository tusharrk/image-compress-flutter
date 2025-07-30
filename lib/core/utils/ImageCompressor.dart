import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/models/export_format_enum.dart';
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

  static Future<CompressedImagesResult> compressAndSaveImages({
    required List<AssetEntity> imageAssets,
    required double quality,
    required double dimension,
    required ExportFormat format,
    required bool keepExif,
    required bool keepLocationData,
    required CompressionProgressCallback onProgress,
    required String folderName,
  }) async {
    final List<File> compressedFiles = [];
    final total = imageAssets.length;
    int totalSize = 0;

    // Create temporary directory for processing
    final Directory tempDir = await getTemporaryDirectory();
    final Directory processingDir =
        Directory(p.join(tempDir.path, 'compressed_images'));
    if (!await processingDir.exists()) {
      await processingDir.create(recursive: true);
    }

    for (int i = 0; i < imageAssets.length; i++) {
      final image = imageAssets[i];

      var originalBytes = await image.originBytes;

      if (Platform.isIOS) {
        // Use file instead of originBytes for better iOS compatibility
        final file = await image.file;
        if (file == null) {
          print('Could not get file for image ${i + 1}');
          continue;
        }
        originalBytes = await file.readAsBytes();
      }
      if (originalBytes == null) continue;

      var fileName = "";
      // ignore: await_only_futures
      if (image.title?.isEmpty != false) {
        fileName = await image.titleAsync;
      } else {
        fileName = image.title ?? "image.${format.name}";
      }
      final name = "compressed_$fileName";

      print('Processing file: $fileName');

      final compressedBytes = await _compressImageBytes(
          bytes: originalBytes,
          fileName: fileName,
          quality: (quality * 100).toInt(),
          dimensionRatio: dimension,
          format: format,
          keepExif: keepExif,
          keepLocationData: keepLocationData);
      final finalBytes = compressedBytes ?? originalBytes;

      final String fileExt = _getExtension(format, fileName);

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

      // Update total size
      totalSize += finalBytes.length;

      // Progress callback
      onProgress(
        currentName: name,
        currentIndex: i + 1,
        total: total,
      );
    }

    return CompressedImagesResult(
      files: compressedFiles,
      totalSize: totalSize,
    );
  }

  static Future<Uint8List?> _compressImageBytes({
    required Uint8List bytes,
    required String fileName,
    required int quality,
    required double dimensionRatio,
    required ExportFormat format,
    required bool keepExif,
    required bool keepLocationData,
  }) async {
    final formatEnum = getCompressFormat(format, fileName);
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) return null;

    final newWidth = (decodedImage.width * dimensionRatio).toInt();
    final newHeight = (decodedImage.height * dimensionRatio).toInt();

    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      quality: quality,
      format: formatEnum,
      minWidth: newWidth,
      minHeight: newHeight,
      autoCorrectionAngle: true,
      keepExif: false, // always false, we'll manually add EXIF
    );

    // Only JPEG & HEIC support EXIF
    // final shouldAddExif =
    //     (format == ExportFormat.jpeg || format == ExportFormat.heic) && keepExif;

    final shouldAddExif = (format == ExportFormat.jpeg) && keepExif;

    if (shouldAddExif) {
      final finalBytes = await ExifChannel.addExifToImage(
        originalImage: bytes,
        compressedImage: Uint8List.fromList(compressed),
        keepLocation: keepLocationData,
      );
      return (finalBytes ?? compressed);
    } else {
      return compressed;
    }
  }

  // static CompressFormat getCompressFormat(ExportFormat format) {
  //   switch (format) {
  //     case ExportFormat.original:
  //       return CompressFormat.jpeg;
  //     case ExportFormat.jpeg:
  //       return CompressFormat.jpeg;
  //     case ExportFormat.png:
  //       return CompressFormat.png;
  //     case ExportFormat.webp:
  //       return CompressFormat.webp;
  //     // case ExportFormat.heic:
  //     //   return CompressFormat.heic;
  //   }
  // }

  static String _getExtension(ExportFormat format, String? filePath) {
    if (format == ExportFormat.original && filePath != null) {
      final ext = filePath.split('.').last.toLowerCase();
      switch (ext) {
        case 'jpg':
        case 'jpeg':
          return 'jpg';
        case 'png':
          return 'png';
        case 'webp':
          return 'webp';
        case 'heic':
          if (Platform.isIOS) {
            return 'heic'; // Add HEIC support if needed
          } else {
            return 'jpg'; // Fallback for non-iOS
          }
        // Add more if needed
      }
      // If extension is unknown or unsupported
      return 'jpg';
    }

    switch (format) {
      case ExportFormat.jpeg:
        return 'jpg';
      case ExportFormat.png:
        return 'png';
      case ExportFormat.webp:
        return 'webp';
      case ExportFormat.original:
        return 'jpg'; // fallback if filePath is null
      case ExportFormat.heic:
        return 'heic';
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

  static CompressFormat getCompressFormat(
      ExportFormat format, String? filePath) {
    if (format == ExportFormat.original) {
      if (filePath != null) {
        final ext = filePath.split('.').last.toLowerCase();
        switch (ext) {
          case 'jpg':
          case 'jpeg':
            return CompressFormat.jpeg;
          case 'png':
            return CompressFormat.png;
          case 'webp':
            return CompressFormat.webp;
          case 'heic':
            if (Platform.isIOS) {
              return CompressFormat.heic; // Add HEIC support if needed
            } else {
              return CompressFormat.jpeg; // Fallback for non-iOS
            }
          // Add more if flutter_image_compress supports them
        }
      }
      // Default fallback if extension is unknown or unsupported
      return CompressFormat.jpeg;
    }

    // Other specific formats
    switch (format) {
      case ExportFormat.jpeg:
        return CompressFormat.jpeg;
      case ExportFormat.png:
        return CompressFormat.png;
      case ExportFormat.webp:
        return CompressFormat.webp;
      case ExportFormat.heic:
        {
          if (Platform.isIOS) {
            return CompressFormat.heic; // Add HEIC support if needed
          } else {
            return CompressFormat.jpeg; // Fallback for non-iOS
          }
        }
      default:
        return CompressFormat.jpeg; // Fallback default
    }
  }
}

class CompressedImagesResult {
  final List<File> files;
  final int totalSize;

  CompressedImagesResult({
    required this.files,
    required this.totalSize,
  });
}

class ExifChannel {
  static const _channel = MethodChannel('image_exif_channel');

  static Future<Uint8List?> addExifToImage({
    required Uint8List originalImage,
    required Uint8List compressedImage,
    required bool keepLocation,
  }) async {
    return await _channel.invokeMethod<Uint8List>(
      'addExifToImage',
      {
        'originalImage': originalImage,
        'compressedImage': compressedImage,
        'keepLocation': keepLocation,
      },
    );
  }
}
