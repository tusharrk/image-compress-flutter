// {
//  "photoQuality": 0.2,
//  "photoDimensions": 0.2,
//  "outputFormat": "JPEG",
//  "keepLocation": false,
//  "keepExif": false,
// }

import 'package:flutter_boilerplate/core/utils/compression_calculator.dart';

class PhotoCompressSettings {
  final double photoQuality;
  final double photoDimensions;
  final ExportFormat outputFormat;
  final bool keepLocation;
  final bool keepExif;

  PhotoCompressSettings({
    required this.photoQuality,
    required this.photoDimensions,
    required this.outputFormat,
    required this.keepLocation,
    required this.keepExif,
  });

  // factory PhotoCompressSettings.fromJson(Map<String, dynamic> json) {
  //   return PhotoCompressSettings(
  //     photoQuality: (json['photoQuality'] as num).toDouble(),
  //     photoDimensions: (json['photoDimensions'] as num).toDouble(),
  //     outputFormat: json['outputFormat'],
  //     keepLocation: json['keepLocation'],
  //     keepExif: json['keepExif'],
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'photoQuality': photoQuality,
  //     'photoDimensions': photoDimensions,
  //     'outputFormat': outputFormat,
  //     'keepLocation': keepLocation,
  //     'keepExif': keepExif,
  //   };
  // }
}
