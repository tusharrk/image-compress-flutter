// image_compressor.dart
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/models/export_format_enum.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

typedef CompressionProgressCallback = void Function({
  required String currentName,
  required int currentIndex,
  required int total,
});

class ImageCompressor {
  static const MethodChannel _channel = MethodChannel('image_compressor_ios');

  /// Compress and save images (native pipeline).
  static Future<CompressedImagesResult> compressAndSaveImages({
    required List<AssetEntity> imageAssets,
    required double quality, // 0.0 .. 1.0
    required double dimension, // fraction 0..1 to scale original dims
    required ExportFormat format,
    required bool keepExif,
    required bool keepLocationData,
    required CompressionProgressCallback onProgress,
    required String folderName,
  }) async {
    final Directory tempDir = await getTemporaryDirectory();
    final processingDir = Directory(p.join(tempDir.path, 'compressed_images'));
    if (!await processingDir.exists())
      await processingDir.create(recursive: true);

    final total = imageAssets.length;
    final files = <File>[];
    int totalSize = 0;

    for (int i = 0; i < imageAssets.length; i++) {
      final asset = imageAssets[i];

      // ALWAYS use originFile (original file bytes, correct format)
      final file = await asset.originFile ?? await asset.file;
      if (file == null) {
        // skip if we can't fetch anything
        continue;
      }

      final sourceBytes = await file.readAsBytes();
      final fileName = asset.title?.isNotEmpty == true
          ? asset.title!
          : p.basename(file.path);
      final newWidth = (asset.width * dimension).toInt();
      final newHeight = (asset.height * dimension).toInt();
      print("compressAndSaveImages== Processing File Path: ${file.path}");
      print(
          "compressAndSaveImages== File Extension: ${p.extension(file.path)}");
      print(
          "filename before compress:- ${asset.title ?? p.basename(file.path)}");
      print("height-$newHeight");
      print("width-$newWidth");
      print("keepExif-$keepExif");
      print("keepLocationData-$keepLocationData");

      // call native compressor
      final Uint8List? compressed = await compressNative(
        originalImage: sourceBytes,
        quality: quality,
        width: newWidth,
        height: newHeight,
        format: format,
        keepExif: keepExif,
        keepLocation: keepLocationData,
        sourceFileName: fileName,
      );

      final bytesToSave = compressed ?? sourceBytes;
      final ext = _getExtension(format, fileName);
      final outFile =
          File(p.join(processingDir.path, 'compressed_$fileName.$ext'));
      await outFile.writeAsBytes(bytesToSave);

      // try save to gallery
      try {
        await Gal.putImage(outFile.path, album: folderName);
        files.add(outFile);
      } catch (_) {
        // fallback to app directory
        final saveDir = await _getSaveDirectory(folderName);
        final fallback =
            File(p.join(saveDir.path, 'compressed_$fileName.$ext'));
        await fallback.writeAsBytes(bytesToSave);
        files.add(fallback);
      }

      totalSize += bytesToSave.length;
      print("size after compress:- ${bytesToSave.length}");
      onProgress(currentName: fileName, currentIndex: i + 1, total: total);
    }

    return CompressedImagesResult(files: files, totalSize: totalSize);
  }

  /// Calculates compressed size using identical native pipeline. Returns size in bytes.
  static Future<int> calculateCompressedSize({
    required Uint8List originalImage,
    required double quality,
    required int width,
    required int height,
    required ExportFormat format,
    required String? sourceFileName,
    required bool keepExif,
    required bool keepLocation,
  }) async {
    try {
      final res =
          await _channel.invokeMethod<int>('calculateSize', <String, dynamic>{
        'originalImage': originalImage,
        'quality': quality,
        'width': width,
        'height': height,
        'format': format.name,
        'sourceFileName': sourceFileName ?? '',
        'keepExif': keepExif,
        'keepLocation': keepLocation,
      });
      return res ?? 0;
    } catch (e) {
      print('calculateCompressedSize error: $e');
      return 0;
    }
  }

  static Future<Uint8List?> compressNative({
    required Uint8List originalImage,
    required double quality,
    required int width,
    required int height,
    required ExportFormat format,
    required bool keepExif,
    required bool keepLocation,
    required String sourceFileName,
  }) async {
    try {
      final res = await _channel
          .invokeMethod<dynamic>('compressImage', <String, dynamic>{
        'originalImage': originalImage,
        'quality': quality,
        'width': width,
        'height': height,
        'format': format.name,
        'keepExif': keepExif,
        'keepLocation': keepLocation,
        'sourceFileName': sourceFileName,
      });

      if (res == null) return null;
      if (res is Uint8List) return res;
      if (res is List<int>) return Uint8List.fromList(res);
      return null;
    } catch (e) {
      print('compressNative error: $e');
      return null;
    }
  }

  static String _getExtension(ExportFormat format, String? filePath) {
    if (format == ExportFormat.original && filePath != null) {
      final ext = p.extension(filePath).replaceFirst('.', '').toLowerCase();
      switch (ext) {
        case 'jpg':
        case 'jpeg':
          return 'jpg';
        case 'png':
          return 'png';
        case 'webp':
          return 'webp';
        case 'heic':
          return 'heic';
      }
      return 'jpg';
    }

    switch (format) {
      case ExportFormat.jpeg:
        return 'jpg';
      case ExportFormat.png:
        return 'png';
      case ExportFormat.webp:
        return 'webp';
      case ExportFormat.heic:
        return 'heic';
      case ExportFormat.original:
      default:
        return 'jpg';
    }
  }

  static Future<Directory> _getSaveDirectory(String folderName) async {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Pictures/$folderName');
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    } else {
      final base = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(base.path, folderName));
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    }
  }
}

class CompressedImagesResult {
  final List<File> files;
  final int totalSize;
  CompressedImagesResult({required this.files, required this.totalSize});
}
