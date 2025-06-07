import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

// Create a base class for tabbed views that works with any view model
abstract class StackedTabbedView<T extends BaseViewModel>
    extends StatefulWidget {
  const StackedTabbedView({Key? key}) : super(key: key);

  // Methods to override in subclasses
  Widget builder(BuildContext context, T viewModel, Widget? child);
  T viewModelBuilder(BuildContext context);
  void onViewModelReady(T viewModel, TickerProvider tickerProvider);

  @override
  _StackedTabbedViewState<T> createState() => _StackedTabbedViewState<T>();
}

class _StackedTabbedViewState<T extends BaseViewModel>
    extends State<StackedTabbedView<T>> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<T>.reactive(
      viewModelBuilder: () => widget.viewModelBuilder(context),
      onViewModelReady: (model) => widget.onViewModelReady(model, this),
      builder: (context, model, child) => widget.builder(context, model, child),
    );
  }
}
