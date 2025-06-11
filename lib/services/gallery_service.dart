import 'package:photo_manager/photo_manager.dart';

class GalleryService {
  List<AssetEntity> _accessibleAssets = [];
  List<AssetPathEntity> _albums = [];
  PermissionState _permissionState = PermissionState.notDetermined;

  List<AssetEntity> get accessibleAssets => _accessibleAssets;
  List<AssetPathEntity> get albums => _albums;
  PermissionState get permissionState => _permissionState;
  bool get hasFullAccess => _permissionState == PermissionState.authorized;
  bool get hasLimitedAccess => _permissionState == PermissionState.limited;

  Future<PermissionState> requestPermission() async {
    final permission = await PhotoManager.requestPermissionExtend();
    _permissionState = permission;
    print('Permission state: $_permissionState');
    return permission;
  }

  Future<void> loadAccessibleContent() async {
    if (_permissionState == PermissionState.notDetermined) {
      await requestPermission();
    }

    if (_permissionState == PermissionState.authorized) {
      // Full access - load all photos and albums
      await _loadAlbums();
      await _loadAllPhotos();
    } else if (_permissionState == PermissionState.limited) {
      // Limited access - load only accessible photos
      await _loadAccessiblePhotos();
    }
  }

  Future<void> _loadAlbums() async {
    _albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: false,
    );
  }

  Future<void> _loadAllPhotos() async {
    if (_albums.isNotEmpty) {
      // Get all photos from the main album (usually "Recent" or "All Photos")
      _accessibleAssets =
          await _albums.first.getAssetListPaged(page: 0, size: 500);
    }
  }

  Future<void> _loadAccessiblePhotos() async {
    // For limited access, get only the photos user has granted access to
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );

    if (paths.isNotEmpty) {
      _accessibleAssets =
          await paths.first.getAssetListPaged(page: 0, size: 500);
    }
  }

  Future<List<AssetEntity>> getAssetsFromAlbum(AssetPathEntity album) async {
    return await album.getAssetListPaged(page: 0, size: 500);
  }

  Future<void> openNativePhotoPicker() async {
    // This will trigger the native photo picker
    // The newly selected photos will automatically be accessible
    final permission = await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      // Reload accessible content after user potentially adds more photos
      await loadAccessibleContent();
    }
  }

  void refresh() async {
    await loadAccessibleContent();
  }
}
