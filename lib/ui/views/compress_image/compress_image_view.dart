import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_app_bar.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_scaffold.dart';
import 'package:flutter_boilerplate/ui/components/widgets/custom_containers/secondary_full_width_container.dart';
import 'package:flutter_boilerplate/ui/views/compress_image/widgets/image_list.dart';
import 'package:flutter_boilerplate/ui/views/compress_image/widgets/stats_view.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stacked/stacked.dart';

import 'compress_image_viewmodel.dart';

class CompressImageView extends StackedView<CompressImageViewModel> {
  final List<AssetEntity> photosList;
  const CompressImageView({Key? key, required this.photosList})
      : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CompressImageViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      appBar: const AppAppBar(
        title: "Compression Settings",
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            SecondaryFullWidthContainer(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  ThumbNailImageList(
                      viewModel: viewModel, photosList: photosList)
                ],
              ),
            ),
            const SizedBox(height: 24),
            StatsView(
              totalImages: photosList.length,
              compressedImages: 0, // Placeholder for actual count
              totalSizeBefore: 12000000, // Placeholder for actual size in bytes
              totalSizeAfter: 7000000, // Placeholder for actual size in bytes
            ),
          ],
        ),
      ),
    );
  }

  @override
  CompressImageViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CompressImageViewModel();

  @override
  void onViewModelReady(CompressImageViewModel viewModel) =>
      viewModel.initialise(photosList);
}
