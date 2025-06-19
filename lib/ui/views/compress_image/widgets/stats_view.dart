import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/utils/asset_utils.dart';
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
            title: AssetUtils().formatBytes(totalSizeAfter),
            subTitle: "from ${AssetUtils().formatBytes(totalSizeBefore)}",
            icon: Icons.insert_drive_file_outlined,
          ),
        ),
        const SizedBox(width: 8), // Add spacing between items
        Expanded(
          child: _buildStatItem(context,
              title: calculateCompressionPercentage(),
              subTitle: "smaller",
              icon: Icons.trending_down_rounded),
        ),
      ],
    );
  }

  String calculateCompressionPercentage() {
    if (totalSizeBefore == 0) return '0%';
    final percentage =
        ((totalSizeBefore - totalSizeAfter) / totalSizeBefore) * 100;
    return '${percentage.toStringAsFixed(1)}%';
  }

  Widget _buildStatItem(BuildContext context,
      {required String title,
      required String subTitle,
      required IconData icon}) {
    return SecondaryIconContainer(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 35,
          ),
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
