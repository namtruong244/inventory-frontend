import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../providers/inventory_provider.dart';
import '../screens/alerts_screen.dart';
import '../screens/lending_tracker_screen.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_icon.dart';
import 'soft_ui.dart';
import 'state_views.dart';
import 'tappable.dart';

/// Home tab sections. Navigation and tab switching stay owned by the home
/// screen and are passed in as callbacks. Sections have no outer margin: the
/// Home column owns the 24 side padding and the 24 gaps between sections.
class HomeSections {
  final BuildContext context;
  final Future<void> Function(Widget page) navigate;

  /// Switches tab; `reset` opens it at the top with filters cleared.
  final void Function(int index, {bool reset}) selectTab;

  HomeSections(this.context, {required this.navigate, required this.selectTab});

  /// "Can't reach the server" strip with Retry; offline mode is covered by the
  /// app-wide SyncStatusBar so it only shows for a failed connection.
  Widget buildConnectionBanner() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        if (provider.isConnected || provider.isOffline) {
          return const SizedBox.shrink();
        }
        return ConnectionErrorBanner(onRetry: () => provider.fetchAllData());
      },
    );
  }

  /// Dark "Action required" card with a Review button and count pills.
  Widget buildAlertBanner() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        final c = context.colors;
        final l10n = context.l10n;
        final alertCount = provider.totalAlertCount;
        if (alertCount == 0) return const SizedBox.shrink();
        final expired = provider.getExpiredItems().length;
        final low = provider.getLowStockItems().length;
        final overdue = provider.getOverdueLoans().length;

        Widget pill(String text, Color dot) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  color: AppTones.textOnDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

        return e2eId(
          'home_alert_banner',
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: c.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SoftIconTile(
                      Icons.warning_amber_rounded,
                      size: 40,
                      color: c.onAccent,
                      background: c.accent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.actionRequired.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: c.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.homeAttentionTitle(alertCount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    e2eId(
                      'home_review',
                      Tappable(
                        semanticLabel: l10n.commonReview,
                        onTap: () => navigate(const AlertsScreen()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: c.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.commonReview,
                                style: TextStyle(
                                  color: c.onAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              AppIcon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: c.onAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (expired + low + overdue > 0) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (expired > 0)
                        pill(
                          l10n.homeChipExpired(expired),
                          AppTones.coralOnDark,
                        ),
                      if (low > 0)
                        pill(l10n.homeChipLow(low), AppTones.amberOnDark),
                      if (overdue > 0)
                        pill(
                          l10n.homeChipOverdue(overdue),
                          AppTones.coralOnDark,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Alerts and Lending shortcut cards, side by side.
  Widget buildQuickModulesSection() {
    final provider = Provider.of<InventoryProvider>(context);
    final c = context.colors;
    final l10n = context.l10n;
    final activeLoans = provider.getActiveLoans().length;
    final overdueLoans = provider.getOverdueLoans().length;
    final totalAlerts = provider.totalAlertCount;

    final alertsChip = totalAlerts > 0
        ? SoftChip(
            label: l10n.homeAlertsOpen(totalAlerts),
            background: c.dangerSoft,
            foreground: c.dangerStrong,
            icon: Icons.error_outline_rounded,
          )
        : SoftChip(
            label: l10n.allClear,
            background: c.successSoft,
            foreground: c.successStrong,
            icon: Icons.check_circle_outline_rounded,
          );
    final lendingChip = overdueLoans > 0
        ? SoftChip(
            label: l10n.homeChipOverdue(overdueLoans),
            background: c.dangerSoft,
            foreground: c.dangerStrong,
            icon: Icons.schedule_rounded,
          )
        : activeLoans > 0
        ? SoftChip(
            label: l10n.homeLendingActive(activeLoans),
            background: c.warningSoft,
            foreground: c.warningStrong,
            icon: Icons.schedule_rounded,
          )
        : SoftChip(
            label: l10n.noLoans,
            background: c.fill,
            foreground: c.textSecondary,
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: e2eId(
            'home_alerts',
            _ModuleCard(
              icon: totalAlerts > 0
                  ? Icons.notifications_active_outlined
                  : Icons.shield_outlined,
              iconBg: totalAlerts > 0 ? c.dangerSoft : c.successSoft,
              iconFg: totalAlerts > 0 ? c.dangerStrong : c.successStrong,
              title: l10n.commonAlerts,
              sub: l10n.homeAlertsSub,
              chip: alertsChip,
              onTap: () => navigate(const AlertsScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: e2eId(
            'home_lending',
            _ModuleCard(
              icon: Icons.handshake_outlined,
              iconBg: c.warningSoft,
              iconFg: c.warningStrong,
              title: l10n.commonLending,
              sub: l10n.homeLendingSub,
              chip: lendingChip,
              onTap: () => navigate(const LendingTrackerScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

/// Design `Alerts Module` / `Lending Module`: icon tile + arrow, title, sub, chip.
class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String sub;
  final Widget chip;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.sub,
    required this.chip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tappable(
      semanticLabel: title,
      onTap: onTap,
      child: SoftCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SoftIconTile(icon, size: 40, color: iconFg, background: iconBg),
                AppIcon(Icons.north_east_rounded, size: 18, color: c.textMuted),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            chip,
          ],
        ),
      ),
    );
  }
}
