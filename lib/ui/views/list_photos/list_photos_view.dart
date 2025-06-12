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
      appBar: AppAppBar(
        title: viewModel.selectedCount > 0
            ? "Selected (${viewModel.selectedCount})"
            : "Select Images",
        showBack: true,
        actions: [
          TextButton(
            onPressed: viewModel.selectedCount > 0
                ? () {
                    // TODO: Handle next action
                  }
                : null,
            child: Text(
              "Next",
              style: TextStyle(
                  fontSize: 16,
                  color: viewModel.selectedCount > 0
                      ? Colors.white
                      : Colors.white.withOpacity(0.30)),
            ),
          ),
        ],
      ),
      body: _PaginatedPhotoGrid(viewModel: viewModel),
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

// Add a new widget for paginated grid
class _PaginatedPhotoGrid extends StatefulWidget {
  final ListPhotosViewModel viewModel;
  const _PaginatedPhotoGrid({required this.viewModel});

  @override
  State<_PaginatedPhotoGrid> createState() => _PaginatedPhotoGridState();
}

class _PaginatedPhotoGridState extends State<_PaginatedPhotoGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (widget.viewModel.hasMore && !widget.viewModel.isLoadingMore) {
        widget.viewModel.loadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    if (viewModel.isBusy && viewModel.photos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.photos.isEmpty) {
      return const Center(child: Text('No albums available.'));
    }
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            cacheExtent: 1000,
            addAutomaticKeepAlives: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount:
                viewModel.photos.length + (viewModel.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == viewModel.photos.length && viewModel.isLoadingMore) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final photo = viewModel.photos[index];
              final isSelected = viewModel.isSelected(photo);
              return GestureDetector(
                onTap: () => setState(() => viewModel.toggleSelection(photo)),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final imageSize = constraints.maxWidth * 0.85;
                    return Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
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
                                      isOriginal: false,
                                      thumbnailSize:
                                          const ThumbnailSize.square(200),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    bottom: 6,
                                    right: 6,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.15),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(1),
                                      child: const CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.blue,
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: FutureBuilder<String>(
                                future: viewModel.getFileSize(photo),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
