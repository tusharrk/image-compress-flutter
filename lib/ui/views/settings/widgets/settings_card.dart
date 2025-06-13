// widgets/settings_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/ui/components/widgets/custom_containers/secondary_full_width_container.dart';

class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SecondaryFullWidthContainer(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
      child: Column(
        children: children,
      ),
    );
    // return Card(
    //   elevation: 0,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(12),
    //     side: BorderSide(
    //       color: Theme.of(context).dividerColor.withOpacity(0.1),
    //     ),
    //   ),
    //   child: Column(
    //     children: children,
    //   ),
    // );
  }
}
