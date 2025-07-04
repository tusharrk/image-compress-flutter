import 'package:flutter_boilerplate/core/constants/app_strings.dart';
import 'package:flutter_boilerplate/core/models/compression_settings.dart';
import 'package:flutter_boilerplate/core/utils/ImageCompressor.dart';
import 'package:flutter_boilerplate/core/utils/compression_calculator.dart';
import 'package:flutter_boilerplate/core/utils/permission_manager.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stacked/stacked.dart';

class CompressProcessViewModel extends BaseViewModel {
  List<AssetEntity> selectedPhotosList = [];
  PhotoCompressSettings? compressSettings;

  Future<void> initialise(List<AssetEntity> photosList,
      PhotoCompressSettings compressSettings) async {
    setBusy(true);
    selectedPhotosList.clear();
    selectedPhotosList.addAll(photosList);
    this.compressSettings = compressSettings;
    setBusy(false);
    notifyListeners();
    compressImages();
    notifyListeners();
  }

  Future<void> compressImages() async {
    if (selectedPhotosList.isEmpty) return;

    setBusy(true);
    try {
      final permissionGranted = await requestStoragePermission();
      if (!permissionGranted) {
        print("Storage permission denied.");
        return;
      }

      await ImageCompressor.compressAndSaveImages(
        imageAssets: selectedPhotosList,
        quality: compressSettings?.photoQuality ?? 0.8,
        dimension: compressSettings?.photoDimensions ?? 0.9,
        format: compressSettings?.outputFormat ?? ExportFormat.jpg,
        folderName: AppStrings.appName,
        onProgress: ({
          required String currentName,
          required int currentIndex,
          required int total,
        }) {
          print("Compressing $currentName ($currentIndex/$total)");
        },
      );
      print("Compression completed successfully.");

      // Optionally, you can navigate to a success screen or show a success message
    } catch (e) {
      // Handle any errors that occur during compression
      print("Compression error: $e");
    } finally {
      setBusy(false);
    }
  }
}
