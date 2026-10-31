import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../screens/item_create_screen.dart';
import '../screens/item_details_screen.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_feedback.dart';
import 'app_icon.dart';
import 'item_box_actions.dart';
import 'item_card.dart';
import 'lend_item_sheet.dart';
import 'move_item_sheet.dart';
import 'soft_ui.dart';
import 'trash_actions.dart';

/// Title + "N assets tracked" subtitle of the Item tab.
class ItemsListHeader extends StatelessWidget {
  final int count;
  const ItemsListHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.itemCatalog,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          context.l10n.assetsTracked(count),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: c.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Pill "pin · All storage locations · caret" that opens a menu of boxes.
class ItemsLocationFilter extends StatelessWidget {
  final List<Box> boxes;
  final String? selectedBoxId;
  final ValueChanged<String?> onChanged;

  const ItemsLocationFilter({
    super.key,
    required this.boxes,
    required this.selectedBoxId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = boxes.where((b) => b.id == selectedBoxId).firstOrNull;
    final label = selected == null
        ? context.l10n.allStorageLocations
        : '${selected.type.displayName}: ${selected.name}';
    return Align(
      alignment: Alignment.centerLeft,
      child: e2eId(
        'items_location_filter',
        PopupMenuButton<String?>(
          tooltip: context.l10n.allStorageLocations,
          position: PopupMenuPosition.under,
          color: c.surface,
          initialValue: selectedBoxId,
          onSelected: onChanged,
          constraints: const BoxConstraints(maxHeight: 420, minWidth: 220),
          itemBuilder: (_) => [
            PopupMenuItem<String?>(
              value: null,
              child: Text(context.l10n.allStorageLocations),
            ),
            ...boxes.map(
              (b) => PopupMenuItem<String?>(
                value: b.id,
                child: Text('${b.type.displayName}: ${b.name}'),
              ),
            ),
          ],
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: c.fill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: c.textPrimary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                AppIcon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: c.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One row of the item list: [ItemCard] with the swipe actions
/// (move, lend/return, edit, delete).
class ItemListTile extends StatelessWidget {
  final Item item;
  final InventoryProvider provider;
  final String locationPath;

  const ItemListTile({
    super.key,
    required this.item,
    required this.provider,
    required this.locationPath,
  });

  @override
  Widget build(BuildContext context) {
    final tags = <Widget>[
      if (item.isLowStock)
        SoftChip.tone(
          context.l10n.tagLowStock,
          AppTones.amber,
          icon: Icons.production_quantity_limits_rounded,
        ),
      if (item.isExpired)
        SoftChip.tone(
          context.l10n.tagExpired,
          AppTones.coral,
          icon: Icons.event_busy_outlined,
        )
      else if (item.daysUntilExpiry != null && item.daysUntilExpiry! <= 30)
        SoftChip.tone(
          context.l10n.expiresInShort(item.daysUntilExpiry!),
          AppTones.amber,
          icon: Icons.event_outlined,
        ),
    ];

    return SoftCard(
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.85,
          children: [
            SlidableAction(
              onPressed: (_) => MoveItemSheet.show(context, item),
              backgroundColor: AppTones.lilac,
              foregroundColor: Colors.white,
              icon: Icons.drive_file_move_outlined,
              label: context.l10n.commonMove,
            ),
            if (item.status == ItemStatus.lent)
              SlidableAction(
                onPressed: (_) {
                  final loan = provider.getActiveLoanForItem(item.id);
                  if (loan != null) {
                    confirmAndReturnLoan(context, loan, itemName: item.name);
                  }
                },
                backgroundColor: AppTones.matcha,
                foregroundColor: Colors.white,
                icon: Icons.assignment_turned_in_outlined,
                label: context.l10n.commonReturn,
              )
            else
              SlidableAction(
                onPressed: (_) =>
                    LendItemSheet.show(context, initialItem: item),
                backgroundColor: AppTones.amber,
                foregroundColor: Colors.white,
                icon: Icons.assignment_ind_outlined,
                label: context.l10n.commonLend,
              ),
            SlidableAction(
              onPressed: (_) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ItemCreateScreen(boxId: item.boxId, existingItem: item),
                ),
              ),
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              icon: Icons.edit_outlined,
              label: context.l10n.commonEdit,
            ),
            SlidableAction(
              onPressed: (_) => _delete(context),
              backgroundColor: AppTones.coral,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: context.l10n.commonDelete,
            ),
          ],
        ),
        child: ItemCard(
          id: 'item_card_${item.name}',
          name: item.name,
          description: '',
          locationPath: locationPath.isEmpty ? null : locationPath,
          quantityText: provider.formatQty(item.quantity, item.unit),
          status: SoftChip.tone(
            item.status.displayName,
            item.status.color,
            dot: true,
          ),
          tags: tags,
          imageUrl: item.imageUrl,
          enableClip: false,
          onLongPress: () => showItemActionsSheet(context, item),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemDetailsScreen(itemId: item.id),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
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
  }
}
