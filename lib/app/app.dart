import 'package:flutter_boilerplate/services/environment_service.dart';
import 'package:flutter_boilerplate/services/storage_service.dart';
import 'package:flutter_boilerplate/services/user_service.dart';
import 'package:flutter_boilerplate/ui/components/bottom_sheets/notice/notice_sheet.dart';
import 'package:flutter_boilerplate/ui/components/dialogs/info_alert/info_alert_dialog.dart';
import 'package:flutter_boilerplate/ui/views/example_page/example_page_view.dart';
import 'package:flutter_boilerplate/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_boilerplate/ui/views/home/home_view.dart';
import 'package:flutter_boilerplate/ui/views/list_photos/list_photos_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
    MaterialRoute(page: ExamplePageView),
    MaterialRoute(page: HomeView),
    MaterialRoute(page: ListPhotosView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: StorageService),
    LazySingleton(classType: EnvironmentService),
    LazySingleton(classType: UserService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App {}
