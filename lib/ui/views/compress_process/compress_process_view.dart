import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'compress_process_viewmodel.dart';

class CompressProcessView extends StackedView<CompressProcessViewModel> {
  const CompressProcessView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CompressProcessViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
}
