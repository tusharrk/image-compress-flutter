import 'package:flutter/material.dart';

class SecondaryFullWidthContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const SecondaryFullWidthContainer({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius = 20,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget container = Container(
      width: double.infinity,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ??
            colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: container,
        ),
      );
    }

    return container;
  }
}
