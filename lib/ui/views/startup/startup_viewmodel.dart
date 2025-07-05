import 'package:flutter_boilerplate/core/common_imports/common_imports.dart';
import 'package:flutter_boilerplate/core/common_imports/service_imports.dart';

class StartupViewModel extends CommonBaseViewmodel {
  final _navigationService = locator<NavigationService>();

  // Place anything here that needs to happen before we get into the application
  Future runStartupLogic() async {
    await Future.delayed(const Duration(seconds: 1));

    // This is where you can make decisions on where your app should navigate when
    // you have custom startup logic
    await test();
    _navigationService.replaceWithHomeView();
  }

  Future<void> test() async {
    await storageService.write('testKey', "test Value");
    setProUser(true);
  }
}
