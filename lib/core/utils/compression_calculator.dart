// compression_calculator.dart
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_boilerplate/core/models/export_format_enum.dart';
import 'package:flutter_boilerplate/core/utils/ImageCompressor.dart';
import 'package:path/path.dart' as p;
import 'package:photo_manager/photo_manager.dart';

class CancellationToken {
  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;
  void cancel() => _isCancelled = true;
}

class CompressionCalculator {
  static CancellationToken? _currentToken;

  static Future<int> getTotalCompressedSize({
    required List<AssetEntity> imageAssets,
    required double quality, // 0..1
    required double dimension,
    required ExportFormat format,
    required bool keepExif,
    required bool keepLocation,
  }) async {
    _currentToken?.cancel();
    final token = CancellationToken();
    _currentToken = token;

    try {
      int total = 0;
      for (final asset in imageAssets) {
        if (token.isCancelled) return 0;

        final file = await asset.originFile ?? await asset.file;
        if (file == null) continue;
        print("getTotalCompressedSize== Processing File Path: ${file.path}");
        print(
            "getTotalCompressedSize== File Extension: ${p.extension(file.path)}");
        final bytes = await file.readAsBytes();
        final w = (asset.width * dimension).toInt();
        final h = (asset.height * dimension).toInt();
        print(
            "filename before calculate:- ${(asset.title?.isNotEmpty ?? false) ? asset.title! : p.basename(file.path)}");

        print("height-$h");
        print("width-$w");

        // final size = await ImageCompressor.calculateCompressedSize(
        //   originalImage: bytes,
        //   quality: quality,
        //   width: w,
        //   height: h,
        //   format: format,
        //   sourceFileName: asset.title ?? p.basename(file.path),
        //   keepExif: keepExif,
        //   keepLocation: keepLocation,
        // );
        final Uint8List? compressed = await ImageCompressor.compressNative(
          originalImage: bytes,
          quality: quality,
          width: w,
          height: h,
          format: format,
          keepExif: keepExif,
          keepLocation: keepLocation,
          sourceFileName: (asset.title?.isNotEmpty ?? false)
              ? asset.title!
              : p.basename(file.path),
        );

        var size = compressed?.length ?? bytes.length;
        total += (size > 0 ? size : bytes.length);
        print("calculated size:- $size");
      }
      return token.isCancelled ? 0 : total;
    } finally {
      if (_currentToken == token) _currentToken = null;
    }
  }

  static void cancel() => _currentToken?.cancel();
}
