import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool centerTitle;
  final bool showBack;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;

  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.centerTitle = true,
    this.showBack = false,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      systemOverlayStyle: _overlayStyleFor(
          backgroundColor ?? Theme.of(context).colorScheme.primary),
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: TextStyle(
                      color: foregroundColor ??
                          Theme.of(context).colorScheme.onPrimary),
                )
              : null),
      centerTitle: centerTitle,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed:
                  onBackPressed ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      foregroundColor:
          foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
      actions: actions,
      elevation: elevation ?? 0,
      bottom: bottom,
    );
  }

  SystemUiOverlayStyle _overlayStyleFor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    //print("Background color: $backgroundColor, luminance: $luminance");

    return luminance > 0.5
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
  }
}
