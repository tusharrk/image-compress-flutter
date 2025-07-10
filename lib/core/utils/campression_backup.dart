// import 'dart:async';
// import 'dart:collection';
// import 'dart:typed_data';

// import 'package:flutter_boilerplate/core/models/export_format_enum.dart';
// import 'package:flutter_boilerplate/core/utils/ImageCompressor.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:image/image.dart' as img;
// import 'package:photo_manager/photo_manager.dart';

// class CompressionCalculator {
//   static const int _maxConcurrentOperations = 3;
//   static const int _batchSize = 10;
//   static const int _maxCacheSize = 50;

//   // Simple LRU cache for compression results
//   static final Map<String, int> _sizeCache = {};
//   static final List<String> _cacheKeys = [];

//   static Future<int> getTotalCompressedSize({
//     required List<AssetEntity> imageAssets,
//     required double quality,
//     required double dimension,
//     required ExportFormat format,
//   }) async {
//     if (imageAssets.isEmpty) return 0;

//     final compressionTasks = imageAssets.map((image) async {
//       final originalBytes = await image.originBytes;
//       if (originalBytes == null) return 0;

//       final fileName = image.title ?? "image.${format.name}";
//       final formatEnum = ImageCompressor.getCompressFormat(format, fileName);

//       // If no compression needed, use original size
//       if (quality == 1.0 && dimension == 1.0) return originalBytes.length;

//       final compressedBytes = await FlutterImageCompress.compressWithList(
//         originalBytes,
//         quality: (quality * 100).toInt(),
//         format: formatEnum,
//         minWidth: (image.width * dimension).toInt(),
//         minHeight: (image.height * dimension).toInt(),
//       );

//       return compressedBytes.isNotEmpty
//           ? compressedBytes.length
//           : originalBytes.length;
//     });

//     final sizes = await Future.wait(compressionTasks);
//     return sizes.fold<int>(0, (sum, size) => sum + size);
//   }

//   static Future<int> getTotalCompressedSize1({
//     required List<AssetEntity> imageAssets,
//     required double quality,
//     required double dimension,
//     required ExportFormat format,
//   }) async {
//     if (imageAssets.isEmpty) return 0;

//     // Process in batches to avoid memory issues
//     int totalCompressedSize = 0;

//     for (int i = 0; i < imageAssets.length; i += _batchSize) {
//       final batch = imageAssets.skip(i).take(_batchSize).toList();
//       final batchSize = await _processBatch(
//         batch: batch,
//         quality: quality,
//         dimension: dimension,
//         format: format,
//       );
//       totalCompressedSize += batchSize;

//       // Optional: Yield control to prevent UI blocking
//       await Future.delayed(Duration.zero);
//     }

//     return totalCompressedSize;
//   }

//   static Future<int> _processBatch({
//     required List<AssetEntity> batch,
//     required double quality,
//     required double dimension,
//     required ExportFormat format,
//   }) async {
//     // Process batch with limited concurrency
//     final semaphore = Semaphore(_maxConcurrentOperations);
//     final futures = batch.map((image) async {
//       return await semaphore.acquire(() async {
//         return await _getCompressedImageSize(
//           image: image,
//           quality: quality,
//           dimension: dimension,
//           format: format,
//         );
//       });
//     });

//     final sizes = await Future.wait(futures);
//     return sizes.fold<int>(0, (sum, size) => sum + size);
//   }

//   static Future<int> _getCompressedImageSize({
//     required AssetEntity image,
//     required double quality,
//     required double dimension,
//     required ExportFormat format,
//   }) async {
//     // Create cache key
//     final cacheKey = _createCacheKey(image, quality, dimension, format);

//     // Check cache first
//     if (_sizeCache.containsKey(cacheKey)) {
//       return _sizeCache[cacheKey]!;
//     }

//     try {
//       final originalBytes = await image.originBytes;
//       if (originalBytes == null) return 0;

//       final originalSize = originalBytes.length;

//       // Skip compression for very small images (< 50KB)
//       if (originalSize < 50 * 1024) {
//         _cacheResult(cacheKey, originalSize);
//         return originalSize;
//       }

//       // Early size estimation for large images
//       final estimatedSize = _estimateCompressedSize(
//         originalSize: originalSize,
//         quality: quality,
//         dimension: dimension,
//         format: format,
//       );

