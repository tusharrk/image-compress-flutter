import 'package:flutter_boilerplate/core/common_imports/common_imports.dart';
import 'package:flutter_boilerplate/core/utils/asset_utils.dart';
import 'package:flutter_boilerplate/core/utils/revenue_cat_util.dart'
    as revenue_cat;
import 'package:flutter_boilerplate/services/notification_service.dart';

class HomeViewModel extends CommonBaseViewmodel {
  // Services
  final notificationService = locator<NotificationService>();

  void initialise() {
    askNotificationPermission();
  }

  void navigateToSettings() {
    print("Theme mode saved: ${storageService.read<String>("theme_mode")}");

    navigationService.navigateToSettingsView();
  }

  void onProBtnClicked() async {
    // navigateToProUpgrade();
    //void presentPaywall() async {
    revenue_cat.presentRevenueCatPaywall();
    // }
  }

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

  void askNotificationPermission() async {
    await notificationService.requestPermissions();
  }
}
