import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/ui/components/widgets/custom_containers/secondary_icon_container.dart';

class StatsView extends StatelessWidget {
  final int totalImages;
  final int compressedImages;
  final int totalSizeBefore;
  final int totalSizeAfter;

  const StatsView({
    Key? key,
    required this.totalImages,
    required this.compressedImages,
    required this.totalSizeBefore,
    required this.totalSizeAfter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            title: '7 MB',
            subTitle: "from 12 MB",
          ),
        ),
        const SizedBox(width: 8), // Add spacing between items
        Expanded(
          child: _buildStatItem(
            context,
            title: '46%',
            subTitle: "smaller",
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context,
      {required String title, required String subTitle}) {
    return SecondaryIconContainer(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Icon(Icons.image, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            // This Expanded is now properly constrained
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  subTitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
