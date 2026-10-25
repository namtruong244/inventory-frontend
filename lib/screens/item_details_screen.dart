import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/trash_actions.dart';
import '../widgets/app_image_view.dart';
import '../widgets/move_item_sheet.dart';
import '../widgets/stock_history_sheet.dart';
import '../widgets/item_attributes_card.dart';
import '../widgets/item_detail_cards.dart';
import '../widgets/item_stock_sheets.dart';
import 'item_create_screen.dart';
import 'lending_tracker_screen.dart';
import '../widgets/tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailsScreen({super.key, required this.itemId});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int _currentPhotoIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
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
      provider.returnItem(activeLoan.id);
      AppFeedback.showSuccess(context, context.l10n.returnedToStorage(item.name));
      return;
    }

    if (item.status == ItemStatus.stored) {
      final updated = item.copyWith(status: ItemStatus.inUse);
      final success = await provider.updateItem(updated);
      if (success && context.mounted) {
        AppFeedback.showSuccess(context, '"${item.name}" is now in use');
      }
    } else if (item.status == ItemStatus.inUse) {
      final updated = item.copyWith(status: ItemStatus.stored);
      final success = await provider.updateItem(updated);
      if (success && context.mounted) {
        final parentBox = provider.getBoxById(item.boxId);
        final boxName = parentBox != null ? ' "${parentBox.name}"' : '';
        AppFeedback.showSuccess(context, context.l10n.returnedToStorage2(item.name, boxName));
      }
    } else {
      final updated = item.copyWith(status: ItemStatus.stored);
      final success = await provider.updateItem(updated);
      if (success && context.mounted) {
        AppFeedback.showSuccess(context, context.l10n.movedBackToStorage(item.name));
      }
    }
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
                  Icon(Icons.inventory_2_outlined, size: 64, color: context.colors.textMuted),
                  const SizedBox(height: 16),
                  Text(context.l10n.itemNotFoundOrHas, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
        final breadcrumbs = parentBox != null ? provider.getBreadcrumb(parentBox.id) : <Box>[];
        final activeLoan = provider.getActiveLoanForItem(item.id);

        return Scaffold(
          backgroundColor: context.colors.background,
          body: CustomScrollView(
            slivers: [
              // Custom Silver App Bar with Hero Image Carousel
              SliverAppBar(
                expandedHeight: item.photos.isNotEmpty ? 340 : 160,
                pinned: true,
                backgroundColor: context.colors.primary,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: context.colors.surface.withValues(alpha: 0.85),
                    child: IconButton(
 tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: context.colors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  CircleAvatar(
                    backgroundColor: context.colors.surface.withValues(alpha: 0.85),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, size: 20, color: context.colors.textPrimary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onSelected: (val) async {
                        if (val == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemCreateScreen(boxId: item.boxId, existingItem: item),
                            ),
                          );
                        } else if (val == 'move') {
                          _showMoveItemDialog(context, item);
                        } else if (val == 'lend') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LendingTrackerScreen()),
                          );
                        } else if (val == 'delete') {
                          final confirm = await TrashActions.confirm(context, name: item.name);
                          if (confirm && context.mounted) {
                            final ok = await provider.deleteItem(item.id);
                            if (!context.mounted) return;
                            if (ok) {
                              Navigator.pop(context);
                              TrashActions.showMoved(context, provider, name: item.name, itemId: item.id);
                            } else {
                              AppFeedback.showError(context, context.l10n.couldNotDeletePleaseTry2(item.name));
                            }
                          }
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 12),
                              Text(context.l10n.editItemDetails),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'move',
                          child: Row(
                            children: [
                              Icon(Icons.drive_file_move_outlined, size: 20),
                              SizedBox(width: 12),
                              Text(context.l10n.moveLocation),
                            ],
                          ),
                        ),
                        if (item.status != ItemStatus.lent)
                          PopupMenuItem(
                            value: 'lend',
                            child: Row(
                              children: [
                                Icon(Icons.handshake_outlined, size: 20),
                                SizedBox(width: 12),
                                Text(context.l10n.lendItem),
                              ],
                            ),
                          ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              SizedBox(width: 12),
                              Text(context.l10n.deleteItem, style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: item.photos.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: item.photos.length,
                              onPageChanged: (idx) => setState(() => _currentPhotoIndex = idx),
                              itemBuilder: (context, idx) {
                                final photoUrl = item.photos[idx];
                                return Tappable(
                                  onTap: () => showFullScreenImage(context, photoUrl),
                                  child: AppImageView(
                                    imageUrlOrPath: photoUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: Container(
                                      color: context.colors.primary,
                                      child: const Center(
                                        child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Gradient shadow on top and bottom
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: 120,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.75),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Page Indicator Dots
                            if (item.photos.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    item.photos.length,
                                    (idx) => AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: _currentPhotoIndex == idx ? 20 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _currentPhotoIndex == idx
                                            ? context.colors.surface
                                            : context.colors.surface.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Container(
                          color: context.colors.primary,
                          child: const Center(
                            child: Icon(Icons.image_outlined, size: 64, color: Colors.white24),
                          ),
                        ),
                ),
              ),

              // Product Information Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & Category Badges (using Wrap to prevent RenderFlex overflow)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: item.status.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(item.status.icon, size: 14, color: item.status.color),
                                const SizedBox(width: 6),
                                Text(
                                  item.status.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: item.status.color,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: context.colors.fill,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CategoryHelper.getCategoryIcon(item.categoryId),
                                  size: 13,
                                  color: context.colors.textPrimary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  item.categoryId,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (item.isConsumable)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: context.colors.infoSoft,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shopping_basket_outlined, size: 13, color: Color(0xFF2563EB)),
                                  SizedBox(width: 4),
                                  Text(
                                    context.l10n.commonConsumable,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (item.isLowStock)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: context.colors.warningSoft,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFCD34D)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFD97706)),
                                  SizedBox(width: 4),
                                  Text(
                                    context.l10n.settingsLowStock,
                                    style: TextStyle(
                                      color: context.colors.warningStrong,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Quantity Pill
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: context.l10n.stockHistory,
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.history, size: 20),
                                onPressed: () => StockHistorySheet.show(context, item),
                              ),
                          Tappable(
                            onTap: item.isConsumable
                                ? () => showConsumeSheet(context, item, provider)
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: context.colors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    provider.formatQty(item.quantity, item.unit),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (item.isConsumable) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.touch_app_outlined, size: 12, color: Colors.white70),
                                  ],
                                ],
                              ),
                            ),
                          ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Product Title
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: context.colors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      if (item.description.isNotEmpty) ...[
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ] else
                        const SizedBox(height: 14),

                      // If currently Lent: Show Prominent Loan Details Card (Module 6)
                      for (final loan in provider.getActiveLoansForItem(item.id)) ...[
                        buildActiveLoanCard(context, provider, loan),
                        const SizedBox(height: 20),
                      ],

                      // Storage Location & Breadcrumb Card (Module 1 & 4)
                      buildStorageLocationCard(context, provider, item, parentBox, breadcrumbs),
                      const SizedBox(height: 20),

                      // Expiry Warning Alert Banner (Module 5)
                      if (item.expiryDate != null) ...[
                        buildExpiryCard(context, item),
                        const SizedBox(height: 20),
                      ],

                      // Low Stock Alert Banner (Custom per-item threshold)
                      if (item.isLowStock) ...[
                        buildLowStockCard(context, item),
                        const SizedBox(height: 20),
                      ],

                      // Asset & Warranty Details Card (Module 2 & 5)
                      buildAssetDetailsCard(context, item),
                      const SizedBox(height: 20),

                      // Custom Attributes Card (Module 2)
                      buildCustomAttributesCard(context, item),
                      const SizedBox(height: 20),

                      // Receipt & Warranty Proof Photos
                      if (item.receiptPhotos.isNotEmpty) ...[
                        buildReceiptsCard(context, item.receiptPhotos),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom Sticky Action Bar
          bottomSheet: Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: context.colors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Move button
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: context.colors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _showMoveItemDialog(context, item),
                    icon: Icon(Icons.drive_file_move_outlined, size: 18, color: context.colors.textPrimary),
                    label: Text(context.l10n.commonMove, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
                  ),
                ),
                const SizedBox(width: 12),

                // Main Action Button (Dynamic based on isConsumable & status)
                Expanded(
                  flex: 2,
                  child: item.isConsumable
                      ? ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.quantity <= 0
                                ? const Color(0xFFD97706)
                                : context.colors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            if (item.quantity <= 0) {
                              showRestockSheet(context, item, provider);
                            } else {
                              showConsumeSheet(context, item, provider);
                            }
                          },
                          icon: Icon(
                            item.quantity <= 0
                                ? Icons.add_shopping_cart_outlined
                                : Icons.remove_circle_outline,
                            size: 18,
                          ),
                          label: Text(
                            item.quantity <= 0
                                ? context.l10n.outOfStockRestock
                                : context.l10n.commonConsume(item.unit),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.status == ItemStatus.lent
                                ? const Color(0xFF10B981)
                                : item.status == ItemStatus.stored
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => _handleStatusToggle(context, item, provider, activeLoan),
                          icon: Icon(
                            item.status == ItemStatus.lent
                                ? Icons.assignment_turned_in_outlined
                                : item.status == ItemStatus.stored
                                    ? Icons.outbox_rounded
                                    : Icons.inventory_2_outlined,
                            size: 18,
                          ),
                          label: Text(
                            item.status == ItemStatus.lent
                                ? context.l10n.returnToStorage
                                : item.status == ItemStatus.stored
                                    ? context.l10n.takeOutToUse
                                    : context.l10n.returnToStorage,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
