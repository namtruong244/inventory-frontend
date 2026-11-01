import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../screens/box_create_screen.dart';
import '../screens/item_create_screen.dart';
import '../screens/qr_display_screen.dart';
import '../theme/app_theme.dart';
import 'app_feedback.dart';
import 'export_barcodes_sheet.dart';
import 'move_location_dialog.dart';
import 'soft_sheet.dart';
import 'trash_actions.dart';

/// Everything that can be done to a location: the "…" menu of the box detail
/// page and the long-press menu of box rows. Each action runs after the sheet
/// closed. [closeScreenOnDelete] pops the page underneath once the box is gone
/// (the detail page of that box).
Future<void> showStorageActionsSheet(
  BuildContext context,
  Box box, {
  bool closeScreenOnDelete = false,
}) {
  final l10n = context.l10n;
  final provider = context.read<InventoryProvider>();
  final itemCount = provider.countTotalItemsIn(box.id);
  final containerCount = provider.getBoxesIn(box.id).length;
  final items = l10n.itemsCountLabel(itemCount);
  final containers = l10n.containersCountLabel(containerCount);

  final path = [
    for (final b in provider.getBreadcrumb(box.id))
      if (b.id != box.id) b.name,
    box.type.displayName,
  ].join(' › ');
  final contents = switch ((itemCount > 0, containerCount > 0)) {
    (true, true) => l10n.storageDeleteHintBoth(items, containers),
    (true, false) => items,
    (false, true) => containers,
    (false, false) => null,
  };

  void push(WidgetBuilder builder) =>
      Navigator.push(context, MaterialPageRoute(builder: builder));

  Future<void> delete() async {
    final confirmed = await TrashActions.confirm(
      context,
      name: box.name,
      isBox: true,
      hasContents: contents != null,
    );
    if (!confirmed || !context.mounted) return;
    final ok = await provider.deleteBox(box.id, cascade: true);
    if (!context.mounted) return;
    if (ok) {
      if (closeScreenOnDelete) Navigator.pop(context);
      TrashActions.showMoved(context, provider, name: box.name, boxId: box.id);
    } else {
      AppFeedback.showError(context, l10n.couldNotDeletePleaseTry(box.name));
    }
  }

  return showSoftSheet<void>(
    context,
    title: box.name,
    subtitle: '$path · $items · $containers',
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
              id: 'box_menu_add_item',
              icon: Icons.view_in_ar_outlined,
              tone: AppTones.matcha,
              toneBackground: AppTones.matchaSoft,
              label: l10n.storageActionAddItem,
              onTap: () =>
                  run(() => push((_) => ItemCreateScreen(boxId: box.id))),
            ),
            SoftSheetActionRow(
              id: 'box_menu_add_container',
              icon: Icons.create_new_folder_outlined,
              tone: AppTones.sky,
              toneBackground: AppTones.skySoft,
              label: l10n.storageActionAddContainer,
              onTap: () =>
                  run(() => push((_) => BoxCreateScreen(parentId: box.id))),
            ),
            SoftSheetActionRow(
              id: 'box_menu_move',
              icon: Icons.open_with_rounded,
              label: l10n.storageActionMove,
              onTap: () => run(() => MoveLocationDialog.show(context, box)),
            ),
            SoftSheetActionRow(
              id: 'box_menu_edit',
              icon: Icons.edit_outlined,
              label: l10n.storageActionEdit,
              onTap: () =>
                  run(() => push((_) => BoxCreateScreen(existingBox: box))),
            ),
            SoftSheetActionRow(
              id: 'box_menu_qr',
              icon: Icons.qr_code_2_rounded,
              label: l10n.storageActionQr,
              onTap: () => run(() => push((_) => QRDisplayScreen(box: box))),
            ),
            SoftSheetActionRow(
              id: 'box_menu_export',
              icon: Icons.file_download_outlined,
              label: l10n.storageActionExport,
              onTap: () => run(() => ExportBarcodesSheet.show(context, box.id)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Divider(height: 1, color: c.border),
            ),
            SoftSheetActionRow(
              id: 'box_menu_delete',
              icon: Icons.delete_outline_rounded,
              tone: c.dangerStrong,
              toneBackground: c.dangerSoft,
              label: l10n.storageActionDelete,
              sublabel: contents == null
                  ? l10n.itemRestoreWithin(TrashActions.retentionDays)
                  : l10n.storageDeleteHintContents(contents),
              danger: true,
              onTap: () => run(delete),
            ),
          ],
        ),
      );
    },
  );
}
