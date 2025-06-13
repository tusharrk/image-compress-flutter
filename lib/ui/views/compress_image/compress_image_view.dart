import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'compress_image_viewmodel.dart';

class CompressImageView extends StackedView<CompressImageViewModel> {
  const CompressImageView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CompressImageViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("CompressImageView")),
      ),
    );
  }

  @override
  CompressImageViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CompressImageViewModel();
}
