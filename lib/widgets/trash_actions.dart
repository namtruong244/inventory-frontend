import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import 'session_guard.dart';

/// Shared copy and Undo for deleting items/boxes, which only moves them to Trash.
class TrashActions {
  static const retentionDays = 30;

  static Future<bool> confirm(
    BuildContext context, {
    required String name,
    bool isBox = false,
    bool hasContents = false,
  }) {
    final l10n = AppLocalizations.of(context);
    return AppFeedback.showConfirmDialog(
      context,
      title: isBox ? l10n.trashConfirmBoxTitle : l10n.trashConfirmItemTitle,
      message: hasContents
          ? l10n.trashConfirmBoxMessage(name, retentionDays)
          : l10n.trashConfirmMessage(name, retentionDays),
      confirmLabel: l10n.trashMoveAction,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
  }

  /// Toast after a delete. Undo restores from Trash, so it is only offered when
  /// the delete already reached the server (nothing is waiting in the offline queue).
  static void showMoved(
    BuildContext context,
    InventoryProvider provider, {
    required String name,
    String? itemId,
    String? boxId,
  }) {
    // The screen that deleted may already be popped, so show on the root navigator.
    context = appNavigatorKey.currentContext ?? context;
    final l10n = AppLocalizations.of(context);
    final canUndo = provider.isConnected && provider.pendingChanges == 0;
    AppFeedback.showSuccess(
      context,
      l10n.trashMovedToast(name),
      actionLabel: canUndo ? l10n.trashUndo : null,
      onAction: canUndo
          ? () async {
              final ok = await provider.restoreFromTrash(
                itemId: itemId,
                boxId: boxId,
              );
              if (!context.mounted) return;
              if (ok) {
                AppFeedback.showSuccess(context, l10n.trashRestoredToast(name));
              } else {
                AppFeedback.showError(context, l10n.trashRestoreFailed(name));
              }
            }
          : null,
    );
  }
}
