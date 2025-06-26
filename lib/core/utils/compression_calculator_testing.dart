// import 'dart:isolate';
// import 'dart:typed_data';

// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:photo_manager/photo_manager.dart';

// enum ExportFormat { jpg, png, webp, heic }

// // Simple message classes for isolate communication
// class CompressionTask {
//   final Uint8List imageBytes;
//   final int quality;
//   final double dimensionRatio;
//   final ExportFormat format;
//   final int originalWidth;
//   final int originalHeight;

//   CompressionTask({
//     required this.imageBytes,
//     required this.quality,
//     required this.dimensionRatio,
//     required this.format,
//     required this.originalWidth,
//     required this.originalHeight,
//   });
// }

// class CompressionResult {
//   final int compressedSize;
//   final int originalSize;
//   final bool success;

//   CompressionResult({
//     required this.compressedSize,
//     required this.originalSize,
//     required this.success,
//   });
// }

// class CompressionCalculator {
//   static const Map<ExportFormat, CompressFormat> _formatMap = {
//     ExportFormat.jpg: CompressFormat.jpeg,
//     ExportFormat.png: CompressFormat.png,
//     ExportFormat.webp: CompressFormat.webp,
//     ExportFormat.heic: CompressFormat.heic,
//   };

//   /// Main compression method with simple multi-threading
//   static Future<int> getTotalCompressedSize({
//     required List<AssetEntity> imageAssets,
//     required double quality,
//     required double dimension,
//     required ExportFormat format,
//     int? threadCount,
//     Function(int processed, int total)? onProgress,
//   }) async {
//     if (imageAssets.isEmpty) return 0;

//     // Determine optimal thread count
//     final actualThreadCount =
//         threadCount ?? _getOptimalThreadCount(imageAssets.length);

//     // Prepare tasks by loading image data
//     final tasks = <CompressionTask>[];
//     for (int i = 0; i < imageAssets.length; i++) {
//       final asset = imageAssets[i];
//       final bytes = await asset.originBytes;
//       if (bytes != null) {
//         tasks.add(CompressionTask(
//           imageBytes: bytes,
//           quality: (quality * 100).toInt(),
//           dimensionRatio: dimension,
//           format: format,
//           originalWidth: asset.width,
//           originalHeight: asset.height,
//         ));
//       }

//       // Report loading progress
//       onProgress?.call(i + 1, imageAssets.length);
//     }

//     if (tasks.isEmpty) return 0;

//     // Process tasks in parallel using simple isolate spawning
//     final results = await _processInParallel(
//       tasks: tasks,
//       threadCount: actualThreadCount,
//       onProgress: onProgress,
//     );

//     // Calculate total size
//     int totalSize = 0;
//     for (final result in results) {
//       if (result.success) {
//         totalSize += result.compressedSize < result.originalSize
//             ? result.compressedSize
//             : result.originalSize;
//       }
//     }

//     return totalSize;
//   }

//   /// Simple parallel processing using batch isolates
//   static Future<List<CompressionResult>> _processInParallel({
//     required List<CompressionTask> tasks,
//     required int threadCount,
//     Function(int processed, int total)? onProgress,
//   }) async {
//     // Split tasks into batches
//     final batches = <List<CompressionTask>>[];
//     final batchSize = (tasks.length / threadCount).ceil();

//     for (int i = 0; i < tasks.length; i += batchSize) {
//       final batch = tasks.skip(i).take(batchSize).toList();
//       batches.add(batch);
//     }

//     // Process each batch in separate isolate
//     final futures = <Future<List<CompressionResult>>>[];

//     for (int i = 0; i < batches.length; i++) {
//       final batch = batches[i];
//       final future = _processBatchInIsolate(batch, i);
//       futures.add(future);
//     }

//     // Wait for all batches to complete
//     final batchResults = await Future.wait(futures);

//     // Flatten results
//     final allResults = <CompressionResult>[];
//     for (final batchResult in batchResults) {
//       allResults.addAll(batchResult);
//     }

//     return allResults;
//   }

//   /// Process a batch of tasks in a separate isolate
//   static Future<List<CompressionResult>> _processBatchInIsolate(
//     List<CompressionTask> batch,
//     int batchIndex,
//   ) async {
//     final receivePort = ReceivePort();

//     // Spawn isolate with batch data
//     await Isolate.spawn(
//       _isolateBatchProcessor,
//       {
//         'sendPort': receivePort.sendPort,
//         'tasks': batch,
//         'batchIndex': batchIndex,
//       },
//       debugName: 'CompressionBatch-$batchIndex',
//     );

//     // Wait for results
//     final results = await receivePort.first as List<CompressionResult>;
//     receivePort.close();

//     return results;
//   }

//   /// Isolate entry point for batch processing
//   static void _isolateBatchProcessor(Map<String, dynamic> params) async {
//     final sendPort = params['sendPort'] as SendPort;
//     final tasks = params['tasks'] as List<CompressionTask>;
//     final batchIndex = params['batchIndex'] as int;

//     final results = <CompressionResult>[];

//     for (int i = 0; i < tasks.length; i++) {
//       final task = tasks[i];
//       final result = await _processTaskInIsolate(task);
//       results.add(result);
//     }

//     // Send all results back at once
//     sendPort.send(results);
//   }

//   /// Process single compression task in isolate
//   static Future<CompressionResult> _processTaskInIsolate(
//       CompressionTask task) async {
//     try {
//       final formatEnum = _formatMap[task.format]!;
//       final targetWidth = (task.originalWidth * task.dimensionRatio).toInt();
//       final targetHeight = (task.originalHeight * task.dimensionRatio).toInt();

