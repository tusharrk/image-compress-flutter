import 'package:flutter/material.dart';

enum AppButtonType { elevated, outlined, text }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;
  final bool isEnabled;
  final bool fullWidth;
  final Widget? icon;
  final AppButtonType type;
  final AppButtonSize size;
  final ButtonStyle? customStyle;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isBusy = false,
    this.isEnabled = true,
    this.fullWidth = true,
    this.icon,
    this.type = AppButtonType.elevated,
    this.size = AppButtonSize.medium,
    this.customStyle,
  });

  double getButtonHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.large:
        return 56;
      case AppButtonSize.medium:
        return 48;
    }
  }

  ButtonStyle getDefaultStyle(BuildContext context) {
    final height = getButtonHeight();

    final style = ButtonStyle(
      minimumSize: WidgetStateProperty.all(Size.fromHeight(height)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    return style;
  }

  Widget _buildChild() {
    if (isBusy) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    return row;
  }

  @override
  Widget build(BuildContext context) {
    final child = _buildChild();
    final style = customStyle ?? getDefaultStyle(context);

    final bool shouldDisable = !isEnabled || isBusy;

    final Widget button;
    switch (type) {
      case AppButtonType.outlined:
        button = OutlinedButton(
          onPressed: shouldDisable ? null : onPressed,
          style: style,
          child: child,
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          onPressed: shouldDisable ? null : onPressed,
          style: style,
          child: child,
        );
        break;
      case AppButtonType.elevated:
        button = ElevatedButton(
          onPressed: shouldDisable ? null : onPressed,
          style: style,
          child: child,
        );
        break;
    }

    return fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: IntrinsicWidth(child: button),
            ));
  }
}
