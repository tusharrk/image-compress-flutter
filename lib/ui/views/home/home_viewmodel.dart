import 'package:flutter_boilerplate/core/common_imports/common_imports.dart';

class HomeViewModel extends CommonBaseViewmodel {
  void navigateToSettings() {
    navigationService.navigateToSettingsView();
  }

  void navigateToProUpgrade() {}

  void navigateToSelectImage() {
    navigationService.navigateToListAlbumsView();
  }

  String get totalSpaceSaved {
    // This should return the total space saved by the user
    // For now, returning a placeholder value
    return "Total Space Saved: 0 MB";
  }

  bool isUserProPurchased() {
    return isProUser();
  }
}
