import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/app/app.dialogs.dart';
import 'package:flutter_boilerplate/app/app.locator.dart';
import 'package:flutter_boilerplate/app/app.router.dart';
import 'package:flutter_boilerplate/services/storage_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:stacked_services/stacked_services.dart';

export 'package:purchases_flutter/purchases_flutter.dart'
    show Package, Offering;

Offerings? _offerings;
CustomerInfo? _customerInfo;
String? _loggedInUid;

Offerings? get offerings => _offerings;

CustomerInfo? get customerInfo => _customerInfo;

final dialogService = locator<DialogService>();
final storageService = locator<StorageService>();
final navigationService = locator<NavigationService>();

set customerInfo(CustomerInfo? customerInfo) => _customerInfo = customerInfo;

Future initialize(
  String appStoreKey,
  String playStoreKey, {
  bool debugLogEnabled = false,
  bool loadDataAfterLaunch = false,
}) async {
  if (kIsWeb) {
    print('RevenueCat is not supported on web.');
    return;
  }
  try {
    PurchasesConfiguration configuration;
    if (Platform.isIOS) {
      await Purchases.setLogLevel(LogLevel.debug);
      configuration = PurchasesConfiguration(appStoreKey);
      await Purchases.configure(configuration);
    } else if (Platform.isAndroid) {
      //  configuration = PurchasesConfiguration(playStoreKey);
      //  await Purchases.configure(configuration);
      //TODO: uncomment when add for android
    } else {
      print("RevenueCat is not supported on this platform.");
      return;
    }

    if (loadDataAfterLaunch) {
      loadCustomerInfo();
      loadOfferings();
    } else {
      await loadCustomerInfo();
      await loadOfferings();
    }

    Purchases.addCustomerInfoUpdateListener((info) {
      customerInfo = info;
    });
  } on Exception catch (e) {
    // This should happen only in the web run mode.
    print("RevenueCat initialization failed: $e");
  }
}

// Purchase a package.
Future<bool> purchasePackage(String package) async {
  try {
    final revenueCatPackage = offerings?.current?.getPackage(package);
    if (revenueCatPackage == null) {
      return false;
    }
    var result = await Purchases.purchasePackage(revenueCatPackage);
    customerInfo = result.customerInfo;
    return true;
  } catch (_) {
    return false;
  }
}

List<String> get activeEntitlementIds => _customerInfo != null
    ? _customerInfo!.entitlements.active.values
        .map((e) => e.identifier)
        .toList()
    : [];

Future loadOfferings() async {
  try {
    _offerings = await Purchases.getOfferings();
    print("Offerings");
  } on PlatformException catch (e) {
    print("Error loading offerings info: $e");
  }
}

Future loadCustomerInfo() async {
  try {
    _customerInfo = await Purchases.getCustomerInfo();
  } on PlatformException catch (e) {
    print("Error loading purchaser info: $e");
  }
}

// Return if the user has the entitlement.
// Return null on errors.
Future<bool?> isEntitled(String entitlementId) async {
  try {
    customerInfo = await Purchases.getCustomerInfo();
    return customerInfo!.entitlements.all[entitlementId]?.isActive ?? false;
  } on Exception catch (e) {
    print("Unable to check RevenueCat entitlements: $e");
    return null;
  }
}

// https://docs.revenuecat.com/docs/user-ids
Future login(String? uid) async {
  if (kIsWeb || uid == _loggedInUid) {
    return;
  }
  try {
    if (uid != null) {
      customerInfo = (await Purchases.logIn(uid)).customerInfo;
    } else {
      customerInfo = await Purchases.logOut();
    }
    _loggedInUid = uid;
  } on Exception catch (e) {
    debugPrint("Unable to logIn or logOut user in RevenueCat: $e");
  }
}

// https://docs.revenuecat.com/docs/restoring-purchases
Future restorePurchases() async {
  try {
    customerInfo = await Purchases.restorePurchases();
  } on PlatformException catch (e) {
    debugPrint("Unable to restore purchases in RevenueCat: $e");
  }
}

Future fetchUserPurchases() async {
  try {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    // access latest customerInfo
    // print('Customer Info: ${customerInfo.toJson()}');
    // print('Active Entitlements: ${customerInfo.entitlements.active}');
    // print(
    //     'active Entitlements: ${customerInfo.activeSubscriptions.join(', ')}');
    debugPrint(
        'Active Entitlements: ${customerInfo.entitlements.active.isNotEmpty}');
    if (customerInfo.entitlements.active.isNotEmpty) {
      //user has access to some entitlement
      await storageService.write("isProUser", true);
    } else {
      await storageService.write("isProUser", false);
    }
  } on PlatformException catch (e) {
    // Error fetching customer info
    debugPrint("Error fetching customer info: $e");
  }
}

Future presentRevenueCatPaywall() async {
  final paywallResult = await RevenueCatUI.presentPaywall();
  print('Paywall result: $paywallResult');
  await handlePurchaseResult(paywallResult);
}

Future handlePurchaseResult(PaywallResult result) async {
  if (result == PaywallResult.purchased) {
    // Handle successful purchase
    print('Purchase was successful.');
    // Optionally, you can navigate to a different screen or show a success message
    await _showPurchaseSuccessDialog();
    await storageService.write("isProUser", true);
    navigationService.clearStackAndShow(Routes.homeView);
    print('User is now a Pro user, status saved in storage.');
  } else if (result == PaywallResult.notPresented) {
    print('Paywall was not presented.');
  } else if (result == PaywallResult.cancelled) {
    print('Purchase was cancelled by the user.');
  } else {
    print('An unknown result occurred: $result');
  }
}

Future _showPurchaseSuccessDialog() async {
  await dialogService.showCustomDialog(
    variant: DialogType.infoAlert,
    title: 'Purchase Successful',
    description:
        'Thank you for subscribing to our Pro plan! You now have access to all premium features.',
    mainButtonTitle: 'Got it',
  );
}
