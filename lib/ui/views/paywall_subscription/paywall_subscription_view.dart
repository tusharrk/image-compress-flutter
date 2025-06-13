import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'paywall_subscription_viewmodel.dart';

class PaywallSubscriptionView
    extends StackedView<PaywallSubscriptionViewModel> {
  const PaywallSubscriptionView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PaywallSubscriptionViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("PaywallSubscriptionView")),
      ),
    );
  }

  @override
  PaywallSubscriptionViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PaywallSubscriptionViewModel();
}
