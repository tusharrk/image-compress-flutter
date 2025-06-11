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
    if (!viewModel.hasPermission) {
      return Center(
        child: ElevatedButton(
          onPressed: viewModel.requestPermission,
          child: const Text('Grant Photo Access'),
        ),
      );
    }

    if (viewModel.albums.isEmpty) {
      return const Center(
        child: Text('No albums available.'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: viewModel.albums.length,
      itemBuilder: (context, index) {
        final album = viewModel.albums[index];
        return GestureDetector(
          onTap: () => viewModel.showAlbumPhotos(album),
          child: Container(
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
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FutureBuilder<List<AssetEntity>>(
                    future: album.getAssetListPaged(page: 0, size: 1),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AssetEntityImage(
                            snapshot.data!.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        );
                      } else {
                        return const Icon(
                          Icons.photo_album,
                          size: 50,
                          color: Colors.grey,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  album.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                // FutureBuilder<int>(
                //   future: album.assetCountAsync,
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.done &&
                //         snapshot.hasData) {
                //       return Text(
                //         '${snapshot.data} photos',
                //         style: const TextStyle(
                //           fontSize: 12,
                //           color: Colors.black54,
                //         ),
                //       );
                //     } else {
                //       return const SizedBox.shrink();
                //     }
                //   },
                // ),
              ],
            ),
          ),
        );
      },
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
