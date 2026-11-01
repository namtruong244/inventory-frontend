import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../theme/app_theme.dart';
import 'soft_sheet.dart';

/// The "…" menu of the item detail page. Each callback runs after the sheet closed.
Future<void> showItemActionsSheet(
  BuildContext context, {
  required Item item,
  required String subtitle,
  required VoidCallback onMainAction,
  required VoidCallback onMove,
  required VoidCallback onEdit,
  required VoidCallback onLend,
  required VoidCallback onHistory,
  required VoidCallback onDelete,
}) {
  final l10n = context.l10n;
  final mainLabel = item.isConsumable
      ? l10n.itemActionUseRestock
      : switch (item.status) {
          ItemStatus.lent => l10n.itemMarkReturned,
          ItemStatus.stored => l10n.takeOutToUse,
          _ => l10n.returnToStorage,
        };
  final mainIcon = item.isConsumable
      ? Icons.remove_circle_outline
      : item.status == ItemStatus.lent
      ? Icons.assignment_turned_in_outlined
      : Icons.outbox_rounded;
  return showSoftSheet<void>(
    context,
    title: item.name,
    subtitle: subtitle,
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
            SoftSheetActionRow(
              id: 'item_menu_main',
              icon: mainIcon,
              tone: AppTones.sky,
              label: mainLabel,
              onTap: () => run(onMainAction),
            ),
            if (item.status != ItemStatus.lent)
              SoftSheetActionRow(
                id: 'item_menu_lend',
                icon: Icons.handshake_outlined,
                tone: AppTones.amber,
                label: l10n.lendItem,
                onTap: () => run(onLend),
              ),
            SoftSheetActionRow(
              id: 'item_menu_move',
              icon: Icons.drive_file_move_outlined,
              label: l10n.itemMoveToAnother,
              onTap: () => run(onMove),
            ),
            SoftSheetActionRow(
              id: 'item_menu_edit',
              icon: Icons.edit_outlined,
              label: l10n.editItemDetails,
              onTap: () => run(onEdit),
            ),
            SoftSheetActionRow(
              id: 'item_menu_history',
              icon: Icons.history,
              label: l10n.stockHistory,
              onTap: () => run(onHistory),
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
              sublabel: l10n.itemRestoreWithin(30),
              danger: true,
              onTap: () => run(onDelete),
            ),
          ],
        ),
      );
    },
  );
}
