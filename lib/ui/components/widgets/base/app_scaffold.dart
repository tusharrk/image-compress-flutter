import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool safeArea;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final Drawer? drawer;
  final Drawer? endDrawer;
  final void Function(bool)? onDrawerChanged;

  const AppScaffold({
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.safeArea = true,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.drawer,
    this.endDrawer,
    this.onDrawerChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: appBar,
      body: safeArea ? SafeArea(child: body) : body,
      backgroundColor: backgroundColor,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      drawer: drawer,
      endDrawer: endDrawer,
      onDrawerChanged: onDrawerChanged,
    );

    return GestureDetector(
        onTap: () {
          // This will dismiss the keyboard when tapping outside the TextField
          FocusScope.of(context).unfocus();
        },
        child: scaffold);
  }
}
