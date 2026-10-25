import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_image_view.dart';
import '../widgets/move_item_sheet.dart';
import '../widgets/stock_history_sheet.dart';
import '../widgets/item_attributes_card.dart';
import '../widgets/item_detail_cards.dart';
import '../widgets/item_stock_sheets.dart';
import 'item_create_screen.dart';
import 'lending_tracker_screen.dart';

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
      AppFeedback.showSuccess(context, 'Returned "${item.name}" to storage');
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
        AppFeedback.showSuccess(context, 'Returned "${item.name}" to storage$boxName');
      }
    } else {
      final updated = item.copyWith(status: ItemStatus.stored);
      final success = await provider.updateItem(updated);
      if (success && context.mounted) {
        AppFeedback.showSuccess(context, 'Moved "${item.name}" back to storage');
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
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Item not found or has been deleted', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
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
          backgroundColor: const Color(0xFFF8F9FA),
          body: CustomScrollView(
            slivers: [
              // Custom Silver App Bar with Hero Image Carousel
              SliverAppBar(
                expandedHeight: item.photos.isNotEmpty ? 340 : 160,
                pinned: true,
                backgroundColor: const Color(0xFF18181B),
                systemOverlayStyle: SystemUiOverlayStyle.light,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.85),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF18181B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.85),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 20, color: Color(0xFF18181B)),
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
                          final confirm = await AppFeedback.showConfirmDialog(
                            context,
                            title: 'Delete Item',
                            message: 'Are you sure you want to permanently delete "${item.name}"?',
                            confirmLabel: 'Delete',
                            isDestructive: true,
                            icon: Icons.delete_outline,
                          );
                          if (confirm && context.mounted) {
                            provider.deleteItem(item.id);
                            Navigator.pop(context);
                            AppFeedback.showSuccess(context, 'Item deleted');
                          }
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 12),
                              Text('Edit Item Details'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'move',
                          child: Row(
                            children: [
                              Icon(Icons.drive_file_move_outlined, size: 20),
                              SizedBox(width: 12),
                              Text('Move Location'),
                            ],
                          ),
                        ),
                        if (item.status != ItemStatus.lent)
                          const PopupMenuItem(
                            value: 'lend',
                            child: Row(
                              children: [
                                Icon(Icons.handshake_outlined, size: 20),
                                SizedBox(width: 12),
                                Text('Lend Item'),
                              ],
                            ),
                          ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              SizedBox(width: 12),
                              Text('Delete Item', style: TextStyle(color: Colors.red)),
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
                                return GestureDetector(
                                  onTap: () => showFullScreenImage(context, photoUrl),
                                  child: AppImageView(
                                    imageUrlOrPath: photoUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: Container(
                                      color: const Color(0xFF27272A),
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
                                            ? Colors.white
                                            : Colors.white.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Container(
                          color: const Color(0xFF18181B),
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
                              color: const Color(0xFFF4F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CategoryHelper.getCategoryIcon(item.categoryId),
                                  size: 13,
                                  color: const Color(0xFF18181B),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  item.categoryId,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF18181B),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (item.isConsumable)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shopping_basket_outlined, size: 13, color: Color(0xFF2563EB)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Consumable',
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
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFCD34D)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFD97706)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Low Stock',
                                    style: TextStyle(
                                      color: Color(0xFFB45309),
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
                                tooltip: 'Stock history',
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.history, size: 20),
                                onPressed: () => StockHistorySheet.show(context, item),
                              ),
                          GestureDetector(
                            onTap: item.isConsumable
                                ? () => showConsumeSheet(context, item, provider)
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF18181B),
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
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF18181B),
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
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ] else
                        const SizedBox(height: 14),

                      // If currently Lent: Show Prominent Loan Details Card (Module 6)
                      if (item.status == ItemStatus.lent && activeLoan != null) ...[
                        buildActiveLoanCard(context, provider, activeLoan),
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
              color: Colors.white,
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
                      side: const BorderSide(color: Color(0xFF18181B), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _showMoveItemDialog(context, item),
                    icon: const Icon(Icons.drive_file_move_outlined, size: 18, color: Color(0xFF18181B)),
                    label: const Text('Move', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF18181B))),
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
                                : const Color(0xFF18181B),
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
                                ? 'Out of Stock (Restock)'
                                : 'Consume (${item.unit})',
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
                                ? 'Return to Storage'
                                : item.status == ItemStatus.stored
                                    ? 'Take Out to Use'
                                    : 'Return to Storage',
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
