import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/settings_common.dart';
import '../widgets/settings_profile_sheets.dart';
import '../widgets/settings_pickers.dart';
import '../widgets/settings_report_sheets.dart';
import '../widgets/settings_backend_section.dart';


import '../l10n/app_localizations.dart';
import '../providers/inventory_provider.dart';
import '../widgets/settings_appearance_section.dart';
import '../widgets/app_feedback.dart';
import '../widgets/failed_ops_tile.dart';
import '../widgets/export_barcodes_sheet.dart';
import 'login_screen.dart';
import 'trash_screen.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

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
        AppFeedback.showSuccess(context, context.l10n.developerOptionsActivated);
      } else if (_versionTapCount >= 4) {
        final remaining = 7 - _versionTapCount;
        HapticFeedback.selectionClick();
        AppFeedback.showInfo(context, context.l10n.tapMoreTimesToUnlock(remaining));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<InventoryProvider>(
          builder: (context, provider, child) {
            final totalBoxes = provider.boxes.length;
            final totalItems = provider.items.length;
            final activeLoans = provider.getActiveLoans().length;

            return ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
              children: [
                // Page Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.commonSettings,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.preferencesTaxonomyInventoryTools,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 1. User Profile Card
                _buildProfileCard(context, provider),
                const SizedBox(height: 16),

                // 2. Inventory Stats Overview Banner
                _buildStatsBanner(provider, totalBoxes, totalItems, activeLoans),
                const SizedBox(height: 24),

                // 3. Category Management Section
                buildSectionHeader(context.l10n.taxonomyCategories),
                const SizedBox(height: 8),
                buildCardContainer([
                  ListTile(
                    leading: buildIconBox(Icons.category_rounded, const Color(0xFF6366F1), context.colors.infoSoft),
                    title: Text(
                      context.l10n.manageCategories,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: context.colors.textPrimary),
                    ),
                    subtitle: Text(
                      '${provider.categories.length} item categories available',
                      style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.colors.fill,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${provider.categories.length}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: context.colors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: context.colors.textSecondary, size: 20),
                      ],
                    ),
                    onTap: () => showCategoryManagementSheet(context, provider),
                  ),
                ]),
                const SizedBox(height: 24),

                // 4. Inventory Preferences
                buildSectionHeader(context.l10n.inventoryPreferences),
                const SizedBox(height: 8),
                buildCardContainer([
                  buildPreferenceTile(
                    icon: Icons.payments_outlined,
                    iconColor: const Color(0xFF10B981),
                    iconBg: context.colors.successSoft,
                    title: context.l10n.currencySymbol,
                    subtitle: context.l10n.usedForPurchasePricesValuation,
                    valueText: provider.currency,
                    onTap: () => showCurrencyPicker(context, provider),
                  ),
                  const Divider(height: 1),
                  buildPreferenceTile(
                    icon: Icons.straighten_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    iconBg: context.colors.warningSoft,
                    title: context.l10n.defaultItemUnit,
                    subtitle: context.l10n.preFilledUnitForNewly,
                    valueText: provider.defaultUnit,
                    onTap: () => showDefaultUnitPicker(context, provider),
                  ),
                  const Divider(height: 1),
                  buildPreferenceTile(
                    icon: Icons.event_available_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    iconBg: context.colors.infoSoft,
                    title: context.l10n.expiryWarningWindow,
                    subtitle: context.l10n.daysBeforeExpirationToTrigger,
                    valueText: '${provider.expiryWarningDays} days',
                    onTap: () => showExpiryDaysPicker(context, provider),
                  ),
                  const Divider(height: 1),
                  buildPreferenceTile(
                    icon: Icons.verified_user_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBg: context.colors.infoSoft,
                    title: context.l10n.warrantyWarningWindow,
                    subtitle: context.l10n.daysBeforeWarrantyEndsTo,
                    valueText: '${provider.warrantyWarningDays} days',
                    onTap: () => showWarrantyDaysPicker(context, provider),
                  ),
                  const Divider(height: 1),
                  buildPreferenceTile(
                    icon: Icons.public,
                    iconColor: const Color(0xFF0EA5E9),
                    iconBg: const Color(0xFFF0F9FF),
                    title: context.l10n.timeZone,
                    subtitle: context.l10n.usedToDecideWhatToday,
                    valueText: provider.timezone,
                    onTap: () => showTimezonePicker(context, provider),
                  ),
                ]),
                const SizedBox(height: 24),

                SettingsAppearanceSection(provider: provider),
                const SizedBox(height: 24),

                // 5. Scanner & Barcode Options
                buildSectionHeader(l10n.settingsScannerHeader),
                const SizedBox(height: 8),
                buildCardContainer([
                  SwitchListTile.adaptive(
                    value: provider.vibrateOnScan,
                    onChanged: (val) {
                      provider.setVibrateOnScan(val);
                      if (val) HapticFeedback.mediumImpact();
                    },
                    secondary: buildIconBox(Icons.vibration_rounded, const Color(0xFF8B5CF6), context.colors.infoSoft),
                    title: Text(l10n.settingsVibrate, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(l10n.settingsVibrateSubtitle, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                    activeTrackColor: context.colors.primary,
                    activeThumbColor: Colors.white,
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: provider.beepOnScan,
                    onChanged: (val) => provider.setBeepOnScan(val),
                    secondary: buildIconBox(Icons.volume_up_outlined, const Color(0xFF06B6D4), const Color(0xFFECFEFF)),
                    title: Text(l10n.settingsSound, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(l10n.settingsSoundSubtitle, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                    activeTrackColor: context.colors.primary,
                    activeThumbColor: Colors.white,
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: provider.autoOpenOnScan,
                    onChanged: (val) => provider.setAutoOpenOnScan(val),
                    secondary: buildIconBox(Icons.open_in_new_rounded, const Color(0xFF10B981), context.colors.successSoft),
                    title: Text(l10n.settingsAutoOpen, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(l10n.settingsAutoOpenSubtitle, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                    activeTrackColor: context.colors.primary,
                    activeThumbColor: Colors.white,
                  ),
                ]),
                const SizedBox(height: 24),

                // 6. Alerts & Notifications
                buildSectionHeader(l10n.settingsAlertsHeader),
                const SizedBox(height: 8),
                buildCardContainer([
                  SwitchListTile.adaptive(
                    value: provider.notifyExpiring,
                    onChanged: (val) => provider.setNotifyExpiring(val),
                    secondary: buildIconBox(Icons.alarm_rounded, const Color(0xFFEF4444), context.colors.dangerSoft),
                    title: Text(l10n.settingsExpiring, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(l10n.settingsExpiringSubtitle, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                    activeTrackColor: context.colors.primary,
                    activeThumbColor: Colors.white,
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: provider.notifyOverdue,
                    onChanged: (val) => provider.setNotifyOverdue(val),
                    secondary: buildIconBox(Icons.assignment_late_outlined, const Color(0xFFF97316), context.colors.warningSoft),
                    title: Text(l10n.settingsOverdue, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(l10n.settingsOverdueSubtitle, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                    activeTrackColor: context.colors.primary,
                    activeThumbColor: Colors.white,
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: provider.notifyLowStock,
                    onChanged: (val) => provider.setNotifyLowStock(val),
                    secondary: buildIconBox(Icons.production_quantity_limits_rounded, const Color(0xFFEAB308), const Color(0xFFFEFCE8)),
                    title: Text(l10n.settingsLowStock, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(l10n.settingsLowStockSubtitle, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                    activeTrackColor: context.colors.primary,
                    activeThumbColor: Colors.white,
                  ),
                ]),
                const SizedBox(height: 24),

                // 7. Reports & Audit
                buildSectionHeader(context.l10n.reportsInventoryAudit),
                const SizedBox(height: 8),
                buildCardContainer([
                  ListTile(
                    leading: buildIconBox(Icons.qr_code_2_rounded, const Color(0xFF6366F1), context.colors.infoSoft),
                    title: Text(
                      context.l10n.exportAllBoxBarcodesPdf,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.colors.textPrimary),
                    ),
                    subtitle: Text(
                      context.l10n.generatePrintablePdfStickerSheet,
                      style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: context.colors.textSecondary, size: 20),
                    onTap: () => ExportBarcodesSheet.showAll(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: buildIconBox(Icons.summarize_outlined, const Color(0xFF059669), context.colors.successSoft),
                    title: Text(
                      context.l10n.exportInventoryReport,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.colors.textPrimary),
                    ),
                    subtitle: Text(
                      context.l10n.generateCopyFormattedSummaryOf,
                      style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: context.colors.textSecondary, size: 20),
                    onTap: () => showExportReportSheet(context, provider),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: buildIconBox(Icons.delete_outline_rounded, const Color(0xFFDC2626), context.colors.dangerSoft),
                    title: Text(
                      context.l10n.commonTrash,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.colors.textPrimary),
                    ),
                    subtitle: Text(
                      context.l10n.restoreOrPermanentlyDeleteRemoved,
                      style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: context.colors.textSecondary, size: 20),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TrashScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: buildIconBox(Icons.donut_large_outlined, const Color(0xFF2563EB), context.colors.infoSoft),
                    title: Text(
                      context.l10n.inventoryHealthBreakdown,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.colors.textPrimary),
                    ),
                    subtitle: Text(
                      context.l10n.statusDistributionInStockLent,
                      style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: context.colors.textSecondary, size: 20),
                    onTap: () => showInventoryStatusSheet(context, provider),
                  ),
                ]),
                const SizedBox(height: 24),

                // 8. Backend Server & API (Developer Mode Only - Unlocked via 7 taps on Version)
                if (_developerModeUnlocked) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildSectionHeader(context.l10n.developerOptionsBackendApi),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _developerModeUnlocked = false;
                            _versionTapCount = 0;
                          });
                          AppFeedback.showInfo(context, context.l10n.developerModeDeactivated);
                        },
                        icon: Icon(Icons.lock_outline, size: 14, color: context.colors.textSecondary),
                        label: Text(context.l10n.commonHide, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildBackendSection(context, provider),
                  const SizedBox(height: 24),
                ],

                // 9. Application Info
                buildSectionHeader(context.l10n.applicationInfo),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(
                    children: [
                      buildInfoRow(
                        context.l10n.applicationVersion,
                        '1.0.0 (Build 2026)',
                        onTap: _handleVersionTap,
                        trailingBadge: _developerModeUnlocked
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  context.l10n.developerBadge,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const Divider(height: 20),
                      buildInfoRow(context.l10n.designSystem, context.l10n.minimalCharcoalIosStyle),
                      const Divider(height: 20),
                      buildInfoRow(context.l10n.qrBarcodeEngine, 'MobileScanner v5'),
                      const Divider(height: 20),
                      buildInfoRow(context.l10n.storageArchitecture, context.l10n.hierarchicalMultiLevelTree),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                FailedOpsTile(provider: provider),

                // 10. Account Sign Out / Switch
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmSignOut(context, provider),
                    icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
                    label: Text(
                      context.l10n.logOutSwitchAccount,
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.colors.dangerSoft, width: 1.5),
                      backgroundColor: context.colors.dangerSoft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => _confirmDeleteAccount(context, provider),
                    child: Text(
                      context.l10n.deleteAccount,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
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

  // --- Profile Card ---
  Widget _buildProfileCard(BuildContext context, InventoryProvider provider) {
    final email = provider.userEmail;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  provider.userRole,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.switchAccountLogin,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.fill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.sync_alt_rounded, size: 18, color: context.colors.textPrimary),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          IconButton(
            tooltip: context.l10n.editProfile,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.fill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.edit_outlined, size: 18, color: context.colors.textPrimary),
            ),
            onPressed: () => showEditProfileDialog(context, provider),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, InventoryProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.l10n.logOut, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text(
          context.l10n.areYouSureYouWant,
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              var loggedOut = await provider.logout();
              if (!loggedOut && context.mounted) {
                final discard = await AppFeedback.showConfirmDialog(
                  context,
                  title: context.l10n.unsyncedChanges,
                  message:
                      '${provider.pendingChanges} change(s) have not been uploaded yet and will be lost if you log out. Log out anyway?',
                  confirmLabel: context.l10n.discardLogOut,
                  isDestructive: true,
                );
                if (!discard) return;
                loggedOut = await provider.logout(force: true);
              }
              if (loggedOut && context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: Text(context.l10n.logOut2),
          ),
        ],
      ),
    );
  }

  /// Two steps: explain what is lost, then require typing DELETE.
  void _confirmDeleteAccount(BuildContext context, InventoryProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.l10n.deleteAccount2, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text(
          context.l10n.thisPermanentlyDeletesYourAccount,
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _confirmDeleteAccountTyped(context, provider);
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: Text(context.l10n.commonContinue),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccountTyped(BuildContext context, InventoryProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(context.l10n.confirmDeletion, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: TextField(
            controller: controller,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: context.l10n.typeDeleteToConfirm,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton(
              onPressed: controller.text.trim() == 'DELETE'
                  ? () async {
                      Navigator.pop(ctx);
                      final error = await provider.deleteAccount();
                      if (!context.mounted) return;
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                        return;
                      }
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  : null,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: Text(context.l10n.deleteForever),
            ),
          ],
        ),
      ),
    ).whenComplete(controller.dispose);
  }

  // --- Stats Banner ---
  Widget _buildStatsBanner(InventoryProvider provider, int totalBoxes, int totalItems, int activeLoans) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              context.l10n.inventoryQuickMetrics,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context.l10n.commonContainers, '$totalBoxes'),
              Container(width: 1, height: 32, color: Colors.white24),
              _buildStatItem(context.l10n.totalAssets, '$totalItems'),
              Container(width: 1, height: 32, color: Colors.white24),
              _buildStatItem(context.l10n.onLoan, '$activeLoans'),
              Container(width: 1, height: 32, color: Colors.white24),
              _buildStatItem(context.l10n.estValue, provider.formatPrice(provider.totalInventoryValue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // --- Reusable UI Elements ---

  // ==========================================
  // MODAL BOTTOM SHEETS & DIALOGS
  // ==========================================

  // 1. Edit Profile Sheet

  // 2. Category Management Modal Sheet

  // 3. Currency Picker Sheet

  // 4. Default Unit Picker Sheet

  // 5. Expiry Days Warning Picker

  // Generic Selection Sheet Helper

  // 7. Export Report Sheet

  // 8. Inventory Health & Status Sheet

  // --- Backend Server Section ---
}

