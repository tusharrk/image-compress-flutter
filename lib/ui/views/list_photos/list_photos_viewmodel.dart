import 'package:flutter_boilerplate/app/app.locator.dart';
import 'package:flutter_boilerplate/core/viewmodels/common_base_viewmodel.dart';
import 'package:flutter_boilerplate/services/gallery_service.dart'
    show GalleryService;
import 'package:photo_manager/photo_manager.dart';

class ListPhotosViewModel extends CommonBaseViewmodel {
  final _galleryService = locator<GalleryService>();

  bool _isAddingPhotos = false;
  bool get isAddingPhotos => _isAddingPhotos;

  Future<void> initialise() async {
    setBusy(true);
    try {
      await _galleryService.loadAccessibleContent();
      _showPermissionMessage();
    } catch (e) {
      logger.e('Error initializing gallery: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> requestPermission() async {
    setBusy(true);
    try {
      final permission = await _galleryService.requestPermission();

      if (permission == PermissionState.authorized ||
          permission == PermissionState.limited) {
        await _galleryService.loadAccessibleContent();
        _showPermissionMessage();
      } else {
        logger.w('Photo access is required to use this feature');
        _showPermissionDeniedMessage();
      }
    } catch (e) {
      logger.e('Error requesting permission: $e');
    } finally {
      setBusy(false);
    }
  }

  // Updated permission getters to handle Android 14+ issues
  bool get hasPermission =>
      _galleryService.permissionState == PermissionState.authorized ||
      _galleryService.permissionState == PermissionState.limited;

  bool get hasFullAccess => _galleryService.hasFullAccess;

  bool get hasLimitedAccess => _galleryService.hasLimitedAccess;

  // New getter to check effective full access (handles Android 14+ reporting issues)
  bool get hasEffectiveFullAccess => _galleryService.hasEffectiveFullAccess;

  // Check if "Add More Photos" button should be enabled
  bool get canAddMorePhotos {
    // Don't allow adding more photos if:
    // 1. No permission at all
    // 2. Already have full access (or effective full access)
    // 3. Currently in process of adding photos
    if (!hasPermission ||
        hasFullAccess ||
        hasEffectiveFullAccess ||
        _isAddingPhotos) {
      return false;
    }

    // Only allow if we have limited access and it's actually limited
    return hasLimitedAccess &&
        accessibleAssets.length < 50; // Adjust threshold as needed
  }

  String get addMorePhotosButtonText {
    if (!hasPermission) return 'Grant Permission';
    if (hasFullAccess || hasEffectiveFullAccess) return 'Full Access Granted';
    if (_isAddingPhotos) return 'Adding Photos...';
    return 'Add More Photos';
  }

  List<AssetPathEntity> get albums => _galleryService.albums;

  List<AssetEntity> get accessibleAssets => _galleryService.accessibleAssets;

  String get permissionStatusMessage => _galleryService.permissionStatusMessage;

  Future<void> addMorePhotos() async {
    // Prevent multiple simultaneous calls
    if (_isAddingPhotos) {
      logger.i('Already adding photos, please wait...');
      return;
    }

    // Don't allow if we already have full access
    if (!canAddMorePhotos) {
      if (hasFullAccess || hasEffectiveFullAccess) {
        logger.i('You already have full access to photos');
        _showFullAccessMessage();
      } else {
        logger.w('Cannot add more photos at this time');
      }
      return;
    }

    _isAddingPhotos = true;
    notifyListeners();

    try {
      final success = await _galleryService.requestMorePhotos();

      if (success) {
        // Check if permission was upgraded
        if (_galleryService.permissionState == PermissionState.authorized) {
          logger.i('Permission upgraded to full access!');
          _showFullAccessGrantedMessage();
        } else {
          logger.i('Photos updated! Pull down to refresh if needed.');
          _showPhotosUpdatedMessage();
        }

        // Refresh the data
        await initialise();
      } else {
        logger.w('No new photos were added or permission was not granted');
        _showNoPhotosAddedMessage();
      }
    } catch (e) {
      logger.e('Error opening photo picker: $e');
      _showErrorMessage('Unable to open photo picker');
    } finally {
      _isAddingPhotos = false;
      notifyListeners();
    }
  }

  Future<void> showAlbumPhotos(AssetPathEntity album) async {
    setBusy(true);
    try {
      final albumAssets = await _galleryService.getAssetsFromAlbum(album);

      if (albumAssets.isEmpty) {
        logger.w('Album "${album.name}" is empty');
        _showEmptyAlbumMessage(album.name);
        return;
      }

      // Show album photos in a dialog or bottom sheet
      // await _dialogService.showCustomDialog(
      //   variant: 'album_photos',
      //   title: album.name,
      //   description: '${albumAssets.length} photos',
      //   data: albumAssets,
      // );

      logger
          .i('Showing ${albumAssets.length} photos from album: ${album.name}');
    } catch (e) {
      logger.e('Error loading album photos: $e');
      _showErrorMessage('Unable to load album photos');
    } finally {
      setBusy(false);
    }
  }

  void _showPermissionMessage() {
    if (hasFullAccess || hasEffectiveFullAccess) {
      _showFullAccessMessage();
    } else if (hasLimitedAccess) {
      _showLimitedAccessMessage();
    }
  }

  void _showFullAccessMessage() {
    // _snackbarService.showSnackbar(
    //   message: 'Full access granted! All photos and albums are now available.',
    //   duration: const Duration(seconds: 3),
    // );
    logger.i('Full access granted! All photos and albums are now available.');
  }

  void _showLimitedAccessMessage() {
    // _snackbarService.showSnackbar(
    //   message: 'Limited access granted. You can add more photos anytime.',
    //   duration: const Duration(seconds: 3),
    // );
    logger.i('Limited access granted. You can add more photos anytime.');
  }

  void _showFullAccessGrantedMessage() {
    // _snackbarService.showSnackbar(
    //   message: 'Upgraded to full access! All photos are now available.',
    //   duration: const Duration(seconds: 3),
    // );
    logger.i('Upgraded to full access! All photos are now available.');
  }

  void _showPhotosUpdatedMessage() {
    // _snackbarService.showSnackbar(
    //   message: 'Photos updated! Pull down to refresh if needed.',
    //   duration: const Duration(seconds: 2),
    // );
    logger.i('Photos updated! Pull down to refresh if needed.');
  }

  void _showNoPhotosAddedMessage() {
    // _snackbarService.showSnackbar(
    //   message: 'No new photos were selected.',
    //   duration: const Duration(seconds: 2),
    // );
    logger.i('No new photos were selected.');
  }

  void _showPermissionDeniedMessage() {
    // _snackbarService.showSnackbar(
    //   message: 'Photo access denied. Please enable in settings.',
    //   duration: const Duration(seconds: 3),
    // );
    logger.w('Photo access denied. Please enable in settings.');
  }

  void _showEmptyAlbumMessage(String albumName) {
    // _snackbarService.showSnackbar(
    //   message: 'Album "$albumName" is empty',
    //   duration: const Duration(seconds: 2),
    // );
    logger.w('Album "$albumName" is empty');
  }

  void _showErrorMessage(String message) {
    // _snackbarService.showSnackbar(
    //   message: message,
    //   duration: const Duration(seconds: 2),
    // );
    logger.e(message);
  }

  void viewPhoto(AssetEntity asset) {
    // Handle photo tap - could open full screen view, show details, etc.
    // _snackbarService.showSnackbar(
    //   message: 'Photo: ${asset.title ?? "Untitled"}',
    //   duration: const Duration(seconds: 1),
    // );
    logger.i('Viewing photo: ${asset.title ?? "Untitled"}');
  }

  // Refresh method for pull-to-refresh
  Future<void> refresh() async {
    await _galleryService.refresh();
    notifyListeners();
  }

  // Open app settings if permission is denied
  Future<void> openAppSettings() async {
    try {
      await _galleryService.openAppSettings();
    } catch (e) {
      logger.e('Error opening app settings: $e');
    }
  }

  bool isAdBtnVisible() {
    if (!canAddMorePhotos) {
      if (hasFullAccess || hasEffectiveFullAccess) {
        logger.i('You already have full access to photos');
        return false;
      } else {
        logger.w('Cannot add more photos at this time');
        return false;
      }
    } else {
      return true;
    }
  }
}
