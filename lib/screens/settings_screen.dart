import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_icon.dart';
import '../widgets/export_barcodes_sheet.dart';
import '../widgets/failed_ops_tile.dart';
import '../widgets/settings_account_dialogs.dart';
import '../widgets/settings_appearance_section.dart';
import '../widgets/settings_backend_section.dart';
import '../widgets/settings_common.dart';
import '../widgets/settings_pickers.dart';
import '../widgets/settings_profile_card.dart';
import '../widgets/settings_profile_sheets.dart';
import '../widgets/settings_report_sheets.dart';
import '../widgets/sync_status_sheet.dart';
import '../widgets/tappable.dart';
import 'dev_component_gallery_screen.dart';
import 'trash_screen.dart';

class SettingsScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const SettingsScreen({super.key, this.scrollController});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _versionTapCount = 0;
  bool _developerModeUnlocked = false;

  void _handleVersionTap() {
    setState(() {
      _versionTapCount++;
      if (_developerModeUnlocked) {
        return;
      }
      if (_versionTapCount >= 7) {
        _developerModeUnlocked = true;
        HapticFeedback.heavyImpact();
        AppFeedback.showSuccess(
          context,
          context.l10n.developerOptionsActivated,
        );
      } else if (_versionTapCount >= 4) {
        final remaining = 7 - _versionTapCount;
        HapticFeedback.selectionClick();
        AppFeedback.showInfo(
          context,
          context.l10n.tapMoreTimesToUnlock(remaining),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<InventoryProvider>(
          builder: (context, provider, child) {
            final syncValue = provider.pendingChanges > 0
                ? '${provider.pendingChanges}'
                : provider.isOffline
                ? l10n.statusOfflineTag
                : l10n.settingsSyncRowValueSynced;
            return ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 140),
              children: [
                Text(
                  l10n.commonSettings,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                SettingsProfileCard(provider: provider),
                const SizedBox(height: 20),
                SettingsAppearanceSection(provider: provider),
                const SizedBox(height: 20),
                SettingsGroup(
                  label: l10n.inventoryPreferences,
                  children: [
                    SettingsRow(
                      icon: Icons.payments_outlined,
                      label: l10n.currencySymbol,
                      value: provider.currency,
                      onTap: () => showCurrencyPicker(context, provider),
                    ),
                    SettingsRow(
                      icon: Icons.straighten_rounded,
                      label: l10n.defaultItemUnit,
                      value: provider.defaultUnit,
                      onTap: () => showDefaultUnitPicker(context, provider),
                    ),
                    SettingsRow(
                      icon: Icons.public,
                      label: l10n.timeZone,
                      value: provider.timezone,
                      onTap: () => showTimezonePicker(context, provider),
                    ),
                    e2eId(
                      'settings_categories',
                      SettingsRow(
                        icon: Icons.category_rounded,
                        label: l10n.manageCategories,
                        value: '${provider.categories.length}',
                        onTap: () =>
                            showCategoryManagementSheet(context, provider),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SettingsGroup(
                  label: l10n.settingsScannerHeader,
                  children: [
                    e2eId(
                      'settings_vibrate',
                      SettingsToggleRow(
                        icon: Icons.vibration_rounded,
                        label: l10n.settingsVibrate,
                        value: provider.vibrateOnScan,
                        onChanged: (val) {
                          provider.setVibrateOnScan(val);
                          if (val) HapticFeedback.mediumImpact();
                        },
                      ),
                    ),
                    e2eId(
                      'settings_beep',
                      SettingsToggleRow(
                        icon: Icons.volume_up_outlined,
                        label: l10n.settingsSound,
                        value: provider.beepOnScan,
                        onChanged: provider.setBeepOnScan,
                      ),
                    ),
                    e2eId(
                      'settings_auto_open',
                      SettingsToggleRow(
                        icon: Icons.open_in_new_rounded,
                        label: l10n.settingsAutoOpen,
                        value: provider.autoOpenOnScan,
                        onChanged: provider.setAutoOpenOnScan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SettingsGroup(
                  label: l10n.settingsAlertsHeader,
                  children: [
                    SettingsRow(
                      icon: Icons.event_available_rounded,
                      label: l10n.expiryWarningWindow,
                      value: '${provider.expiryWarningDays} days',
                      onTap: () => showExpiryDaysPicker(context, provider),
                    ),
                    SettingsRow(
                      icon: Icons.verified_user_outlined,
                      label: l10n.warrantyWarningWindow,
                      value: '${provider.warrantyWarningDays} days',
                      onTap: () => showWarrantyDaysPicker(context, provider),
                    ),
                    SettingsToggleRow(
                      icon: Icons.alarm_rounded,
                      label: l10n.settingsExpiring,
                      value: provider.notifyExpiring,
                      onChanged: provider.setNotifyExpiring,
                    ),
                    SettingsToggleRow(
                      icon: Icons.production_quantity_limits_rounded,
                      label: l10n.settingsLowStock,
                      value: provider.notifyLowStock,
                      onChanged: provider.setNotifyLowStock,
                    ),
                    SettingsToggleRow(
                      icon: Icons.assignment_late_outlined,
                      label: l10n.settingsOverdue,
                      value: provider.notifyOverdue,
                      onChanged: provider.setNotifyOverdue,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SettingsGroup(
                  label: l10n.reportsInventoryAudit,
                  children: [
                    SettingsRow(
                      icon: Icons.donut_large_outlined,
                      label: l10n.inventoryHealthBreakdown,
                      onTap: () => showInventoryStatusSheet(context, provider),
                    ),
                    SettingsRow(
                      icon: Icons.qr_code_2_rounded,
                      label: l10n.exportAllBoxBarcodesPdf,
                      onTap: () => ExportBarcodesSheet.showAll(context),
                    ),
                    SettingsRow(
                      icon: Icons.summarize_outlined,
                      label: l10n.exportInventoryReport,
                      onTap: () => showExportReportSheet(context, provider),
                    ),
                    e2eId(
                      'settings_trash',
                      SettingsRow(
                        icon: Icons.delete_outline_rounded,
                        label: l10n.commonTrash,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TrashScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_developerModeUnlocked) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildSectionHeader(
                          l10n.developerOptionsBackendApi,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _developerModeUnlocked = false;
                            _versionTapCount = 0;
                          });
                          AppFeedback.showInfo(
                            context,
                            l10n.developerModeDeactivated,
                          );
                        },
                        icon: AppIcon(
                          Icons.lock_outline,
                          size: 14,
                          color: c.textSecondary,
                        ),
                        label: Text(
                          l10n.commonHide,
                          style: TextStyle(
                            fontSize: 12,
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildBackendSection(context, provider),
                  const SizedBox(height: 20),
                ],
                FailedOpsTile(provider: provider),
                SettingsGroup(
                  label: l10n.settingsAccountHeader,
                  children: [
                    e2eId(
                      'settings_sync',
                      SettingsRow(
                        icon: Icons.sync_rounded,
                        label: l10n.syncSheetTitle,
                        value: syncValue,
                        onTap: () => showSyncStatusSheet(context, provider),
                      ),
                    ),
                    if (kE2E)
                      e2eId(
                        'settings_dev_gallery',
                        SettingsRow(
                          icon: Icons.palette_outlined,
                          label: 'Component gallery (dev)',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const DevComponentGalleryScreen(),
                            ),
                          ),
                        ),
                      ),
                    e2eId(
                      'settings_logout',
                      SettingsRow(
                        icon: Icons.logout_rounded,
                        label: l10n.logOutSwitchAccount,
                        onTap: () => showLogoutDialog(context, provider),
                      ),
                    ),
                    e2eId(
                      'settings_delete_account',
                      SettingsRow(
                        icon: Icons.person_remove_outlined,
                        label: l10n.deleteAccount,
                        labelColor: c.dangerStrong,
                        iconColor: c.dangerStrong,
                        iconBackground: c.dangerSoft,
                        onTap: () => showDeleteAccountDialog(context, provider),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Tappable(
                  onTap: _handleVersionTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            '${l10n.applicationVersion} 1.0.0 (Build 2026)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: c.textMuted,
                            ),
                          ),
                        ),
                        if (_developerModeUnlocked) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTones.limeSoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n.developerBadge,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppTones.matcha,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
