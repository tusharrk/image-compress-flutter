// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter_boilerplate/core/utils/compression_calculator.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:photo_manager/photo_manager.dart';

// class CompressedImageResult {
//   final String assetId;
//   final Uint8List compressedBytes;
//   final int originalSize;
//   final int compressedSize;
//   final double compressionRatio;

//   CompressedImageResult({
//     required this.assetId,
//     required this.compressedBytes,
//     required this.originalSize,
//     required this.compressedSize,
//   }) : compressionRatio =
//             originalSize > 0 ? compressedSize / originalSize : 1.0;

//   double get compressionPercentage => (1 - compressionRatio) * 100;
// }

// class BatchCompressionResult {
//   final List<CompressedImageResult> results;
//   final int totalOriginalSize;
//   final int totalCompressedSize;
//   final int successCount;
//   final int failureCount;

//   BatchCompressionResult({
//     required this.results,
//     required this.totalOriginalSize,
//     required this.totalCompressedSize,
//     required this.successCount,
//     required this.failureCount,
//   });

//   double get overallCompressionRatio =>
//       totalOriginalSize > 0 ? totalCompressedSize / totalOriginalSize : 1.0;

//   double get overallCompressionPercentage =>
//       (1 - overallCompressionRatio) * 100;
// }

// class ImageCompressor {
//   /// Compresses a single image asset
//   static Future<CompressedImageResult?> compressImage({
//     required AssetEntity imageAsset,
//     required double quality,
//     required double dimension,
//     required ExportFormat format,
//   }) async {
//     try {
//       final originalBytes = await imageAsset.originBytes;
//       if (originalBytes == null) return null;

//       final compressedBytes = await _compressImageBytes(
//         bytes: originalBytes,
//         quality: (quality * 100).toInt(),
//         dimensionRatio: dimension,
//         format: format,
//       );

//       if (compressedBytes == null) return null;

//       final originalSize = originalBytes.length;
//       final compressedSize = compressedBytes.length;

//       // Use original if compression didn't reduce size
//       final finalBytes =
//           compressedSize < originalSize ? compressedBytes : originalBytes;
//       final finalSize = finalBytes.length;

//       return CompressedImageResult(
//         assetId: imageAsset.id,
//         compressedBytes: finalBytes,
//         originalSize: originalSize,
//         compressedSize: finalSize,
//       );
//     } catch (e) {
//       print('Error compressing image ${imageAsset.id}: $e');
//       return null;
//     }
//   }

//   /// Compresses multiple images with progress callback
//   static Future<BatchCompressionResult> compressBatch({
//     required List<AssetEntity> imageAssets,
//     required double quality,
//     required double dimension,
//     required ExportFormat format,
//     Function(int current, int total, String? currentAssetId)? onProgress,
//   }) async {
//     final results = <CompressedImageResult>[];
//     int totalOriginalSize = 0;
//     int totalCompressedSize = 0;
//     int successCount = 0;
//     int failureCount = 0;

//     for (int i = 0; i < imageAssets.length; i++) {
//       final asset = imageAssets[i];
//       onProgress?.call(i + 1, imageAssets.length, asset.id);

//       final result = await compressImage(
//         imageAsset: asset,
//         quality: quality,
//         dimension: dimension,
//         format: format,
//       );

//       if (result != null) {
//         results.add(result);
//         totalOriginalSize += result.originalSize;
//         totalCompressedSize += result.compressedSize;
//         successCount++;
//       } else {
//         failureCount++;
//       }
//     }

//     return BatchCompressionResult(
//       results: results,
//       totalOriginalSize: totalOriginalSize,
//       totalCompressedSize: totalCompressedSize,
//       successCount: successCount,
//       failureCount: failureCount,
//     );
//   }

//   /// Compresses image bytes directly
//   static Future<Uint8List?> compressImageBytes({
//     required Uint8List bytes,
//     required double quality,
//     required double dimension,
//     required ExportFormat format,
//   }) async {
//     return await _compressImageBytes(
//       bytes: bytes,
//       quality: (quality * 100).toInt(),
//       dimensionRatio: dimension,
//       format: format,
//     );
//   }

