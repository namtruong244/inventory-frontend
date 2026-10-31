import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/inventory_provider.dart';
import 'failed_ops_tile.dart';
import 'session_guard.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';
import 'tappable.dart';

/// App-wide strip shown above every screen while the app is offline, changes are
/// waiting to sync, or the server dropped some of them. Tap for details and "Sync now".
class SyncStatusBar extends StatelessWidget {
  final Widget child;
  const SyncStatusBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final l10n = AppLocalizations.of(context);
    final needsAttention =
        provider.failedOps.length + (provider.syncNotices.isEmpty ? 0 : 1);
    final show =
        !provider.sessionExpired &&
        (provider.isOffline ||
            provider.pendingChanges > 0 ||
            needsAttention > 0);
    if (!show) return child;

    final text = StringBuffer(
      provider.isOffline ? l10n.syncOffline : l10n.syncUnsynced,
    );
    if (provider.pendingChanges > 0) {
      text.write(' · ${l10n.syncPending(provider.pendingChanges)}');
    }
    if (needsAttention > 0) {
      text.write(' · ${l10n.syncNeedsAttention(needsAttention)}');
    }

    return Column(
      children: [
        ColoredBox(
          color: context.colors.background,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 6),
              child: SyncStatusPill(
                text: text.toString(),
                icon: provider.isOffline
                    ? Icons.cloud_off_rounded
                    : Icons.sync_problem_rounded,
                danger: needsAttention > 0,
                actionLabel: provider.isSyncing ? null : l10n.syncNow,
                onAction: provider.syncNow,
                onTap: () => _showDetails(provider),
              ),
            ),
          ),
        ),
        Expanded(
          // The bar already covers the status bar inset.
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          ),
        ),
      ],
    );
  }

  void _showDetails(InventoryProvider provider) {
    final navContext = appNavigatorKey.currentContext;
    if (navContext == null) return;
    showModalBottomSheet<void>(
      context: navContext,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ChangeNotifierProvider<InventoryProvider>.value(
        value: provider,
        child: const _SyncDetailsSheet(),
      ),
    );
  }
}

class _SyncDetailsSheet extends StatelessWidget {
  const _SyncDetailsSheet();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.syncSheetTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.isOffline ? l10n.syncOfflineBody : l10n.syncOnlineBody,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.syncPending(provider.pendingChanges),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (provider.syncNotices.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.syncRejectedTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              for (final notice in provider.syncNotices)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $notice', style: theme.textTheme.bodyMedium),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: provider.dismissSyncNotices,
                  child: Text(l10n.syncDismiss),
                ),
              ),
            ],
            const SizedBox(height: 12),
            FailedOpsTile(provider: provider),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: provider.isSyncing ? null : provider.syncNow,
                icon: provider.isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const AppIcon(Icons.sync_rounded),
                label: Text(l10n.syncNow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Design SyncStatusBar pill: warning tones (danger when changes need attention),
/// icon, message and a "Sync now" action.
class SyncStatusPill extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool danger;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onTap;

  const SyncStatusPill({
    super.key,
    required this.text,
    required this.icon,
    this.danger = false,
    this.actionLabel,
    this.onAction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bg = danger ? c.dangerSoft : c.warningSoft;
    final fg = danger ? c.dangerStrong : c.warningStrong;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 38),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                AppIcon(icon, size: 18, color: fg),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(width: 10),
                  Tappable(
                    onTap: onAction,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      actionLabel!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
