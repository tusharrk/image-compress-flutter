import 'package:flutter_boilerplate/core/viewmodels/common_base_viewmodel.dart';
import 'package:photo_manager/photo_manager.dart';

class CompressImageViewModel extends CommonBaseViewmodel {
  List<AssetEntity> selectedPhotosList = [];

  Future<void> initialise(List<AssetEntity> photosList) async {
    setBusy(true);
    selectedPhotosList.clear();
    selectedPhotosList.addAll(selectedPhotosList);
    setBusy(false);
    notifyListeners();
  }
}
