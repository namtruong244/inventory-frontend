import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../providers/inventory_provider.dart';
import '../services/offline_store.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_feedback.dart';
import 'app_icon.dart';
import 'soft_sheet.dart';
import 'soft_ui.dart';

/// Opens the "Sync status" sheet: connection state, changes the server rejected
/// (keep / discard), how many are waiting, and the Sync now action.
Future<void> showSyncStatusSheet(
  BuildContext context,
  InventoryProvider provider,
) {
  return showSoftSheet<void>(
    context,
    title: context.l10n.syncSheetTitle,
    subtitle: provider.isOffline
        ? context.l10n.syncOffline
        : provider.pendingChanges > 0 || provider.failedOps.isNotEmpty
        ? context.l10n.syncUnsynced
        : context.l10n.settingsSyncRowValueSynced,
    builder: (_) => ChangeNotifierProvider<InventoryProvider>.value(
      value: provider,
      child: const _SyncSheetBody(),
    ),
  );
}

class _SyncSheetBody extends StatelessWidget {
  const _SyncSheetBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final l10n = context.l10n;
    final c = context.colors;
    final synced =
        !provider.isOffline &&
        provider.pendingChanges == 0 &&
        provider.failedOps.isEmpty &&
        provider.syncNotices.isEmpty;
    final status = provider.isOffline
        ? l10n.syncOfflineBody
        : synced
        ? l10n.syncAllSyncedBody
        : l10n.syncOnlineBody;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Banner(
            icon: provider.isOffline
                ? Icons.cloud_off_rounded
                : synced
                ? Icons.check_circle_rounded
                : Icons.sync_problem_rounded,
            text: status,
            background: synced ? c.successSoft : c.warningSoft,
            foreground: synced ? c.successStrong : c.warningStrong,
          ),
          if (provider.syncNotices.isNotEmpty) ...[
            const SizedBox(height: 14),
            _AttentionTile(
              title: l10n.syncRejectedTitle,
              body: provider.syncNotices.join('\n'),
              actions: [
                Expanded(
                  child: _TileButton(
                    label: l10n.syncDismiss,
                    onTap: provider.dismissSyncNotices,
                  ),
                ),
              ],
            ),
          ],
          for (final op in provider.failedOps) ...[
            const SizedBox(height: 14),
            _AttentionTile(
              title: describePendingOp(op),
              body: op.error ?? l10n.tapToKeepYourVersion,
              actions: [
                Expanded(
                  child: _TileButton(
                    label: l10n.keepMine,
                    accent: true,
                    onTap: () => provider.retryFailedOp(op.id),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TileButton(
                    label: l10n.commonDiscard,
                    onTap: () => _discard(context, provider, op),
                  ),
                ),
              ],
            ),
          ],
          if (provider.pendingChanges > 0) ...[
            const SizedBox(height: 14),
            Text(
              l10n.syncPendingLabel(provider.pendingChanges),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: c.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: e2eId(
                  'sync_sheet_close',
                  SoftButton(
                    label: l10n.commonClose,
                    icon: Icons.close_rounded,
                    style: SoftButtonStyle.secondary,
                    expand: true,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: e2eId(
                  'sync_sheet_sync_now',
                  SoftButton(
                    label: l10n.syncNow,
                    icon: Icons.sync_rounded,
                    expand: true,
                    loading: provider.isSyncing,
                    onPressed: provider.isSyncing ? null : provider.syncNow,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Dropping a change is final, so ask first.
  Future<void> _discard(
    BuildContext context,
    InventoryProvider provider,
    PendingOp op,
  ) async {
    final ok = await AppFeedback.showConfirmDialog(
      context,
      title: context.l10n.discardChangeTitle,
      message: context.l10n.discardChangeMessage,
      confirmLabel: context.l10n.commonDiscard,
      isDestructive: true,
    );
    if (!ok) return;
    await provider.discardFailedOp(op.id);
    await provider.fetchAllData();
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color background;
  final Color foreground;

  const _Banner({
    required this.icon,
    required this.text,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AppIcon(icon, size: 18, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttentionTile extends StatelessWidget {
  final String title;
  final String body;
  final List<Widget> actions;

  const _AttentionTile({
    required this.title,
    required this.body,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.dangerSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIcon(
                Icons.error_outline_rounded,
                size: 18,
                color: c.dangerStrong,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: c.dangerStrong,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: c.dangerStrong,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: actions),
        ],
      ),
    );
  }
}

class _TileButton extends StatelessWidget {
  final String label;
  final bool accent;
  final VoidCallback onTap;

  const _TileButton({
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: accent ? c.accent : c.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: accent ? c.onAccent : c.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
