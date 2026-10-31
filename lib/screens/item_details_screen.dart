import 'package:flutter/material.dart';

import '../utils/e2e.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/trash_actions.dart';
import '../widgets/move_item_sheet.dart';
import '../widgets/stock_history_sheet.dart';
import '../widgets/item_attributes_card.dart';
import '../widgets/item_detail_cards.dart';
import '../widgets/item_stock_sheets.dart';
import '../widgets/item_actions_sheet.dart';
import '../widgets/item_card_parts.dart';
import '../widgets/item_hero_header.dart';
import 'item_create_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/lend_item_sheet.dart';
import '../l10n/l10n_ext.dart';
import '../widgets/app_icon.dart';
import '../widgets/soft_ui.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailsScreen({super.key, required this.itemId});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _showMoveItemDialog(BuildContext context, Item item) {
    MoveItemSheet.show(context, item);
  }

  Future<void> _handleStatusToggle(
    BuildContext context,
    Item item,
    InventoryProvider provider,
    LendingRecord? activeLoan,
  ) async {
    if (item.status == ItemStatus.lent && activeLoan != null) {
      await confirmAndReturnLoan(context, activeLoan, itemName: item.name);
      return;
    }

    if (item.status == ItemStatus.stored) {
      final updated = item.copyWith(status: ItemStatus.inUse);
      final success = await provider.updateItem(updated);
      if (success && context.mounted) {
        AppFeedback.showSuccess(context, context.l10n.itemNowInUse(item.name));
      }
    } else if (item.status == ItemStatus.inUse) {
      final updated = item.copyWith(status: ItemStatus.stored);
      final success = await provider.updateItem(updated);
      if (success && context.mounted) {
        final parentBox = provider.getBoxById(item.boxId);
        final boxName = parentBox != null ? ' "${parentBox.name}"' : '';
        AppFeedback.showSuccess(
          context,
          context.l10n.returnedToStorage2(item.name, boxName),
        );
      }
    } else {
      final updated = item.copyWith(status: ItemStatus.stored);
      final success = await provider.updateItem(updated);
      if (success && context.mounted) {
        AppFeedback.showSuccess(
          context,
          context.l10n.movedBackToStorage(item.name),
        );
      }
    }
  }

  Future<void> _mainAction(
    BuildContext context,
    Item item,
    InventoryProvider provider,
    LendingRecord? activeLoan,
  ) async {
    if (item.isConsumable) {
      if (item.quantity <= 0) {
        showRestockSheet(context, item, provider);
      } else {
        showConsumeSheet(context, item, provider);
      }
      return;
    }
    await _handleStatusToggle(context, item, provider, activeLoan);
  }

  Future<void> _deleteItem(
    BuildContext context,
    Item item,
    InventoryProvider provider,
  ) async {
    final confirm = await TrashActions.confirm(context, name: item.name);
    if (!confirm || !context.mounted) return;
    final ok = await provider.deleteItem(item.id);
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context);
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

  void _edit(BuildContext context, Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemCreateScreen(boxId: item.boxId, existingItem: item),
      ),
    );
  }

  void _showItemOptionsMenu(
    BuildContext context,
    Item item,
    InventoryProvider provider,
    LendingRecord? activeLoan,
  ) {
    final crumbs = item.boxId.isEmpty
        ? <Box>[]
        : provider.getBreadcrumb(item.boxId);
    final where = crumbs.map((b) => b.name).join(' › ');
    showItemActionsSheet(
      context,
      item: item,
      subtitle: where.isEmpty
          ? item.status.displayName
          : '$where · ${item.status.displayName}',
      onMainAction: () => _mainAction(context, item, provider, activeLoan),
      onMove: () => _showMoveItemDialog(context, item),
      onEdit: () => _edit(context, item),
      onLend: () => LendItemSheet.show(context, initialItem: item),
      onHistory: () => StockHistorySheet.show(context, item),
      onDelete: () => _deleteItem(context, item, provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        final item = provider.getItemById(widget.itemId);
        if (item == null) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: context.colors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.itemNotFoundOrHas,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.goBack),
                  ),
                ],
              ),
            ),
          );
        }

        final parentBox = provider.getBoxById(item.boxId);
        final breadcrumbs = parentBox != null
            ? provider.getBreadcrumb(parentBox.id)
            : <Box>[];
        final activeLoan = provider.getActiveLoanForItem(item.id);

        final loans = provider.getActiveLoansForItem(item.id);
        final c = context.colors;
        final top = MediaQuery.paddingOf(context).top;
        final overdueLoan = loans.where((l) => l.isOverdue).firstOrNull;
        final overdueDays = overdueLoan?.expectedReturnDate == null
            ? 0
            : -daysBetweenToday(overdueLoan!.expectedReturnDate!);
        final mainLabel = item.isConsumable
            ? (item.quantity <= 0
                  ? context.l10n.outOfStockRestock
                  : context.l10n.commonConsume(item.unit))
            : switch (item.status) {
                ItemStatus.lent => context.l10n.itemMarkReturned,
                ItemStatus.stored => context.l10n.takeOutToUse,
                _ => context.l10n.returnToStorage,
              };
        final mainIcon = item.isConsumable
            ? (item.quantity <= 0
                  ? Icons.add_shopping_cart_outlined
                  : Icons.remove_circle_outline)
            : switch (item.status) {
                ItemStatus.lent => Icons.assignment_turned_in_outlined,
                ItemStatus.stored => Icons.outbox_rounded,
                _ => Icons.inventory_2_outlined,
              };
        final overlay = Theme.of(context).brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: Scaffold(
            backgroundColor: c.background,
            body: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scroll,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.paddingOf(context).bottom + 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ItemHeroHeader(item: item),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ItemTitleBlock(
                              item: item,
                              quantityText: provider.formatQty(
                                item.quantity,
                                item.unit,
                              ),
                              overdueDays: overdueLoan == null
                                  ? null
                                  : overdueDays,
                            ),
                            const SizedBox(height: 16),
                            e2eId(
                              'item_main_action',
                              SoftButton(
                                expand: true,
                                icon: mainIcon,
                                label: mainLabel,
                                onPressed: () => _mainAction(
                                  context,
                                  item,
                                  provider,
                                  activeLoan,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: e2eId(
                                    'item_move',
                                    ItemActionTile(
                                      icon: Icons.drive_file_move_outlined,
                                      label: context.l10n.commonMove,
                                      onTap: () =>
                                          _showMoveItemDialog(context, item),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: e2eId(
                                    'item_edit',
                                    ItemActionTile(
                                      icon: Icons.edit_outlined,
                                      label: context.l10n.commonEdit,
                                      onTap: () => _edit(context, item),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: e2eId(
                                    'item_history',
                                    ItemActionTile(
                                      icon: Icons.history,
                                      label: context.l10n.itemHistoryLabel,
                                      onTap: () =>
                                          StockHistorySheet.show(context, item),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            for (final loan in loans) ...[
                              buildActiveLoanCard(context, provider, loan),
                              const SizedBox(height: 16),
                            ],
                            buildStorageLocationCard(
                              context,
                              provider,
                              item,
                              parentBox,
                              breadcrumbs,
                            ),
                            const SizedBox(height: 16),
                            if (item.expiryDate != null) ...[
                              buildExpiryCard(context, item),
                              const SizedBox(height: 16),
                            ],
                            if (item.isLowStock) ...[
                              buildLowStockCard(context, item),
                              const SizedBox(height: 16),
                            ],
                            if (item.warrantyExpiryDate != null) ...[
                              buildWarrantyCard(context, item),
                              const SizedBox(height: 16),
                            ],
                            buildPurchaseInfoCard(context, item),
                            const SizedBox(height: 16),
                            buildCustomAttributesCard(context, item),
                            const SizedBox(height: 16),
                            if (item.receiptPhotos.isNotEmpty) ...[
                              buildReceiptsCard(context, item.receiptPhotos),
                              const SizedBox(height: 16),
                            ],
                            ItemStockHistoryRow(
                              onTap: () =>
                                  StockHistorySheet.show(context, item),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _scroll,
                    builder: (context, _) {
                      final heroH = item.photos.isEmpty ? 240.0 : 330.0;
                      final offset = _scroll.hasClients ? _scroll.offset : 0.0;
                      final t = ((offset - (heroH - top - 80)) / 40).clamp(
                        0.0,
                        1.0,
                      );
                      return IgnorePointer(
                        child: Opacity(
                          opacity: t,
                          child: Container(
                            height: top + 60,
                            color: c.background,
                            padding: EdgeInsets.fromLTRB(80, top, 80, 0),
                            alignment: Alignment.center,
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: top + 4,
                  left: 24,
                  child: SoftCircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: MaterialLocalizations.of(context)
                        .backButtonTooltip,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: top + 4,
                  right: 24,
                  child: e2eId(
                    'item_options',
                    SoftCircleButton(
                      icon: Icons.more_horiz_rounded,
                      tooltip: context.l10n.moreOptions,
                      onTap: () => _showItemOptionsMenu(
                        context,
                        item,
                        provider,
                        activeLoan,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
