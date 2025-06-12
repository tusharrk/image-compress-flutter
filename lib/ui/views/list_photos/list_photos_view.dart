import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_app_bar.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_scaffold.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:stacked/stacked.dart';

import 'list_photos_viewmodel.dart';

class ListPhotosView extends StackedView<ListPhotosViewModel> {
  final AssetPathEntity album;
  const ListPhotosView({Key? key, required this.album}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ListPhotosViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      appBar: const AppAppBar(
        title: "Select Images",
        showBack: true,
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

  Widget _buildBody(BuildContext context, ListPhotosViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.photos.isEmpty) {
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
      itemCount: viewModel.photos.length,
      itemBuilder: (context, index) {
        final photo = viewModel.photos[index];
        return GestureDetector(
          onTap: () => viewModel.selectPhoto(photo),
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
                      child: AssetEntityImage(
                        photo,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        isOriginal:
                            false, // Use thumbnail for better performance
                        thumbnailSize: const ThumbnailSize.square(200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                      // Allow text to take remaining space

                      child: FutureBuilder<String>(
                    future: viewModel.getFileSize(photo),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? '',
                        style: const TextStyle(
                          fontSize: 12, // Slightly smaller font
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2, // Allow 2 lines for longer names
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      );
                    },
                  )),
                ],
              );
            },
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
      viewModel.initialise(album);
}
