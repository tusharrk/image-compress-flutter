import 'package:flutter/material.dart';
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("ListPhotosView")),
      ),
    );
  }

  @override
  ListPhotosViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ListPhotosViewModel();
}
