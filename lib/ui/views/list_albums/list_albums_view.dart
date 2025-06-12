import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_app_bar.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_scaffold.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:stacked/stacked.dart';

import 'list_albums_viewmodel.dart';

class ListAlbumsView extends StackedView<ListAlbumsViewModel> {
  const ListAlbumsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ListAlbumsViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      appBar: AppAppBar(
        title: "Photo Albums",
        showBack: true,
        actions: [
          if (viewModel.isAdBtnVisible())
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: viewModel.addMorePhotos,
              tooltip: 'Add photos',
            ),
        ],
      ),
      body: _buildBody(context, viewModel),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: viewModel.addMorePhotos,
      //   icon: const Icon(Icons.add_photo_alternate),
      //   label: const Text('Add Photos'),
      //   backgroundColor: Colors.blue,
      //   foregroundColor: Colors.white,
      // ),
    );
  }

  Widget _buildBody(BuildContext context, ListAlbumsViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }
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
      cacheExtent: 1000, // Keep more items in memory
      addAutomaticKeepAlives: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio:
            0.8, // Add this - makes items taller (width/height ratio)
      ),
      itemCount: viewModel.albums.length,
      itemBuilder: (context, index) {
        final album = viewModel.albums[index];
        return GestureDetector(
          onTap: () => viewModel.showAlbumPhotos(album),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageSize =
                  constraints.maxWidth * 0.85; // Slightly smaller image
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FutureBuilder<List<AssetEntity>>(
                        future: album.getAssetListPaged(page: 0, size: 1),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            return AssetEntityImage(
                              snapshot.data!.first,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              isOriginal:
                                  false, // Use thumbnail for better performance
                              thumbnailSize: const ThumbnailSize.square(200),
                            );
                          } else {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.photo_album,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    // Allow text to take remaining space
                    child: Text(
                      album.name,
                      style: const TextStyle(
                        fontSize: 12, // Slightly smaller font
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2, // Allow 2 lines for longer names
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Expanded(
                  //   child: FutureBuilder<int>(
                  //     future: album.assetCountAsync,
                  //     builder: (context, snapshot) {
                  //       if (snapshot.connectionState == ConnectionState.done &&
                  //           snapshot.hasData) {
                  //         return Text(
                  //           '${snapshot.data} photos',
                  //           style: const TextStyle(
                  //             fontSize: 10, // Smaller font for count
                  //             color: Colors.black54,
                  //           ),
                  //         );
                  //       } else {
                  //         return const SizedBox.shrink();
                  //       }
                  //     },
                  //   ),
                  // ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  ListAlbumsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ListAlbumsViewModel();

  @override
  void onViewModelReady(ListAlbumsViewModel viewModel) =>
      viewModel.initialise();
}
