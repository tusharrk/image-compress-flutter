import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_app_bar.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_scaffold.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_action_tile.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_card.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_divider.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_dropdown_tile.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_segmented_tile.dart';
import 'package:flutter_boilerplate/ui/views/settings/widgets/settings_slider_tile.dart';
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
    return AppScaffold(
      appBar: const AppAppBar(
        title: "Settings",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Compression Settings Section
            _buildSectionHeader("Compression Settings"),
            SettingsCard(
              children: [
                SettingsSliderTile(
                  title: "Default Compression Quality",
                  subtitle: "${(viewModel.compressionQuality * 100).round()}%",
                  value: viewModel.compressionQuality,
                  onChanged: viewModel.updateCompressionQuality,
                  min: 0.05,
                  max: 1.0,
                ),
                const SettingsDivider(),
                SettingsSegmentedTile<ImageFormat>(
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
                  title: "Remove Image Metadata by Default",
                  subtitle: "Strip EXIF data from compressed images",
                  value: viewModel.removeMetadata,
                  onChanged: viewModel.toggleRemoveMetadata,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Appearance Section
            _buildSectionHeader("Appearance"),
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
            _buildSectionHeader("Notifications"),
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
            // _buildSectionHeader("Storage"),
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
            _buildSectionHeader("About"),
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
                  title: "About Developer",
                  trailing: const Icon(Icons.info_outline, size: 20),
                  onTap: viewModel.showAboutDeveloper,
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
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