//       // If estimation shows minimal benefit, return original size
//       if (estimatedSize >= originalSize * 0.9) {
//         _cacheResult(cacheKey, originalSize);
//         return originalSize;
//       }

//       final compressedBytes = await _compressImageBytes(
//         bytes: originalBytes,
//         fileName: image.title ?? "image.${format.name}",
//         quality: (quality * 100).toInt(),
//         dimensionRatio: dimension,
//         format: format,
//       );

//       final compressedSize = compressedBytes?.length ?? originalSize;
//       final finalSize = compressedSize > 0 ? compressedSize : originalSize;

//       _cacheResult(cacheKey, finalSize);
//       return finalSize;
//     } catch (e) {
//       // Fallback to original file size on error
//       try {
//         final originalBytes = await image.originBytes;
//         return originalBytes?.length ?? 0;
//       } catch (_) {
//         return 0;
//       }
//     }
//   }

//   static Future<Uint8List?> _compressImageBytes({
//     required Uint8List bytes,
//     required String fileName,
//     required int quality,
//     required double dimensionRatio,
//     required ExportFormat format,
//   }) async {
//     try {
//       final formatEnum = ImageCompressor.getCompressFormat(format, fileName);

//       // Skip dimension calculation if ratio is 1.0
//       if (dimensionRatio == 1.0) {
//         return await FlutterImageCompress.compressWithList(
//           bytes,
//           quality: quality,
//           format: formatEnum,
//         );
//       }

//       // Only decode image if we need to resize
//       final decodedImage = img.decodeImage(bytes);
//       if (decodedImage == null) return null;

//       final newWidth = (decodedImage.width * dimensionRatio).toInt();
//       final newHeight = (decodedImage.height * dimensionRatio).toInt();

//       return await FlutterImageCompress.compressWithList(
//         bytes,
//         quality: quality,
//         format: formatEnum,
//         minWidth: newWidth,
//         minHeight: newHeight,
//       );
//     } catch (e) {
//       return null;
//     }
//   }

//   // Estimate compressed size without actual compression
//   static int _estimateCompressedSize({
//     required int originalSize,
//     required double quality,
//     required double dimension,
//     required ExportFormat format,
//   }) {
//     double compressionRatio = quality * 0.7; // Rough estimation
//     double dimensionRatio = dimension * dimension; // Area scaling

//     // Format-specific adjustments
//     switch (format) {
//       case ExportFormat.webp:
//         compressionRatio *= 0.8; // WebP is more efficient
//         break;
//       case ExportFormat.png:
//         compressionRatio *= 1.2; // PNG is less efficient for photos
//         break;
//       default:
//         break;
//     }

//     return (originalSize * compressionRatio * dimensionRatio).toInt();
//   }

//   static String _createCacheKey(
//     AssetEntity image,
//     double quality,
//     double dimension,
//     ExportFormat format,
//   ) {
//     return '${image.id}_${quality}_${dimension}_${format.name}';
//   }

//   static void _cacheResult(String key, int size) {
//     // Simple LRU cache implementation
//     if (_sizeCache.length >= _maxCacheSize) {
//       final oldestKey = _cacheKeys.removeAt(0);
//       _sizeCache.remove(oldestKey);
//     }

//     _sizeCache[key] = size;
//     _cacheKeys.add(key);
//   }

//   static void clearCache() {
//     _sizeCache.clear();
//     _cacheKeys.clear();
//   }
// }

// // Simple semaphore implementation for concurrency control
// class Semaphore {
//   final int maxCount;
//   int _currentCount;
//   final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

//   Semaphore(this.maxCount) : _currentCount = maxCount;

//   Future<T> acquire<T>(Future<T> Function() operation) async {
//     await _acquire();
//     try {
//       return await operation();
//     } finally {
//       _release();
//     }
//   }

//   Future<void> _acquire() async {
//     if (_currentCount > 0) {
//       _currentCount--;
//       return;
//     }

//     final completer = Completer<void>();
//     _waitQueue.add(completer);
//     return completer.future;
//   }

//   void _release() {
//     if (_waitQueue.isNotEmpty) {
//       final completer = _waitQueue.removeFirst();
//       completer.complete();
//     } else {
//       _currentCount++;
//     }
//   }
// }
