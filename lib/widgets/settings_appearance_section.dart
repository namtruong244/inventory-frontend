import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../providers/inventory_provider.dart';
import 'settings_common.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'soft_sheet.dart';

/// Theme and language choices (per-device, not synced to the server).
class SettingsAppearanceSection extends StatelessWidget {
  final InventoryProvider provider;

  const SettingsAppearanceSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsGroup(
      label: l10n.settingsAppearanceHeader,
      children: [
        e2eId(
          'settings_theme',
          SettingsRow(
            icon: Icons.brightness_6_outlined,
            label: l10n.settingsTheme,
            value: switch (provider.themeMode) {
              ThemeMode.system => l10n.themeSystem,
              ThemeMode.light => l10n.themeLight,
              ThemeMode.dark => l10n.themeDark,
            },
            onTap: () => _pickTheme(context),
          ),
        ),
        e2eId(
          'settings_language',
          SettingsRow(
            icon: Icons.language_rounded,
            label: l10n.settingsLanguage,
            value: switch (provider.locale?.languageCode) {
              'en' => 'English',
              'vi' => 'Tiếng Việt',
              _ => l10n.languageSystem,
            },
            onTap: () => _pickLanguage(context),
          ),
        ),
      ],
    );
  }

  Future<void> _pickTheme(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final choice = await _showChoices<ThemeMode>(
      context,
      title: l10n.settingsTheme,
      current: provider.themeMode,
      idFor: (m) => 'settings_theme_${m.name}',
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
      idFor: (code) => 'settings_language_$code',
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
    required String Function(T) idFor,
  }) {
    return showSoftSheet<T>(
      context,
      title: title,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in options.entries)
            e2eId(
              idFor(entry.key),
              SettingsRow(
                icon: entry.key == current
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                label: entry.value,
                showChevron: false,
                iconColor: entry.key == current ? ctx.colors.onAccent : null,
                iconBackground: entry.key == current ? ctx.colors.accent : null,
                onTap: () => Navigator.pop(ctx, entry.key),
              ),
            ),
        ],
      ),
    );
  }
}
