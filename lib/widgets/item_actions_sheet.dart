import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../screens/item_create_screen.dart';
import '../theme/app_theme.dart';
import 'app_feedback.dart';
import 'lend_item_sheet.dart';
import 'move_item_sheet.dart';
import 'soft_sheet.dart';
import 'stock_history_sheet.dart';
import 'trash_actions.dart';

/// What can be done to an item: the "…" menu of the detail page and the menu opened
/// by long-pressing a row. Each action runs after the sheet closed.
///
/// [onMainAction] and [onDelete] let the detail page override its own flows (use/
/// restock, pop the screen after deleting). Without [onMainAction] the main row is
/// only shown for a lent item, where it returns the active loan.
Future<void> showItemActionsSheet(
  BuildContext context,
  Item item, {
  VoidCallback? onMainAction,
  VoidCallback? onDelete,
}) {
  final l10n = context.l10n;
  final provider = context.read<InventoryProvider>();
  final loan = item.status == ItemStatus.lent
      ? provider.getActiveLoanForItem(item.id)
      : null;
  final mainAction =
      onMainAction ??
      (loan == null
          ? null
          : () => confirmAndReturnLoan(context, loan, itemName: item.name));
  // The fallback main action always returns the loan, even for a consumable.
  final returnsLoan = onMainAction == null;
  final mainLabel = returnsLoan
      ? l10n.itemMarkReturned
      : item.isConsumable
      ? l10n.itemActionUseRestock
      : switch (item.status) {
          ItemStatus.lent => l10n.itemMarkReturned,
          ItemStatus.stored => l10n.takeOutToUse,
          _ => l10n.returnToStorage,
        };
  final mainIcon = returnsLoan
      ? Icons.assignment_turned_in_outlined
      : item.isConsumable
      ? Icons.remove_circle_outline
      : item.status == ItemStatus.lent
      ? Icons.assignment_turned_in_outlined
      : Icons.outbox_rounded;
  final crumbs = item.boxId.isEmpty
      ? <Box>[]
      : provider.getBreadcrumb(item.boxId);
  final where = crumbs.map((b) => b.name).join(' › ');
  Future<void> defaultDelete() async {
    final confirmed = await TrashActions.confirm(context, name: item.name);
    if (!confirmed || !context.mounted) return;
    final ok = await provider.deleteItem(item.id);
    if (!context.mounted) return;
    if (ok) {
      TrashActions.showMoved(
        context,
        provider,
        name: item.name,
        itemId: item.id,
      );
    } else {
      AppFeedback.showError(context, l10n.couldNotDeletePleaseTry2(item.name));
    }
  }

  return showSoftSheet<void>(
    context,
    title: item.name,
    subtitle: where.isEmpty
        ? item.status.displayName
        : '$where · ${item.status.displayName}',
    builder: (sheetContext) {
      void run(VoidCallback cb) {
        Navigator.pop(sheetContext);
        cb();
      }

      final c = sheetContext.colors;
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (mainAction != null)
              SoftSheetActionRow(
                id: 'item_menu_main',
                icon: mainIcon,
                tone: AppTones.sky,
                label: mainLabel,
                onTap: () => run(mainAction),
              ),
            if (item.canLend)
              SoftSheetActionRow(
                id: 'item_menu_lend',
                icon: Icons.handshake_outlined,
                tone: AppTones.amber,
                label: l10n.lendItem,
                onTap: () =>
                    run(() => LendItemSheet.show(context, initialItem: item)),
              ),
            SoftSheetActionRow(
              id: 'item_menu_move',
              icon: Icons.drive_file_move_outlined,
              label: l10n.itemMoveToAnother,
              onTap: () => run(() => MoveItemSheet.show(context, item)),
            ),
            SoftSheetActionRow(
              id: 'item_menu_edit',
              icon: Icons.edit_outlined,
              label: l10n.editItemDetails,
              onTap: () => run(
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ItemCreateScreen(boxId: item.boxId, existingItem: item),
                  ),
                ),
              ),
            ),
            SoftSheetActionRow(
              id: 'item_menu_history',
              icon: Icons.history,
              label: l10n.stockHistory,
              onTap: () => run(() => StockHistorySheet.show(context, item)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Divider(height: 1, color: c.border),
            ),
            SoftSheetActionRow(
              id: 'item_menu_delete',
              icon: Icons.delete_outline_rounded,
              tone: AppTones.coral,
              label: l10n.itemMoveToTrash,
              sublabel: l10n.itemRestoreWithin(TrashActions.retentionDays),
              danger: true,
              onTap: () => run(onDelete ?? defaultDelete),
            ),
          ],
        ),
      );
    },
  );
}
