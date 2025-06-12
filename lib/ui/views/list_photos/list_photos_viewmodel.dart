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

  @override
  List<AssetEntity> get photos => _galleryService.accessibleAssets;

  Future<void> initialise(AssetPathEntity album) async {
    setBusy(true);
    _currentAlbum = album;
    _currentPage = 0;
    _hasMore = true;
    try {
      await _galleryService.loadAccessibleContent();
      final albumAssets =
          await _galleryService.getAssetsFromAlbum(album, page: _currentPage);
      photos.clear();
      photos.addAll(albumAssets);
      _hasMore = albumAssets.length == 500; // If less than 500, no more pages
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
        _hasMore = newAssets.length == 500;
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

  void selectPhoto(AssetEntity photo) {
    // Handle photo selection logic here
    // For example, navigate to a detail view or perform an action
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
}
