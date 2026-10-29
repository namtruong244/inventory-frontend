import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../screens/box_create_screen.dart';
import '../screens/item_create_screen.dart';
import '../l10n/l10n_ext.dart';
import 'location_picker_sheet.dart';

/// The box the user filed something into most recently: the best guess for the next item.
String? lastUsedBoxId(InventoryProvider provider) {
  if (provider.items.isEmpty) return null;
  final newest = provider.items.reduce(
    (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
  );
  return provider.getBoxById(newest.boxId) != null ? newest.boxId : null;
}

/// "Add an item" from anywhere: pick the location (pre-selecting the last one used), then
/// open the item form. With no location yet the user is sent to create one first.
Future<void> startAddItemFlow(BuildContext context) async {
  final provider = context.read<InventoryProvider>();
  final navigator = Navigator.of(context);
  if (provider.boxes.isEmpty) {
    await navigator.push(
      MaterialPageRoute(builder: (_) => const BoxCreateScreen()),
    );
    return;
  }
  final box = await LocationPickerSheet.show(
    context,
    initialBoxId: lastUsedBoxId(provider),
    title: context.l10n.selectDestinationContainer,
    subtitle: context.l10n.chooseContainerOrScanIts,
    confirmButtonText: context.l10n.addItemHere,
  );
  if (box == null) return;
  await navigator.push(
    MaterialPageRoute(builder: (_) => ItemCreateScreen(boxId: box.id)),
  );
}
