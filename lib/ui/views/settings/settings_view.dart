import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/models/export_format_enum.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_app_bar.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_scaffold.dart';
import 'package:flutter_boilerplate/ui/components/widgets/common/pro_feature_banner.dart';
import 'package:flutter_boilerplate/ui/components/widgets/custom_containers/primary_full_width_container.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_action_tile.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_card.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_divider.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_dropdown_tile.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_section_header.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_segmented_tile.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_switch_tile.dart';
import 'package:stacked/stacked.dart';

import 'settings_viewmodel.dart';

class SettingsView extends StackedView<SettingsViewModel> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    SettingsViewModel viewModel,
    Widget? child,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppScaffold(
      appBar: const AppAppBar(
        title: "Settings",
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            //Pro Banner
            if (!viewModel.isProUser())
              ModernProBadgeContainer(
                onTap: () {},
                child: ProFeatureBannerView(
                    colorScheme: colorScheme, theme: theme),
              ),
            const SizedBox(height: 24),

            // Compression Settings Section
            const SettingsSectionHeader(title: "Compression Settings"),
            SettingsCard(
              children: [
                // SettingsSliderTile(
                //   title: "Default Photo Quality",
                //   subtitle: "${(viewModel.compressionQuality * 100).round()}%",
                //   value: viewModel.compressionQuality,
                //   onChanged: viewModel.updateCompressionQuality,
                //   min: 0.05,
                //   max: 1.0,
                // ),
                SettingsSegmentedTile<SimpleImageQuality>(
                  title: "Default Photo Quality",
                  value: viewModel.selectedImageQuality,
                  items: viewModel.simpleImageQualityList,
                  onChanged: viewModel.updateSimpleImageQuality,
                  itemBuilder: (format) => format.displayName,
                ),
                Text(
                  viewModel.selectedImageQualityDescription,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SettingsDivider(),
                SettingsSegmentedTile<ExportFormat>(
                  title: "Default Image Format",
                  value: viewModel.defaultImageFormat,
                  items: viewModel.imageFormats,
                  onChanged: viewModel.updateImageFormat,
                  itemBuilder: (format) => format.displayName,
                ),
                // SettingsDropdownTile<ImageFormat>(
                //   title: "Default Image Format",
                //   value: viewModel.defaultImageFormat,
                //   items: viewModel.imageFormats,
                //   onChanged: viewModel.updateImageFormat,
                //   itemBuilder: (format) => format.displayName,
                // ),
                const SettingsDivider(),
                SettingsSwitchTile(
                  title: "Keep Image Metadata by Default",
                  subtitle: "Enable to retain EXIF data in compressed images",
                  value: viewModel.keepMetadata,
                  onChanged: viewModel.toggleKeepMetadata,
                ),

                const SettingsDivider(),
                SettingsSwitchTile(
                  title: "Keep Location Data by Default",
                  subtitle:
                      "Enable to retain GPS Location coordinates in compressed images",
                  value: viewModel.keepLocation,
                  onChanged: viewModel.toggleKeepLocation,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Appearance Section
            const SettingsSectionHeader(title: "Appearance"),
            SettingsCard(
              children: [
                SettingsSegmentedTile<ThemeMode>(
                  title: "Theme Mode",
                  value: viewModel.themeMode,
                  items: viewModel.themeModes,
                  onChanged: viewModel.updateThemeMode,
                  itemBuilder: (mode) => mode.displayName,
                ),
                // SettingsDropdownTile<ThemeMode>(
                //   title: "Theme Mode",
                //   value: viewModel.themeMode,
                //   items: viewModel.themeModes,
                //   onChanged: viewModel.updateThemeMode,
                //   itemBuilder: (mode) => mode.displayName,
                // ),
                const SettingsDivider(),
                SettingsDropdownTile<String>(
                  title: "Language",
                  value: viewModel.selectedLanguage,
                  items: viewModel.availableLanguages,
                  onChanged: viewModel.updateLanguage,
                  itemBuilder: (lang) => viewModel.getLanguageDisplayName(lang),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notifications Section
            const SettingsSectionHeader(title: "Notifications"),
            SettingsCard(
              children: [
                SettingsSwitchTile(
                  title: "Compression Notifications",
                  subtitle: "Show notifications when compression is complete",
                  value: viewModel.notificationsEnabled,
                  onChanged: viewModel.toggleNotifications,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Storage Section
            // _const SettingsSectionHeader(title:"Storage"),
            // SettingsCard(
            //   children: [
            //     SettingsActionTile(
            //       title: "Clear Cache",
            //       subtitle: viewModel.cacheSize,
            //       trailing: viewModel.isClearingCache
            //           ? const SizedBox(
            //               width: 20,
            //               height: 20,
            //               child: CircularProgressIndicator(strokeWidth: 2),
            //             )
            //           : null,
            //       onTap: viewModel.clearCache,
            //     ),
            //   ],
            // ),

            //     const SizedBox(height: 24),

            // About Section
            const SettingsSectionHeader(title: "About"),
            SettingsCard(
              children: [
                SettingsActionTile(
                  title: "App Version",
                  subtitle: viewModel.appVersion,
                  onTap: null,
                ),
                const SettingsDivider(),
                SettingsActionTile(
                  title: "Privacy Policy",
                  trailing: const Icon(Icons.open_in_new, size: 20),
                  onTap: viewModel.openPrivacyPolicy,
                ),
                const SettingsDivider(),
                SettingsActionTile(
                  title: "Terms & Conditions",
                  trailing: const Icon(Icons.open_in_new, size: 20),
                  onTap: viewModel.openTermsAndConditions,
                ),
                const SettingsDivider(),
                SettingsActionTile(
                  title: "Rate App",
                  subtitle: "Help us improve by leaving a review",
                  trailing: const Icon(Icons.star_outline, size: 20),
                  onTap: viewModel.rateApp,
                ),
                const SettingsDivider(),
                SettingsActionTile(
                  title: "Tell a Friend",
                  subtitle: "Share the app with your friends",
                  trailing: const Icon(Icons.share_outlined, size: 20),
                  onTap: viewModel.shareApp,
                ),
                const SettingsDivider(),
                SettingsActionTile(
                  title: "About Developer",
                  trailing: const Icon(Icons.info_outline, size: 20),
                  onTap: viewModel.showAboutDeveloper,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SettingsSectionHeader(title: "Our other Apps"),
            SettingsCard(children: [
              SettingsActionTile(
                title: "GPS Map Camera",
                trailing: const Icon(Icons.camera_alt_outlined, size: 20),
                onTap: viewModel.rateApp,
              ),
              SettingsActionTile(
                title: "Rate App",
                subtitle: "Help us improve by leaving a review",
                trailing: const Icon(Icons.camera_alt_outlined, size: 20),
                onTap: viewModel.rateApp,
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  SettingsViewModel viewModelBuilder(BuildContext context) =>
      SettingsViewModel();

  @override
  void onViewModelReady(SettingsViewModel viewModel) => viewModel.initialise();
}
