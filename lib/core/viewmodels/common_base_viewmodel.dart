import 'package:flutter_boilerplate/app/app.logger.dart';
import 'package:flutter_boilerplate/core/common_imports/common_imports.dart';
import 'package:flutter_boilerplate/core/common_imports/service_imports.dart';
import 'package:logger/logger.dart';

class CommonBaseViewmodel extends BaseViewModel {
  final storageService = locator<StorageService>();
  final navigationService = locator<NavigationService>();
  final environmentService = locator<EnvironmentService>();
  final dialogService = locator<DialogService>();
  final bottomSheetService = locator<BottomSheetService>();
  final snackbarService = locator<SnackbarService>();

  Environment get currentEnvironment => environmentService.currentEnvironment;
  late final Logger logger;
  CommonBaseViewmodel() {
    logger = getLogger(runtimeType.toString());
  }
  //String get apiUrl => environmentService.apiUrl;

  // This would handle switching environments at runtime if needed
  // Note: With envied, full switching would require regenerating code

  // void toggleEnvironment() {
  //   environmentService.setEnvironment(environmentService.isDevelopment
  //       ? Environment.production
  //       : Environment.development);
  //   notifyListeners();
  // }
}
