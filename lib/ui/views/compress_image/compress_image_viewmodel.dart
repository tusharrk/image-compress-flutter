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
  double _photoDimensions = 1.0;
  double get photoDimensions => _photoDimensions;

  Future<void> initialise(List<AssetEntity> photosList) async {
    setBusy(true);
    selectedPhotosList.clear();
    selectedPhotosList.addAll(selectedPhotosList);
    setBusy(false);
    notifyListeners();
  }

  void updateCompressOptionType(CompressSettingsType format) {
    _defaultCompressSettingType = format;
    notifyListeners();
  }

  // photo quality Methods
  void updatePhotoQuality(double value) {
    _photoQuality = value;
    notifyListeners();
  }

  // photo quality Methods
  void updatePhotoDimension(double value) {
    _photoDimensions = value;
    notifyListeners();
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
