import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../screens/box_create_screen.dart';
import '../screens/item_create_screen.dart';
import '../theme/app_theme.dart';
import 'app_feedback.dart';
import 'lend_item_sheet.dart';
import 'move_item_sheet.dart';
import 'move_location_dialog.dart';
import 'trash_actions.dart';
import 'app_icon.dart';

/// What can be done to an item, as a menu opened by long-pressing it. Swiping a row
/// stays as a shortcut, but nothing is only reachable by swiping.
Future<void> showItemActionsSheet(BuildContext context, Item item) {
  final provider = context.read<InventoryProvider>();
  final loan = item.status == ItemStatus.lent
      ? provider.getActiveLoanForItem(item.id)
      : null;
  return _showActions(
    context,
    title: item.name,
    actions: [
      _Action(
        Icons.drive_file_move_outlined,
        context.l10n.commonMove,
        () => MoveItemSheet.show(context, item),
      ),
      if (loan != null)
        _Action(
          Icons.assignment_turned_in_outlined,
          context.l10n.commonReturn,
          () => confirmAndReturnLoan(context, loan, itemName: item.name),
        )
      else if (item.status != ItemStatus.lent)
        _Action(
          Icons.assignment_ind_outlined,
          context.l10n.commonLend,
          () => LendItemSheet.show(context, initialItem: item),
        ),
      _Action(
        Icons.edit_outlined,
        context.l10n.commonEdit,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ItemCreateScreen(boxId: item.boxId, existingItem: item),
          ),
        ),
      ),
      _Action(Icons.delete_outline, context.l10n.commonDelete, () async {
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
          AppFeedback.showError(
            context,
            context.l10n.couldNotDeletePleaseTry2(item.name),
          );
        }
      }, destructive: true),
    ],
  );
}

/// The same menu for a location.
Future<void> showBoxActionsSheet(BuildContext context, Box box) {
  final provider = context.read<InventoryProvider>();
  return _showActions(
    context,
    title: box.name,
    actions: [
      _Action(
        Icons.add_box_outlined,
        context.l10n.addSubContainer,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BoxCreateScreen(parentId: box.id)),
        ),
      ),
      _Action(
        Icons.drive_file_move_outlined,
        context.l10n.commonMove,
        () => MoveLocationDialog.show(context, box),
      ),
      _Action(
        Icons.edit_outlined,
        context.l10n.commonEdit,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BoxCreateScreen(existingBox: box)),
        ),
      ),
      _Action(Icons.delete_outline, context.l10n.commonDelete, () async {
        final confirmed = await TrashActions.confirm(
          context,
          name: box.name,
          isBox: true,
          hasContents: true,
        );
        if (!confirmed || !context.mounted) return;
        final ok = await provider.deleteBox(box.id, cascade: true);
        if (!context.mounted) return;
        if (ok) {
          TrashActions.showMoved(
            context,
            provider,
            name: box.name,
            boxId: box.id,
          );
        } else {
          AppFeedback.showError(
            context,
            context.l10n.couldNotDeletePleaseTry2(box.name),
          );
        }
      }, destructive: true),
    ],
  );
}

class _Action {
  final IconData icon;
  final String label;
  final FutureOr<void> Function() run;
  final bool destructive;
  const _Action(this.icon, this.label, this.run, {this.destructive = false});
}

Future<void> _showActions(
  BuildContext context, {
  required String title,
  required List<_Action> actions,
}) {
  final c = context.colors;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Material(
      color: c.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ),
            for (final action in actions)
              ListTile(
                leading: AppIcon(
                  action.icon,
                  color: action.destructive ? c.dangerStrong : c.textPrimary,
                ),
                title: Text(
                  action.label,
                  style: TextStyle(
                    color: action.destructive ? c.dangerStrong : c.textPrimary,
                  ),
                ),
                onTap: () {
                  // Close the menu first so the action opens on the screen underneath.
                  Navigator.pop(sheetContext);
                  action.run();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
