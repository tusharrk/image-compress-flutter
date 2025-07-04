import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    final sdkInt = androidInfo.version.sdkInt;
    if (sdkInt >= 33) {
      final status = await Permission.photos.request();
      return status.isGranted;
    } else {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

    // For iOS 14+, use limited photo library access
    if (iosInfo.systemVersion.split('.').first.compareTo('14') >= 0) {
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    } else {
      // For iOS versions below 14, use photos permission
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  return true;
}
