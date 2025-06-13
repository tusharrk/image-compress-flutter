import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/app/app.bottomsheets.dart';
import 'package:flutter_boilerplate/app/app.dialogs.dart';
import 'package:flutter_boilerplate/app/app.locator.dart';
import 'package:flutter_boilerplate/app/app.router.dart';
import 'package:flutter_boilerplate/core/theme/custom_dark_theme.dart';
import 'package:flutter_boilerplate/core/theme/custom_light_theme.dart';
import 'package:flutter_boilerplate/core/translation/app_localization.dart';
import 'package:flutter_boilerplate/services/theme_service.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:stacked_services/stacked_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await setupLocator();
  setupServices();
  setupSnackbarUi();
  setupDialogUi();
  setupBottomSheetUi();
  runApp(AppLocalization(child: const MainApp()));
  //runApp(const MainApp());
}

void setupServices() {
  locator.registerLazySingleton(() => SnackbarService());
}

void setupSnackbarUi() {
  final service = locator<SnackbarService>();

  // Registers a config to be used when calling showSnackbar
  service.registerSnackbarConfig(SnackbarConfig(
    textColor: Colors.white,
    mainButtonTextColor: Colors.black,
    snackPosition: SnackPosition.BOTTOM,
    animationDuration: const Duration(milliseconds: 200),
    barBlur: 1,
    snackStyle: SnackStyle.FLOATING,
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = locator<ThemeService>();

    return ValueListenableBuilder(
        valueListenable: themeService.themeModeNotifier,
        builder: (context, ThemeMode mode, _) {
          return GetMaterialApp(
            title: 'app_name',
            theme: CustomLightTheme().themeData,
            darkTheme: CustomDarkTheme().themeData,
            themeMode: mode,
            initialRoute: Routes.startupView,
            onGenerateRoute: StackedRouter().onGenerateRoute,
            navigatorKey: StackedService.navigatorKey,
            navigatorObservers: [StackedService.routeObserver],
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          );
        });
  }
}
