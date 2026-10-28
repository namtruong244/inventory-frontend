import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/inventory_provider.dart';
import 'failed_ops_tile.dart';
import 'session_guard.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';

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
    final show = !provider.sessionExpired &&
        (provider.isOffline || provider.pendingChanges > 0 || needsAttention > 0);
    if (!show) return child;

    final warn = needsAttention > 0;
    final bg = warn ? context.colors.warningSoft : context.colors.dangerSoft;
    final fg = warn ? context.colors.warningStrong : context.colors.dangerStrong;
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
        Material(
          color: bg,
          child: SafeArea(
            bottom: false,
            child: InkWell(
              onTap: () => _showDetails(provider),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      AppIcon(
                        provider.isOffline
                            ? Icons.cloud_off_rounded
                            : Icons.sync_problem_rounded,
                        size: 18,
                        color: fg,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          text.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
                        ),
                      ),
                      AppIcon(Icons.chevron_right_rounded, size: 18, color: fg),
                    ],
                  ),
                ),
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
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              provider.isOffline ? l10n.syncOfflineBody : l10n.syncOnlineBody,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.syncPending(provider.pendingChanges),
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (provider.syncNotices.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.syncRejectedTitle,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
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
