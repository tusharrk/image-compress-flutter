import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:stacked/stacked.dart';

import 'list_photos_viewmodel.dart';

class ListPhotosView extends StackedView<ListPhotosViewModel> {
  const ListPhotosView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ListPhotosViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(viewModel)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(context, viewModel),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: viewModel.addMorePhotos,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Add Photos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  String _getTitle(ListPhotosViewModel viewModel) {
    if (viewModel.hasFullAccess) {
      return 'Gallery (${viewModel.accessibleAssets.length} photos)';
    } else if (viewModel.hasLimitedAccess) {
      return 'Selected Photos (${viewModel.accessibleAssets.length})';
    } else {
      return 'Gallery';
    }
  }

  Widget _buildBody(BuildContext context, ListPhotosViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading photos...'),
          ],
        ),
      );
    }

    if (!viewModel.hasPermission) {
      return _buildPermissionDenied(viewModel);
    }

    if (viewModel.accessibleAssets.isEmpty) {
      return _buildEmptyState(viewModel);
    }

    return Column(
      children: [
        // Show albums section only if user has full access
        if (viewModel.hasFullAccess && viewModel.albums.isNotEmpty)
          _buildAlbumsSection(viewModel),

        // Photos grid
        Expanded(
          child: _buildPhotosGrid(viewModel),
        ),
      ],
    );
  }

  Widget _buildPermissionDenied(ListPhotosViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Photo Access Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This app needs access to your photos to display them. You can choose to give full access or select specific photos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: viewModel.requestPermission,
              icon: const Icon(Icons.photo_library),
              label: const Text('Grant Access'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ListPhotosViewModel viewModel) {
    String message = viewModel.hasLimitedAccess
        ? 'No photos selected yet.\nTap "Add Photos" to select photos from your gallery.'
        : 'No photos found.\nTap "Add Photos" to select photos.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumsSection(ListPhotosViewModel viewModel) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Albums',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewModel.albums.length,
              itemBuilder: (context, index) {
                final album = viewModel.albums[index];
                return _buildAlbumCard(album, viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumCard(AssetPathEntity album, ListPhotosViewModel viewModel) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => viewModel.showAlbumPhotos(album),
        child: Column(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FutureBuilder<List<AssetEntity>>(
                future: album.getAssetListPaged(page: 0, size: 1),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AssetEntityImage(
                        snapshot.data!.first,
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70,
                      ),
                    );
                  }
                  return const Icon(
                    Icons.photo_album,
                    color: Colors.grey,
                    size: 32,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              album.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosGrid(ListPhotosViewModel viewModel) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: viewModel.accessibleAssets.length,
      itemBuilder: (context, index) {
        final asset = viewModel.accessibleAssets[index];
        return _buildPhotoTile(asset, viewModel);
      },
    );
  }

  Widget _buildPhotoTile(AssetEntity asset, ListPhotosViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.viewPhoto(asset),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AssetEntityImage(
            asset,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }

  @override
  ListPhotosViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ListPhotosViewModel();

  @override
  void onViewModelReady(ListPhotosViewModel viewModel) =>
      viewModel.initialise();
}
