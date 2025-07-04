import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/models/compression_settings.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stacked/stacked.dart';

import 'compress_process_viewmodel.dart';

class CompressProcessView extends StackedView<CompressProcessViewModel> {
  final List<AssetEntity> photosList;
  final PhotoCompressSettings compressSettings;
  const CompressProcessView(
      {Key? key, required this.photosList, required this.compressSettings})
      : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CompressProcessViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("CompressProcessView")),
      ),
    );
  }

  @override
  CompressProcessViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CompressProcessViewModel();

  @override
  void onViewModelReady(CompressProcessViewModel viewModel) =>
      viewModel.initialise(photosList, compressSettings);
}
