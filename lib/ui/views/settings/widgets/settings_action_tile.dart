// widgets/settings_action_tile.dart
import 'package:flutter/material.dart';

class SettingsActionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsActionTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(fontSize: 14),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      enabled: onTap != null,
    );
  }
}
