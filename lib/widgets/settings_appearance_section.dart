import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../providers/inventory_provider.dart';
import 'settings_common.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';

/// Theme and language choices (per-device, not synced to the server).
class SettingsAppearanceSection extends StatelessWidget {
  final InventoryProvider provider;

  const SettingsAppearanceSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(l10n.settingsAppearanceHeader),
        const SizedBox(height: 8),
        buildCardContainer([
          buildPreferenceTile(
            icon: Icons.brightness_6_outlined,
            iconColor: AppTones.lilac,
            iconBg: context.colors.infoSoft,
            title: l10n.settingsTheme,
            subtitle: l10n.settingsThemeSubtitle,
            valueText: switch (provider.themeMode) {
              ThemeMode.system => l10n.themeSystem,
              ThemeMode.light => l10n.themeLight,
              ThemeMode.dark => l10n.themeDark,
            },
            onTap: () => _pickTheme(context),
          ),
          const Divider(height: 1),
          buildPreferenceTile(
            icon: Icons.language_rounded,
            iconColor: AppTones.sky,
            iconBg: AppTones.skySoft,
            title: l10n.settingsLanguage,
            subtitle: l10n.settingsLanguageSubtitle,
            valueText: switch (provider.locale?.languageCode) {
              'en' => 'English',
              'vi' => 'Tiếng Việt',
              _ => l10n.languageSystem,
            },
            onTap: () => _pickLanguage(context),
          ),
        ]),
      ],
    );
  }

  Future<void> _pickTheme(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final choice = await _showChoices<ThemeMode>(
      context,
      title: l10n.settingsTheme,
      current: provider.themeMode,
      options: {
        ThemeMode.system: l10n.themeSystem,
        ThemeMode.light: l10n.themeLight,
        ThemeMode.dark: l10n.themeDark,
      },
    );
    if (choice != null) provider.setThemeMode(choice);
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final choice = await _showChoices<String>(
      context,
      title: l10n.settingsLanguage,
      current: provider.locale?.languageCode ?? 'system',
      options: {
        'system': l10n.languageSystem,
        'en': 'English',
        'vi': 'Tiếng Việt',
      },
    );
    if (choice != null) provider.setLocale(choice == 'system' ? null : choice);
  }

  Future<T?> _showChoices<T>(
    BuildContext context, {
    required String title,
    required T current,
    required Map<T, String> options,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            for (final entry in options.entries)
              ListTile(
                title: Text(entry.value),
                trailing: entry.key == current
                    ? const AppIcon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(ctx, entry.key),
              ),
          ],
        ),
      ),
    );
  }
}
