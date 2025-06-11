import 'package:flutter_boilerplate/app/app.locator.dart';
import 'package:flutter_boilerplate/core/viewmodels/common_base_viewmodel.dart';
import 'package:flutter_boilerplate/services/gallery_service.dart'
    show GalleryService;
import 'package:photo_manager/photo_manager.dart';

class ListPhotosViewModel extends CommonBaseViewmodel {
  final _galleryService = locator<GalleryService>();

  List<AssetEntity> get accessibleAssets => _galleryService.accessibleAssets;
  List<AssetPathEntity> get albums => _galleryService.albums;
  bool get hasPermission =>
      _galleryService.permissionState == PermissionState.authorized ||
      _galleryService.permissionState == PermissionState.limited;
  // bool get hasPermission => true;

  bool get hasFullAccess => _galleryService.hasFullAccess;
  bool get hasLimitedAccess => _galleryService.hasLimitedAccess;

  Future<void> initialise() async {
    setBusy(true);
    await _galleryService.loadAccessibleContent();
    setBusy(false);
  }

  Future<void> requestPermission() async {
    setBusy(true);
    final permission = await _galleryService.requestPermission();

    if (permission == PermissionState.authorized ||
        permission == PermissionState.limited) {
      await _galleryService.loadAccessibleContent();
      _showPermissionMessage();
    } else {
      // _snackbarService.showSnackbar(
      //   message: 'Photo access is required to use this feature',
      //   duration: const Duration(seconds: 3),
      // );
      logger.w(
        'Photo access is required to use this feature',
      );
    }
    setBusy(false);
  }

  void _showPermissionMessage() {
    if (hasFullAccess) {
      // _snackbarService.showSnackbar(
      //   message:
      //       'Full access granted! All photos and albums are now available.',
      //   duration: const Duration(seconds: 3),
      // );
      logger.i(
        'Full access granted! All photos and albums are now available.',
      );
    } else if (hasLimitedAccess) {
      // _snackbarService.showSnackbar(
      //   message: 'Limited access granted. You can add more photos anytime.',
      //   duration: const Duration(seconds: 3),
      // );
      logger.i(
        'Limited access granted. You can add more photos anytime.',
      );
    }
  }

  Future<void> addMorePhotos() async {
    if (!hasPermission) {
      await requestPermission();
      return;
    }

    // Open native photo picker
    try {
      await _galleryService.openNativePhotoPicker();
      await refresh();

      // _snackbarService.showSnackbar(
      //   message: 'Photos updated! Pull down to refresh if needed.',
      //   duration: const Duration(seconds: 2),
      // );
      logger.i(
        'Photos updated! Pull down to refresh if needed.',
      );
    } catch (e) {
      // _snackbarService.showSnackbar(
      //   message: 'Unable to open photo picker',
      //   duration: const Duration(seconds: 2),
      // );
      logger.e('Error opening photo picker: $e');
    }
  }

  Future<void> refresh() async {
    setBusy(true);
    _galleryService.refresh();
    setBusy(false);
  }

  Future<void> showAlbumPhotos(AssetPathEntity album) async {
    setBusy(true);
    final albumAssets = await _galleryService.getAssetsFromAlbum(album);
    setBusy(false);

    if (albumAssets.isEmpty) {
      // _snackbarService.showSnackbar(
      //   message: 'This album is empty',
      //   duration: const Duration(seconds: 2),
      // );
      logger.w('This album is empty');
      return;
    }

    // Show album photos in a dialog or bottom sheet
    // await _dialogService.showCustomDialog(
    //   variant: 'album_photos',
    //   title: album.name,
    //   description: '${albumAssets.length} photos',
    //   data: albumAssets,
    // );
    logger.i(
      'Showing ${albumAssets.length} photos from album: ${album.name}',
    );
  }

  void viewPhoto(AssetEntity asset) {
    // Handle photo tap - could open full screen view, show details, etc.
    // _snackbarService.showSnackbar(
    //   message: 'Photo: ${asset.title ?? "Untitled"}',
    //   duration: const Duration(seconds: 1),
    // );
    logger.i('Viewing photo: ${asset.title ?? "Untitled"}');
  }
}
