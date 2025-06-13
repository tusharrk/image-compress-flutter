import 'dart:math';

import 'package:photo_manager/photo_manager.dart';

class AssetUtils {
  Future<String> getFileSize(AssetEntity asset) async {
    final file = await asset.originFile;
    if (file == null) return '';
    final bytes = await file.length();
    return formatBytes(bytes);
  }

  String formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(1024))
        .floor(); // bytes must be converted to double implicitly
    final size = bytes / pow(1024, i);
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
