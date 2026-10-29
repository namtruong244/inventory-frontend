import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../screens/alerts_screen.dart';
import '../screens/lending_tracker_screen.dart';
import 'tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';

/// Home tab sections. Navigation and tab switching stay owned by the home
/// screen and are passed in as callbacks.
class HomeSections {
  final BuildContext context;
  final Future<void> Function(Widget page) navigate;
  final void Function(int index) selectTab;

  HomeSections(this.context, {required this.navigate, required this.selectTab});

  Widget buildConnectionBanner() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        // Offline mode is covered by the app-wide SyncStatusBar.
        if (provider.isConnected || provider.isOffline)
          return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.colors.dangerSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const AppIcon(
                Icons.cloud_off_rounded,
                color: AppTones.coral,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.cannotConnectToBackend(provider.serverUrl),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.dangerStrong,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => provider.fetchAllData(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  context.l10n.commonRetry,
                  style: TextStyle(fontSize: 12, ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildAlertBanner() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        final alertCount = provider.totalAlertCount;
        final overdueCount = provider.getOverdueLoans().length;
        final expiredCount = provider.getExpiredItems().length;
        if (alertCount == 0) return const SizedBox.shrink();

        String alertMessage = '';
        if (overdueCount > 0 && expiredCount > 0) {
          alertMessage =
              '$overdueCount overdue loan & $expiredCount expired item require action';
        } else if (overdueCount > 0) {
          alertMessage = '$overdueCount item loan is currently overdue!';
        } else {
          alertMessage = '$alertCount items/warranties require your attention';
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.colors.dangerSoft,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTones.coral.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const AppIcon(
                  Icons.warning_amber_rounded,
                  color: AppTones.coral,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.actionRequired,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.colors.dangerStrong,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alertMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        color: context.colors.dangerStrong,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Tappable(
                onTap: () => navigate(const AlertsScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.l10n.commonReview,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildQuickModulesSection() {
    final provider = Provider.of<InventoryProvider>(context);
    final c = context.colors;
    final activeLoans = provider.getActiveLoans().length;
    final totalAlerts = provider.totalAlertCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _QuickCard(
              icon: Icons.handshake_outlined,
              iconBg: c.infoSoft,
              iconFg: c.infoStrong,
              title: context.l10n.commonLending,
              stat: '$activeLoans',
              caption: activeLoans > 0
                  ? '$activeLoans Active'
                  : context.l10n.noLoans,
              onTap: () => navigate(const LendingTrackerScreen()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickCard(
              icon: totalAlerts > 0
                  ? Icons.notifications_active_outlined
                  : Icons.shield_outlined,
              iconBg: totalAlerts > 0 ? c.dangerSoft : c.successSoft,
              iconFg: totalAlerts > 0 ? c.dangerStrong : c.successStrong,
              title: context.l10n.commonAlerts,
              stat: '$totalAlerts',
              caption: totalAlerts > 0
                  ? '$totalAlerts Issues'
                  : context.l10n.allClear,
              onTap: () => navigate(const AlertsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slim white pill: icon, title with caption, count and a drill-down chevron.
class _QuickCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String stat;
  final String caption;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.stat,
    required this.caption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tappable(
      semanticLabel: title,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: c.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppIcon(icon, color: iconFg, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: c.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              stat,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
              ),
            ),
            AppIcon(Icons.chevron_right_rounded, color: c.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