//       // Skip compression if dimensions are too small
//       if (targetWidth < 10 || targetHeight < 10) {
//         return CompressionResult(
//           compressedSize: task.imageBytes.length,
//           originalSize: task.imageBytes.length,
//           success: true,
//         );
//       }

//       final compressedBytes = await FlutterImageCompress.compressWithList(
//         task.imageBytes,
//         quality: task.quality,
//         format: formatEnum,
//         minWidth: targetWidth,
//         minHeight: targetHeight,
//         rotate: 0,
//         keepExif: false,
//       );

//       return CompressionResult(
//         compressedSize: compressedBytes.length ?? task.imageBytes.length,
//         originalSize: task.imageBytes.length,
//         success: compressedBytes != null,
//       );
//     } catch (e) {
//       return CompressionResult(
//         compressedSize: task.imageBytes.length,
//         originalSize: task.imageBytes.length,
//         success: false,
//       );
//     }
//   }

//   /// Determine optimal thread count based on task count and device
//   static int _getOptimalThreadCount(int taskCount) {
//     if (taskCount <= 2) return 1;
//     if (taskCount <= 5) return 2;
//     if (taskCount <= 10) return 3;
//     return 4; // Maximum 4 threads for most devices
//   }

//   /// Alternative method with progress reporting for each thread
//   static Future<int> getTotalCompressedSizeWithProgress({
//     required List<AssetEntity> imageAssets,
//     required double quality,
//     required double dimension,
//     required ExportFormat format,
//     int? threadCount,
//     Function(int processed, int total, String status)? onProgress,
//   }) async {
//     if (imageAssets.isEmpty) return 0;

//     final actualThreadCount =
//         threadCount ?? _getOptimalThreadCount(imageAssets.length);

//     onProgress?.call(0, imageAssets.length, 'Loading images...');

//     // Prepare tasks
//     final tasks = <CompressionTask>[];
//     for (int i = 0; i < imageAssets.length; i++) {
//       final asset = imageAssets[i];
//       final bytes = await asset.originBytes;
//       if (bytes != null) {
//         tasks.add(CompressionTask(
//           imageBytes: bytes,
//           quality: (quality * 100).toInt(),
//           dimensionRatio: dimension,
//           format: format,
//           originalWidth: asset.width,
//           originalHeight: asset.height,
//         ));
//       }

//       onProgress?.call(i + 1, imageAssets.length, 'Loading images...');
//     }

//     if (tasks.isEmpty) return 0;

//     onProgress?.call(0, tasks.length, 'Compressing images...');

//     // Process in parallel with simple approach
//     final results = await _processInParallelWithProgress(
//       tasks: tasks,
//       threadCount: actualThreadCount,
//       onProgress: onProgress,
//     );

//     // Calculate total
//     int totalSize = 0;
//     for (final result in results) {
//       if (result.success) {
//         totalSize += result.compressedSize < result.originalSize
//             ? result.compressedSize
//             : result.originalSize;
//       }
//     }

//     onProgress?.call(results.length, results.length, 'Complete!');
//     return totalSize;
//   }

//   /// Process with progress updates
//   static Future<List<CompressionResult>> _processInParallelWithProgress({
//     required List<CompressionTask> tasks,
//     required int threadCount,
//     Function(int processed, int total, String status)? onProgress,
//   }) async {
//     final results = <CompressionResult>[];
//     final batchSize = (tasks.length / threadCount).ceil();

//     for (int i = 0; i < tasks.length; i += batchSize) {
//       final batch = tasks.skip(i).take(batchSize).toList();
//       final batchResults = await _processBatchInIsolate(batch, i ~/ batchSize);
//       results.addAll(batchResults);

//       onProgress?.call(results.length, tasks.length, 'Compressing images...');
//     }

//     return results;
//   }

//   /// Simple single-threaded fallback
//   static Future<int> getTotalCompressedSizeSingleThread({
//     required List<AssetEntity> imageAssets,
//     required double quality,
//     required double dimension,
//     required ExportFormat format,
//     Function(int processed, int total)? onProgress,
//   }) async {
//     int totalSize = 0;

//     for (int i = 0; i < imageAssets.length; i++) {
//       final asset = imageAssets[i];
//       final bytes = await asset.originBytes;
//       if (bytes != null) {
//         final task = CompressionTask(
//           imageBytes: bytes,
//           quality: (quality * 100).toInt(),
//           dimensionRatio: dimension,
//           format: format,
//           originalWidth: asset.width,
//           originalHeight: asset.height,
//         );

//         final result = await _processTaskInIsolate(task);
//         if (result.success) {
//           totalSize += result.compressedSize < result.originalSize
//               ? result.compressedSize
//               : result.originalSize;
//         }
//       }

//       onProgress?.call(i + 1, imageAssets.length);
//     }

//     return totalSize;
//   }

//   /// Stream-based processing for real-time updates
//   static Stream<int> getTotalCompressedSizeStream({
//     required List<AssetEntity> imageAssets,
//     required double quality,
//     required double dimension,
//     required ExportFormat format,
//     int? threadCount,
//   }) async* {
//     if (imageAssets.isEmpty) return;

//     final actualThreadCount =
//         threadCount ?? _getOptimalThreadCount(imageAssets.length);
//     int totalSize = 0;
//     int processed = 0;

//     // Process in smaller batches for streaming
//     const streamBatchSize = 5;

//     for (int i = 0; i < imageAssets.length; i += streamBatchSize) {
//       final batch = imageAssets.skip(i).take(streamBatchSize).toList();

//       final batchSize = await getTotalCompressedSize(
//         imageAssets: batch,
//         quality: quality,
//         dimension: dimension,
//         format: format,
//         threadCount: actualThreadCount,
//       );

//       totalSize += batchSize;
//       processed += batch.length;

//       yield totalSize;
//     }
//   }
// }
