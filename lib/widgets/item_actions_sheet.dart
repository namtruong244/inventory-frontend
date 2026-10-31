import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_icon.dart';
import 'soft_sheet.dart';
import 'soft_ui.dart';
import 'tappable.dart';

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
            _Row(
              id: 'item_menu_main',
              icon: mainIcon,
              tone: AppTones.sky,
              label: mainLabel,
              onTap: () => run(onMainAction),
            ),
            if (item.status != ItemStatus.lent)
              _Row(
                id: 'item_menu_lend',
                icon: Icons.handshake_outlined,
                tone: AppTones.amber,
                label: l10n.lendItem,
                onTap: () => run(onLend),
              ),
            _Row(
              id: 'item_menu_move',
              icon: Icons.drive_file_move_outlined,
              label: l10n.itemMoveToAnother,
              onTap: () => run(onMove),
            ),
            _Row(
              id: 'item_menu_edit',
              icon: Icons.edit_outlined,
              label: l10n.editItemDetails,
              onTap: () => run(onEdit),
            ),
            _Row(
              id: 'item_menu_history',
              icon: Icons.history,
              label: l10n.stockHistory,
              onTap: () => run(onHistory),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Divider(height: 1, color: c.border),
            ),
            _Row(
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

class _Row extends StatelessWidget {
  final String id;
  final IconData icon;
  final Color? tone;
  final String label;
  final String? sublabel;
  final bool danger;
  final VoidCallback onTap;

  const _Row({
    required this.id,
    required this.icon,
    required this.label,
    required this.onTap,
    this.tone,
    this.sublabel,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return e2eId(
      id,
      Tappable(
        semanticLabel: label,
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              SoftIconTile(icon, color: tone, size: 40),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: danger ? c.dangerStrong : c.textPrimary,
                      ),
                    ),
                    if (sublabel != null)
                      Text(
                        sublabel!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: c.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (!danger)
                AppIcon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: c.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
