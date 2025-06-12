import 'package:photo_manager/photo_manager.dart';

class GalleryService {
  List<AssetEntity> _accessibleAssets = [];
  List<AssetPathEntity> _albums = [];
  int pageSize = 200;
  PermissionState _permissionState = PermissionState.notDetermined;

  // Getters
  List<AssetEntity> get accessibleAssets => _accessibleAssets;
  List<AssetPathEntity> get albums => _albums;
  PermissionState get permissionState => _permissionState;
  bool get hasFullAccess => _permissionState == PermissionState.authorized;
  bool get hasLimitedAccess => _permissionState == PermissionState.limited;
  bool get hasAnyAccess =>
      _permissionState.isAuth || _permissionState == PermissionState.limited;

  /// Request photo access permission
  Future<PermissionState> requestPermission() async {
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      _permissionState = permission;
      print('Permission state: $_permissionState');
      return permission;
    } catch (e) {
      print('Error requesting permission: $e');
      return PermissionState.denied;
    }
  }

  /// Load all accessible content based on permission state
  Future<void> loadAccessibleContent() async {
    try {
      // Always get the current permission state first
      _permissionState = await PhotoManager.getPermissionState(
        requestOption: const PermissionRequestOption(),
      );
      print('Current permission state: $_permissionState');

      // Request permission if not determined
      if (_permissionState == PermissionState.notDetermined) {
        await requestPermission();
      }

      // Load content based on permission level
      if (hasAnyAccess) {
        await _loadAlbums();
        //  await _loadAccessiblePhotos();
      } else {
        print('No access to photos - clearing existing data');
        _clearData();
      }

      // Additional check for Android 14+ partial access
      await _checkAndHandlePartialAccess();
    } catch (e) {
      print('Error loading accessible content: $e');
      _clearData();
    }
  }

  /// Check and handle Android 14+ partial photo access
  Future<void> _checkAndHandlePartialAccess() async {
    try {
      // On Android 14+, even "limited" might mean we have access to photos
      // Let's verify by trying to load albums and photos
      if (_permissionState == PermissionState.limited && _albums.isNotEmpty) {
        print('Android partial access detected - checking actual photo access');

        // Try to get actual photo count to verify access
        final totalPhotos = _accessibleAssets.length;
        print('Accessible photos count: $totalPhotos');

        if (totalPhotos > 0) {
          print('Partial access is working - photos are accessible');
        } else {
          print(
              'Limited access with no photos - may need user to select photos');
        }
      }
    } catch (e) {
      print('Error checking partial access: $e');
    }
  }

  /// Load all available albums
  Future<void> _loadAlbums() async {
    try {
      _albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: false,
      );
      print('Loaded ${_albums.length} albums');
    } catch (e) {
      print('Error loading albums: $e');
      _albums = [];
    }
  }

  /// Load accessible photos (works for both full and limited access)
  Future<void> _loadAccessiblePhotos() async {
    try {
      if (_albums.isNotEmpty) {
        // Get photos from the first album (usually "Recent" or "All Photos")
        // This automatically respects the permission level
        _accessibleAssets = await _albums.first.getAssetListPaged(
          page: 0,
          size: 1000, // Increased size for better performance
        );
        print('Loaded ${_accessibleAssets.length} accessible photos');
      } else {
        _accessibleAssets = [];
      }
    } catch (e) {
      print('Error loading accessible photos: $e');
      _accessibleAssets = [];
    }
  }

  /// Get assets from a specific album with pagination
  Future<List<AssetEntity>> getAssetsFromAlbum(
    AssetPathEntity album, {
    int page = 0,
    int size = 200,
  }) async {
    try {
      return await album.getAssetListPaged(page: page, size: size);
    } catch (e) {
      print('Error getting assets from album: $e');
      return [];
    }
  }

  /// Load more assets from a specific album (for pagination)
  Future<List<AssetEntity>> loadMoreAssetsFromAlbum(
      AssetPathEntity album, int currentCount,
      {int pageSize = 200}) async {
    try {
      final page = (currentCount / pageSize).floor();
      return await album.getAssetListPaged(page: page, size: pageSize);
    } catch (e) {
      print('Error loading more assets: $e');
      return [];
    }
  }

  /// Request access to more photos (works for both iOS limited and Android partial access)
  Future<bool> requestMorePhotos() async {
    try {
      // Ensure we have current permission state
      await _updatePermissionState();

      if (!hasAnyAccess) {
        print('No permission to access photos');
        return false;
      }

      if (_permissionState == PermissionState.limited) {
        print('Handling limited/partial photo access...');

        // Store current count to detect changes
        final previousCount = _accessibleAssets.length;

        // For iOS: Use presentLimited
        // For Android 14+: This might open photo selection or request full access
        try {
          await PhotoManager.presentLimited();
        } catch (e) {
          print('presentLimited failed (might be Android): $e');
          // Fallback: try requesting permission again
          await requestPermission();
        }

        // Wait for user interaction to complete
        await Future.delayed(const Duration(milliseconds: 1000));

        // Refresh content
        await loadAccessibleContent();

        // Check if new photos were added or access changed
        final newCount = _accessibleAssets.length;
        final addedPhotos = newCount - previousCount;

        if (addedPhotos > 0) {
          print('Added $addedPhotos new photos');
          return true;
        } else if (_permissionState == PermissionState.authorized) {
          print('Permission upgraded to full access');
          return true;
        } else {
          print('No changes in photo access');
          return false;
        }
      } else if (_permissionState == PermissionState.authorized) {
        print('Already have full access to photos');
        await loadAccessibleContent(); // Refresh anyway
        return true;
      } else {
        print('Cannot request more photos with current permission state');
        return false;
      }
    } catch (e) {
      print('Error requesting more photos: $e');
      return false;
    }
  }

  /// Open system settings for photo permissions (alternative approach)
  Future<void> openAppSettings() async {
    try {
      return await PhotoManager.openSetting();
    } catch (e) {
      print('Error opening app settings: $e');
      return;
    }
  }

  /// Update permission state without full reload
  Future<void> _updatePermissionState() async {
    try {
      _permissionState = await PhotoManager.getPermissionState(
        requestOption: const PermissionRequestOption(),
      );
    } catch (e) {
      print('Error updating permission state: $e');
    }
  }

  /// Clear all data
  void _clearData() {
    _accessibleAssets = [];
    _albums = [];
  }

  /// Refresh all content
  Future<void> refresh() async {
    print('Refreshing gallery content...');
    await loadAccessibleContent();
  }

  /// Get total asset count for an album
  Future<int> getAlbumAssetCount(AssetPathEntity album) async {
    try {
      return await album.assetCountAsync;
    } catch (e) {
      print('Error getting album asset count: $e');
      return 0;
    }
  }

  /// Check if more assets are available for an album
  Future<bool> hasMoreAssets(AssetPathEntity album, int currentCount) async {
    final totalCount = await getAlbumAssetCount(album);
    return currentCount < totalCount;
  }

  /// Get permission status with user-friendly message
  String get permissionStatusMessage {
    switch (_permissionState) {
      case PermissionState.authorized:
        return 'Full access to photos';
      case PermissionState.limited:
        // Check if we're on Android with partial access
        if (_accessibleAssets.isNotEmpty) {
          return 'Partial access to photos (${_accessibleAssets.length} photos available)';
        }
        return 'Limited access to selected photos';
      case PermissionState.denied:
        return 'Photo access denied';
      case PermissionState.restricted:
        return 'Photo access restricted';
      case PermissionState.notDetermined:
        return 'Photo access not requested';
      default:
        return 'Unknown permission state';
    }
  }

  /// Check if we effectively have full access (works around Android 14+ reporting issues)
  bool get hasEffectiveFullAccess {
    if (_permissionState == PermissionState.authorized) return true;

    // On Android 14+, even with "limited" state, we might have access to many photos
    // Consider it "effective full access" if we have access to a significant number of photos
    if (_permissionState == PermissionState.limited &&
        _accessibleAssets.length > 100) {
      return true;
    }

    return false;
  }

  /// Dispose resources (call when service is no longer needed)
  void dispose() {
    _clearData();
  }
}
