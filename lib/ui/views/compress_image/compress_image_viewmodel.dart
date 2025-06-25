import 'dart:async';

import 'package:flutter_boilerplate/core/utils/compression_calculator.dart';
import 'package:flutter_boilerplate/core/viewmodels/common_base_viewmodel.dart';
import 'package:photo_manager/photo_manager.dart';

class CompressImageViewModel extends CommonBaseViewmodel {
  List<AssetEntity> selectedPhotosList = [];

// compression settings type
  CompressSettingsType _defaultCompressSettingType =
      CompressSettingsType.simple;
  CompressSettingsType get defaultCompressSettingType =>
      _defaultCompressSettingType;
  List<CompressSettingsType> get compressSettingTypeList =>
      CompressSettingsType.values;

  // photo quality
  double _photoQuality = 0.8;
  double get photoQuality => _photoQuality;

  // photo dimension
  double _photoDimensions = 0.9;
  double get photoDimensions => _photoDimensions;

  String _photoQualityText = "Great";
  String get photoQualityText => _photoQualityText;

  String _photoDimensionsText = "";
  String get photoDimensionsText => _photoDimensionsText;

  int _totalImageSize = 0;
  int get totalImageSize => _totalImageSize;

  int _totalCompressedImageSize = 0;
  int get totalCompressedImageSize => _totalCompressedImageSize;

  Timer? _debounceTimer;
  bool _isCalculating = false;
  bool get isCalculating => _isCalculating;
  ExportFormat selectedFormat = ExportFormat.jpg;

  Future<void> initialise(List<AssetEntity> photosList) async {
    setBusy(true);
    selectedPhotosList.clear();
    selectedPhotosList.addAll(photosList);
    setBusy(false);
    calculateTotalImageSize();
    setPhotoQualityText(_photoQuality);
    setPhotoDimensionsText(_photoDimensions);
    calculateTotalCompressedImageSize();
    notifyListeners();
  }

  void updateCompressOptionType(CompressSettingsType format) {
    _defaultCompressSettingType = format;
    notifyListeners();
  }

  // photo quality Methods
  void updatePhotoQuality(double value) {
    _photoQuality = value;
    setPhotoQualityText(value);
    calculateTotalCompressedImageSize();
    notifyListeners();
  }

  // photo quality Methods
  void updatePhotoDimension(double value) {
    _photoDimensions = value;
    setPhotoDimensionsText(value);
    calculateTotalCompressedImageSize();
    notifyListeners();
  }

  void setPhotoQualityText(double value) {
    if (value < 0.2) {
      _photoQualityText = "Worst";
    } else if (value < 0.4) {
      _photoQualityText = "Poor";
    } else if (value < 0.6) {
      _photoQualityText = "Acceptable";
    } else if (value < 0.8) {
      _photoQualityText = "Good";
    } else if (value < 1.0) {
      _photoQualityText = "Great";
    } else {
      _photoQualityText = "Excellent";
    }
    notifyListeners();
  }

  void setPhotoDimensionsText(double value) {
    try {
      if (selectedPhotosList.length > 1) {
        _photoDimensionsText = "Multiple";
      } else if (selectedPhotosList.isNotEmpty) {
        final asset = selectedPhotosList.first;
        final width = asset.width;
        final height = asset.height;

        final estimatedWidth = (width * value).round();
        final estimatedHeight = (height * value).round();
        _photoDimensionsText = "$estimatedWidth x $estimatedHeight";
      }
      notifyListeners();
    } catch (e) {
      print("error------------$e");
    }
  }

  Future<void> calculateTotalImageSize() async {
    int total = 0;

    for (final asset in selectedPhotosList) {
      final file = await asset.originFile;
      if (file != null) {
        total += file.lengthSync();
      }
    }
    _totalImageSize = total;
    notifyListeners();
  }

  Future<void> calculateTotalCompressedImageSize() async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _updateEstimatedSize();
    });

    notifyListeners();
  }

  Future<void> _updateEstimatedSize() async {
    if (selectedPhotosList.isEmpty) return;

    _isCalculating = true;
    notifyListeners();

    print(
        "photoQuality: $_photoQuality, photoDimensions: $_photoDimensions, selectedFormat: $selectedFormat");
    try {
      _totalCompressedImageSize =
          await CompressionCalculator.getTotalCompressedSize(
        imageAssets: selectedPhotosList,
        quality: photoQuality,
        dimension: photoDimensions,
        format: selectedFormat,
      );
    } catch (e) {
      _totalCompressedImageSize = 0;
    }

    _isCalculating = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

enum CompressSettingsType {
  simple,
  advance;

  String get displayName {
    switch (this) {
      case CompressSettingsType.simple:
        return 'Simple Options';
      case CompressSettingsType.advance:
        return 'Advanced Options';
    }
  }
}
