// widgets/settings_segmented_tile.dart
import 'package:flutter/cupertino.dart';

class SettingsSegmentedTile<T extends Object> extends StatelessWidget {
  final String title;
  final T value;
  final List<T> items;
  final EdgeInsetsGeometry padding;
  final ValueChanged<T> onChanged;
  final String Function(T) itemBuilder;

  const SettingsSegmentedTile({
    Key? key,
    required this.title,
    required this.value,
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    required this.onChanged,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (title.isNotEmpty) const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<T>(
              groupValue: value,
              onValueChanged: (T? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
              children: Map.fromEntries(
                items.map((item) => MapEntry(
                      item,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Text(
                          itemBuilder(item),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    )),
              ),
            ),
          ),
          // const SizedBox(height: 8),
        ],
      ),
    );
  }
}
