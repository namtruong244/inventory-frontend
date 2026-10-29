import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import 'location_picker_sheet.dart';
import '../l10n/l10n_ext.dart';

/// Moving an item is picking its new location in [LocationPickerSheet] and applying it.
class MoveItemSheet {
  MoveItemSheet._();

  static Future<bool?> show(BuildContext context, Item item) async {
    final pickedBox = await LocationPickerSheet.show(
      context,
      initialBoxId: item.boxId,
      currentBoxId: item.boxId,
      title: context.l10n.moveItemLocation,
      subtitle: context.l10n.selectNewStorageDestinationFor(item.name),
      confirmButtonText: context.l10n.confirmMove,
    );

    if (pickedBox != null && pickedBox.id != item.boxId && context.mounted) {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      final ok = await provider.moveItem(item.id, pickedBox.id);
      if (!context.mounted) return ok;
      if (ok) {
        AppFeedback.showSuccess(
          context,
          context.l10n.movedTo(item.name, pickedBox.name),
        );
      } else {
        AppFeedback.showError(
          context,
          context.l10n.somethingWentWrongPleaseTry,
        );
      }
      return ok;
    }
    return false;
  }
}
