import 'dart:math';

import 'package:flutter_boilerplate/app/app.locator.dart';
import 'package:flutter_boilerplate/core/viewmodels/common_base_viewmodel.dart';
import 'package:flutter_boilerplate/services/gallery_service.dart'
    show GalleryService;
import 'package:photo_manager/photo_manager.dart';

class ListPhotosViewModel extends CommonBaseViewmodel {
  final _galleryService = locator<GalleryService>();

  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  late AssetPathEntity _currentAlbum;

  // Selection logic
  final Set<AssetEntity> _selectedPhotos = {};
  Set<AssetEntity> get selectedPhotos => _selectedPhotos;
  int get selectedCount => _selectedPhotos.length;
  bool isSelected(AssetEntity photo) => _selectedPhotos.contains(photo);

  List<AssetEntity> photos = [];

  int maxNumberOfAllowedSelectedPhotos = 0;

  Future<void> initialise(AssetPathEntity album) async {
    setBusy(true);
    maxNumberOfAllowedSelectedPhotos =
        maxNumberOfSelectedPhotos(); // Set the limit based on user type
    _currentAlbum = album;
    _currentPage = 0;
    _hasMore = true;
    try {
      await _galleryService.loadAccessibleContent();
      final albumAssets =
          await _galleryService.getAssetsFromAlbum(album, page: _currentPage);
      photos.clear();
      photos.addAll(albumAssets);
      _hasMore = albumAssets.length ==
          _galleryService
              .pageSize; // If less than  _galleryService.pageSize, no more pages
      notifyListeners();
    } catch (e) {
      logger.e('Error initializing gallery: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      _currentPage++;
      final newAssets = await _galleryService.getAssetsFromAlbum(_currentAlbum,
          page: _currentPage);
      if (newAssets.isNotEmpty) {
        photos.addAll(newAssets);
        _hasMore = newAssets.length == _galleryService.pageSize;
        notifyListeners();
      } else {
        _hasMore = false;
      }
    } catch (e) {
      logger.e('Error loading more photos: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void toggleSelection(AssetEntity photo) {
    if (_selectedPhotos.contains(photo)) {
      _selectedPhotos.remove(photo);
    } else {
      if (_selectedPhotos.length >= maxNumberOfAllowedSelectedPhotos) {
        logger.w(
            'Maximum selection limit reached: ${maxNumberOfSelectedPhotos()}');
        //open pro user dialog
        return; // Optionally show a message to the user
      } else {
        _selectedPhotos.add(photo);
      }
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedPhotos.clear();
    notifyListeners();
  }

  void selectPhoto(AssetEntity photo) {
    // Deprecated: use toggleSelection instead
    logger.i('Selected photo: ${photo.title}');
  }

  Future<String> getFileSize(AssetEntity asset) async {
    final file = await asset.originFile;
    if (file == null) return '';
    final bytes = await file.length();
    return formatBytes(bytes);
  }

  String formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(1024))
        .floor(); // bytes must be converted to double implicitly
    final size = bytes / pow(1024, i);
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  int maxNumberOfSelectedPhotos() {
    return isProUser() ? 10000 : 3; // Example limit, adjust based on your logic
  }
}
