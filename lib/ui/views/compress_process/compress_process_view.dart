import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/models/compression_settings.dart';
import 'package:flutter_boilerplate/core/utils/asset_utils.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_app_bar.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_scaffold.dart';
import 'package:flutter_boilerplate/ui/components/widgets/custom_containers/secondary_full_width_container.dart';
import 'package:flutter_boilerplate/ui/components/widgets/custom_containers/secondary_icon_container.dart';
import 'package:flutter_boilerplate/ui/views/compress_image/widgets/image_list.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_divider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stacked/stacked.dart';

import 'compress_process_viewmodel.dart';

class CompressProcessView extends StackedView<CompressProcessViewModel> {
  final List<AssetEntity> photosList;
  final PhotoCompressSettings compressSettings;
  const CompressProcessView(
      {Key? key, required this.photosList, required this.compressSettings})
      : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CompressProcessViewModel viewModel,
    Widget? child,
  ) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight =
        AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - appBarHeight;

    return AppScaffold(
      appBar: const AppAppBar(
        title: "Compressing Images",
        showBack: true,
      ),
      body: Container(
        height: availableHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Image List Section
              //only visible during progress
              if (viewModel.processError == null &&
                  viewModel.isSuccess == false)
                SecondaryFullWidthContainer(
                  padding: const EdgeInsets.all(12.0),
                  child: ThumbNailImageList(
                    viewModel: null,
                    photosList: photosList,
                  ),
                ),
              const SizedBox(height: 32),

              // Main Content Area - Takes remaining space
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  child: _buildMainContent(context, viewModel, theme),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context,
      CompressProcessViewModel viewModel, ThemeData theme) {
    if (viewModel.processError != null) {
      return _buildErrorState(context, viewModel, theme);
    } else if (viewModel.isSuccess) {
      return _buildSuccessState(context, viewModel, theme);
    } else {
      return _buildProgressState(context, viewModel, theme);
    }
  }

  Widget _buildErrorState(BuildContext context,
      CompressProcessViewModel viewModel, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 64,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Oops! Something went wrong',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            viewModel.processError!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: viewModel.retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context,
      CompressProcessViewModel viewModel, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 80,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          'Compression Complete!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${photosList.length} images compressed successfully',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Compression Statistics
        SecondaryFullWidthContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Compression Statistics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCompressionStat(
                    theme,
                    Icons.folder_outlined,
                    'Before',
                    AssetUtils()
                        .formatBytes(viewModel.beforeCompressionSize ?? 0),
                    theme.colorScheme.onSurface,
                  ),
                  _buildCompressionStat(
                    theme,
                    Icons.folder_zip_outlined,
                    'After',
                    AssetUtils()
                        .formatBytes(viewModel.afterCompressionSize ?? 0),
                    theme.colorScheme.onSurface,
                  ),
                  _buildCompressionStat(
                    theme,
                    Icons.trending_down,
                    'Saved',
                    AssetUtils().formatBytes(viewModel.savedSize ?? 0),
                    theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              viewModel.navigateToHome();
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Start New Compression'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompressionStat(
      ThemeData theme, IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressState(BuildContext context,
      CompressProcessViewModel viewModel, ThemeData theme) {
    final progress =
        viewModel.total > 0 ? viewModel.currentIndex / viewModel.total : 0.0;
    final progressPercentage = (progress * 100).toInt();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circular Progress Indicator
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 500),
          builder: (context, animatedProgress, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: animatedProgress,
                    strokeWidth: 12,
                    backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$progressPercentage%',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Complete',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 48),

        // Progress Info
        SecondaryFullWidthContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Processing Images',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Image ${viewModel.currentIndex} of ${viewModel.total}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              if (viewModel.currentName.isNotEmpty) ...[
                const SizedBox(height: 4),
                const SettingsDivider(),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    viewModel.currentName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),

        const Spacer(),

        // Progress Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              theme,
              Icons.image_outlined,
              'Images',
              '${viewModel.total}',
            ),
            _buildStatItem(
              theme,
              Icons.done_outline,
              'Completed',
              '${viewModel.currentIndex}',
            ),
            _buildStatItem(
              theme,
              Icons.pending_outlined,
              'Remaining',
              '${viewModel.total - viewModel.currentIndex}',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
      ThemeData theme, IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(0),
          child: SecondaryIconContainer(
            child: IconButton(
              icon: Icon(
                icon,
                color: theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              onPressed: () {},
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  @override
  CompressProcessViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CompressProcessViewModel();

  @override
  void onViewModelReady(CompressProcessViewModel viewModel) =>
      viewModel.initialise(photosList, compressSettings);
}