//   /// Compresses and saves images to a specific directory
//   static Future<List<String>> compressAndSave({
//     required List<AssetEntity> imageAssets,
//     required String outputDirectory,
//     required double quality,
//     required double dimension,
//     required ExportFormat format,
//     String? filenamePrefix,
//     Function(int current, int total, String? fileName)? onProgress,
//   }) async {
//     final savedPaths = <String>[];

//     // Ensure directory exists
//     final directory = Directory(outputDirectory);
//     if (!await directory.exists()) {
//       await directory.create(recursive: true);
//     }

//     for (int i = 0; i < imageAssets.length; i++) {
//       final asset = imageAssets[i];
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final filename =
//           '${filenamePrefix ?? 'compressed'}_${timestamp}_${i + 1}.${_getFileExtension(format)}';

//       onProgress?.call(i + 1, imageAssets.length, filename);

//       final result = await compressImage(
//         imageAsset: asset,
//         quality: quality,
//         dimension: dimension,
//         format: format,
//       );

//       if (result != null) {
//         try {
//           final filePath = '$outputDirectory/$filename';
//           final file = File(filePath);
//           await file.writeAsBytes(result.compressedBytes);
//           savedPaths.add(filePath);
//         } catch (e) {
//           print('Error saving file $filename: $e');
//         }
//       }
//     }

//     return savedPaths;
//   }

//   /// Gets app documents directory path
//   static Future<String> getAppDocumentsPath() async {
//     final directory = await getApplicationDocumentsDirectory();
//     return directory.path;
//   }

//   /// Gets external storage directory path (Android)
//   static Future<String?> getExternalStoragePath() async {
//     if (Platform.isAndroid) {
//       final directory = await getExternalStorageDirectory();
//       return directory?.path;
//     }
//     return null;
//   }

//   /// Creates a compressed images folder in documents directory
//   static Future<String> createCompressedImagesFolder() async {
//     final documentsPath = await getAppDocumentsPath();
//     final compressedFolder = '$documentsPath/compressed_images';
//     final directory = Directory(compressedFolder);

//     if (!await directory.exists()) {
//       await directory.create(recursive: true);
//     }

//     return compressedFolder;
//   }

//   /// Requests storage permissions (Android)
//   static Future<bool> requestStoragePermission() async {
//     if (Platform.isAndroid) {
//       final status = await Permission.storage.request();
//       return status.isGranted;
//     }
//     return true; // iOS doesn't need explicit storage permission for app documents
//   }

//   // Private helper methods
//   static Future<Uint8List?> _compressImageBytes({
//     required Uint8List bytes,
//     required int quality,
//     required double dimensionRatio,
//     required ExportFormat format,
//   }) async {
//     try {
//       final formatEnum = _getCompressFormat(format);

//       final decodedImage = img.decodeImage(bytes);
//       if (decodedImage == null) return null;

//       final newWidth = (decodedImage.width * dimensionRatio).toInt();
//       final newHeight = (decodedImage.height * dimensionRatio).toInt();

//       final compressedBytes = await FlutterImageCompress.compressWithList(
//         bytes,
//         quality: quality,
//         format: formatEnum,
//         minWidth: newWidth,
//         minHeight: newHeight,
//       );

//       return compressedBytes;
//     } catch (e) {
//       print('Error in _compressImageBytes: $e');
//       return null;
//     }
//   }

//   static CompressFormat _getCompressFormat(ExportFormat format) {
//     switch (format) {
//       case ExportFormat.jpg:
//         return CompressFormat.jpeg;
//       case ExportFormat.png:
//         return CompressFormat.png;
//       case ExportFormat.webp:
//         return CompressFormat.webp;
//       case ExportFormat.heic:
//         return CompressFormat.heic;
//     }
//   }

//   static String _getFileExtension(ExportFormat format) {
//     switch (format) {
//       case ExportFormat.jpg:
//         return 'jpg';
//       case ExportFormat.png:
//         return 'png';
//       case ExportFormat.webp:
//         return 'webp';
//       case ExportFormat.heic:
//         return 'heic';
//     }
//   }
// }
