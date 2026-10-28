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
        if (provider.isConnected || provider.isOffline) return const SizedBox.shrink();

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
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    horizontal: 14,
                    vertical: 8,
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
    final overdueLoans = provider.getOverdueLoans().length;
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
              caption: activeLoans > 0 ? '$activeLoans Active' : context.l10n.noLoans,
              // Share of active loans that are on time.
              progress: activeLoans == 0 ? null : (activeLoans - overdueLoans) / activeLoans,
              progressColor: overdueLoans > 0 ? c.dangerStrong : c.infoStrong,
              onTap: () => navigate(const LendingTrackerScreen()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickCard(
              icon: totalAlerts > 0 ? Icons.notifications_active_outlined : Icons.shield_outlined,
              iconBg: totalAlerts > 0 ? c.dangerSoft : c.successSoft,
              iconFg: totalAlerts > 0 ? c.dangerStrong : c.successStrong,
              title: context.l10n.commonAlerts,
              stat: '$totalAlerts',
              caption: totalAlerts > 0 ? '$totalAlerts Issues' : context.l10n.allClear,
              progress: totalAlerts == 0 ? 1 : null,
              progressColor: c.successStrong,
              onTap: () => navigate(const AlertsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

/// White 24px card: bold stat, muted caption, thin progress bar and a
/// trailing chevron that signals drill-down.
class _QuickCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String stat;
  final String caption;
  final double? progress;
  final Color progressColor;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.stat,
    required this.caption,
    required this.progress,
    required this.progressColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tappable(
      semanticLabel: title,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: c.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
                  child: AppIcon(icon, color: iconFg, size: 20),
                ),
                const Spacer(),
                AppIcon(Icons.chevron_right_rounded, color: c.textMuted, size: 22),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              stat,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1,
                letterSpacing: -1,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: c.textSecondary),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress ?? 0,
                minHeight: 6,
                backgroundColor: c.fill,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
