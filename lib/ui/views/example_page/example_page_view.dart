import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/common_imports/ui_imports.dart';
import 'package:flutter_boilerplate/gen/asset/assets.gen.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_app_bar.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_button.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_scaffold.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_text_field.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/stacked_tabbed_view.dart';
import 'package:flutter_boilerplate/ui/components/widgets/custom_image/custom_network_image.dart';

import 'example_page_viewmodel.dart';

class ExamplePageView extends StackedTabbedView<ExamplePageViewModel> {
  const ExamplePageView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ExamplePageViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      appBar: AppAppBar(
        title: 'home.title'.tr(),
        showBack: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                viewModel.changeLocale(context);
              }),
        ],
        bottom: TabBar(
          controller: viewModel.tabController,
          tabs: [
            Tab(text: 'Tab 1'.tr()),
            Tab(text: 'Tab 2'.tr()),
            Tab(text: 'Tab 3'.tr()),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  verticalSpaceLarge,
                  Column(
                    children: [
                      Text(
                        'home.title'.tr(),
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Assets.images.thumbnailLogo.image(),
                      AppTextField(
                        label: 'Email',
                        hintText: 'you@example.com',
                        controller: viewModel.emailController,
                        validator: viewModel.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        isFilled: false,
                      ),
                      verticalSpaceMedium,
                      AppButton(
                        label: 'Login',
                        onPressed: () => print('Logging in...'),
                        isBusy: false,
                        icon: const Icon(Icons.login),
                        size: AppButtonSize.medium,
                        fullWidth: true,
                      ),
                      OutlinedButton(
                          onPressed: () {}, child: const Text("adasdas")),
                      verticalSpaceMedium,
                      MaterialButton(
                        onPressed: viewModel.incrementCounter,
                        child: Text(
                          viewModel.counterLabel,
                          style: const TextStyle(),
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: viewModel.isDarkMode,
                    onChanged: (value) {
                      viewModel.changeDarkMode(value);
                    },
                  ),
                  const CustomNetworkImage(
                    imageUrl: 'https://picsum.photos/id/1/140/200',
                    emptyWidget: Icon(Icons.error),
                    boxFit: BoxFit.cover,
                    size: Size(50, 80),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MaterialButton(
                        color: kcDarkGreyColor,
                        onPressed: viewModel.showDialog,
                        child: const Text(
                          'Show Dialog',
                          style: TextStyle(),
                        ),
                      ),
                      MaterialButton(
                        color: kcDarkGreyColor,
                        onPressed: viewModel.showBottomSheet,
                        child: const Text(
                          'Show Bottom Sheet',
                          style: TextStyle(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  ExamplePageViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ExamplePageViewModel();

  @override
  void onViewModelReady(
          ExamplePageViewModel viewModel, TickerProvider tickerProvider) =>
      viewModel.initializeTabController(tickerProvider);
}
