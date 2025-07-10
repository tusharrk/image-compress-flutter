import 'package:flutter_boilerplate/core/common_imports/common_imports.dart';
import 'package:flutter_boilerplate/core/constants/app_strings.dart';
import 'package:flutter_boilerplate/core/models/compression_settings.dart';
import 'package:flutter_boilerplate/core/models/export_format_enum.dart';
import 'package:flutter_boilerplate/core/utils/ImageCompressor.dart';
import 'package:flutter_boilerplate/core/utils/asset_utils.dart';
import 'package:flutter_boilerplate/core/utils/permission_manager.dart';
import 'package:flutter_boilerplate/services/notification_service.dart';
import 'package:photo_manager/photo_manager.dart';

class CompressProcessViewModel extends CommonBaseViewmodel {
  List<AssetEntity> selectedPhotosList = [];
  PhotoCompressSettings? compressSettings;

  final notificationService = locator<NotificationService>();

  // Progress state
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  int _total = 0;
  int get total => _total;
  String _currentName = '';
  String get currentName => _currentName;
  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;
  String? _processError;
  String? get processError => _processError;

  int? _beforeCompressionSize;
  int? get beforeCompressionSize => _beforeCompressionSize;
  int? _afterCompressionSize;
  int? get afterCompressionSize => _afterCompressionSize;
  int? _savedSize;
  int? get savedSize => _savedSize;

  Future<void> initialise(List<AssetEntity> photosList,
      PhotoCompressSettings compressSettings) async {
    setBusy(true);
    selectedPhotosList.clear();
    selectedPhotosList.addAll(photosList);
    this.compressSettings = compressSettings;
    _currentIndex = 0;
    _total = selectedPhotosList.length;
    _currentName = '';
    _isSuccess = false;
    _processError = null;
    // _updateEstimatedSize();
    setBusy(false);
    notifyListeners();
    compressImages();
    notifyListeners();
  }

  Future<void> compressImages() async {
    if (selectedPhotosList.isEmpty) return;

    setBusy(true);
    _isSuccess = false;
    _processError = null;
    _currentIndex = 0;
    _currentName = '';
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));

      final permissionGranted = await requestStoragePermission();
      if (!permissionGranted) {
        _processError = "Storage permission denied.";
        setBusy(false);
        notifyListeners();
        return;
      }
      ////////////////test code
      // _currentName = "Compressing ${selectedPhotosList.length} images...";
      // _isSuccess = false;
      // _processError = "Compression error:";
      // setBusy(false);
      // notifyListeners();
      ////////////////test code end
      // add delay of 2 seconds to simulate processing time
      var compressionResult = await ImageCompressor.compressAndSaveImages(
        imageAssets: selectedPhotosList,
        quality: compressSettings?.photoQuality ?? 0.8,
        dimension: compressSettings?.photoDimensions ?? 0.9,
        format: compressSettings?.outputFormat ?? ExportFormat.original,
        folderName: AppStrings.downloadFolderName,
        keepExif: compressSettings?.keepExif ?? false,
        keepLocationData: compressSettings?.keepLocation ?? false,
        onProgress: ({
          required String currentName,
          required int currentIndex,
          required int total,
        }) {
          _currentName = currentName;
          _currentIndex = currentIndex;
          _total = total;
          notifyListeners();
        },
      );

      _updateEstimatedSize(compressionResult);

      _isSuccess = true;
      setBusy(false);
      notifyListeners();
      // Navigation to result page should be handled in the view after success
    } catch (e) {
      print("Compression error: $e");
      _processError = "Compression error: $e";
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> _updateEstimatedSize(
      CompressedImagesResult compressedImagesResult) async {
    if (selectedPhotosList.isEmpty) return;

    notifyListeners();
    try {
      _beforeCompressionSize = compressSettings?.totalSize ?? 0;

      // _afterCompressionSize =
      //     await CompressionCalculator.getTotalCompressedSize(
      //   imageAssets: selectedPhotosList,
      //   quality: compressSettings?.photoQuality ?? 0.8,
      //   dimension: compressSettings?.photoDimensions ?? 0.9,
      //   format: compressSettings?.outputFormat ?? ExportFormat.original,
      // );
      _afterCompressionSize = compressedImagesResult.totalSize;
      if (_beforeCompressionSize != null && _afterCompressionSize != null) {
        _savedSize =
            ((_beforeCompressionSize ?? 0) - (_afterCompressionSize ?? 0));
      } else {
        _savedSize = 0;
      }
      updateTotalLifeTimeSavedSize(_savedSize ?? 0);
      sendTaskCompletionNotification(
          compressedImagesResult.files.length, _savedSize ?? 0);
    } catch (e) {
      _afterCompressionSize = 0;
    }
    notifyListeners();
  }

  void updateTotalLifeTimeSavedSize(int totalSavedSize) {
    var beforeSavedSize = storageService.read<int>("total_saved_size") ?? 0;
    // print(
    //     "Before saved size: $beforeSavedSize, Total saved size: $totalSavedSize");
    var newSavedSize = beforeSavedSize + totalSavedSize;
    storageService.write("total_saved_size", newSavedSize);
    // print(
    //     "Updated total saved size: ${storageService.read<int>("total_saved_size")}");
    notifyListeners();
  }

  void sendTaskCompletionNotification(int noOfFiles, int savedSize) {
    var isNotificationEnabled =
        storageService.read<bool>("notifications_enabled") ?? true;

    if (!isNotificationEnabled) {
      return;
    }
    notificationService.showNotification(
      id: 1,
      title: 'Compression Completed',
      body: 'Successfully compressed $noOfFiles images. '
          'You saved: ${AssetUtils().formatBytes(savedSize)} 🎉',
    );
  }

  void navigateToHome() {
    navigationService.navigateToHomeView();
  }

  void retry() {
    compressImages();
  }
}
