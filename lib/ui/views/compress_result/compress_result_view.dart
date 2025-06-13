import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'compress_result_viewmodel.dart';

class CompressResultView extends StackedView<CompressResultViewModel> {
  const CompressResultView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CompressResultViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("CompressResultView")),
      ),
    );
  }

  @override
  CompressResultViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CompressResultViewModel();
}
