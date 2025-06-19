import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_app_bar.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_scaffold.dart';
import 'package:flutter_boilerplate/ui/components/widgets/custom_containers/secondary_full_width_container.dart';
import 'package:flutter_boilerplate/ui/views/compress_image/widgets/image_list.dart';
import 'package:flutter_boilerplate/ui/views/compress_image/widgets/stats_view.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_card.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_divider.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_segmented_tile.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_slider_tile.dart';
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
            const SizedBox(height: 16),
            const SettingsDivider(),
            const SizedBox(height: 16),
            SettingsSegmentedTile<CompressSettingsType>(
              title: "",
              value: viewModel.defaultCompressSettingType,
              items: viewModel.compressSettingTypeList,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              onChanged: viewModel.updateCompressOptionType,
              itemBuilder: (format) => format.displayName,
            ),
            const SizedBox(height: 16),
            if (viewModel.defaultCompressSettingType ==
                CompressSettingsType.simple) ...[
              _simpleOptionsView(viewModel),
            ] else ...[
              _advancedOptionsView(viewModel),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _simpleOptionsView(
    CompressImageViewModel viewModel,
  ) {
    return SettingsCard(
      children: [
        SettingsSliderTile(
          title: "Photo Quality",
          subtitle: "${(viewModel.photoQuality * 100).round()}%",
          value: viewModel.photoQuality,
          onChanged: viewModel.updatePhotoQuality,
          min: 0.05,
          max: 1.0,
        ),
        const SettingsDivider(),
        SettingsSliderTile(
          title: "Photo Dimension: 1024x7681",
          subtitle: "${(viewModel.photoDimensions * 100).round()}%",
          value: viewModel.photoDimensions,
          onChanged: viewModel.updatePhotoDimension,
          min: 0.05,
          max: 1.0,
        ),
      ],
    );
  }

  Widget _advancedOptionsView(
    CompressImageViewModel viewModel,
  ) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add advanced options widgets here
        Text("Advanced Options Selected"),
      ],
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
