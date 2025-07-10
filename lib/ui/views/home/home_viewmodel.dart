import 'package:flutter_boilerplate/core/common_imports/common_imports.dart';
import 'package:flutter_boilerplate/core/utils/asset_utils.dart';

class HomeViewModel extends CommonBaseViewmodel {
  void navigateToSettings() {
    print("Theme mode saved: ${storageService.read<String>("theme_mode")}");

    navigationService.navigateToSettingsView();
  }

  void navigateToProUpgrade() {}

  void navigateToSelectImage() {
    navigationService.navigateToListAlbumsView();
  }

  String get totalSpaceSaved {
    var totalSavedSize = storageService.read<int>("total_saved_size") ?? 0;
    if (totalSavedSize == 0) {
      return "0 MB";
    } else {
      //data with celebration emoji
      return "${AssetUtils().formatBytes(totalSavedSize)} 🎉";
    }
    // This should return the total space saved by the user
    // For now, returning a placeholder value
    // return "Total Space Saved: 0 MB";
  }

  bool isUserProPurchased() {
    return isProUser();
  }
}
