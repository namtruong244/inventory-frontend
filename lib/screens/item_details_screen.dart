import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_image_view.dart';
import '../widgets/move_item_sheet.dart';
import '../widgets/stock_history_sheet.dart';
import 'box_details_screen.dart';
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

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AppImageView(
                  imageUrlOrPath: imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.6),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  void _showConsumeSheet(BuildContext context, Item item, InventoryProvider provider) {
    double consumeAmount = 1.0;
    if (item.quantity < 1.0 && item.quantity > 0) {
      consumeAmount = item.quantity;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final currentQty = item.quantity;
            final remainingAfter = (currentQty - consumeAmount).clamp(0.0, double.infinity);
            final formattedCurrent = currentQty % 1 == 0 ? currentQty.toInt().toString() : currentQty.toString();
            final formattedConsume = consumeAmount % 1 == 0 ? consumeAmount.toInt().toString() : consumeAmount.toString();
            final formattedRemain = remainingAfter % 1 == 0 ? remainingAfter.toInt().toString() : remainingAfter.toStringAsFixed(1);

            return Container(
              padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Consume: ${item.name}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Current stock: $formattedCurrent ${item.unit}',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stepper row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Quantity to use:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF18181B),
                              ),
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: consumeAmount > 1
                                  ? () => setSheetState(() => consumeAmount -= 1)
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$formattedConsume ${item.unit}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                              ),
                            ),
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF18181B),
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: consumeAmount < currentQty
                                  ? () => setSheetState(() => consumeAmount += 1)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick chips
                  Wrap(
                    spacing: 8,
                    children: [
                      if (currentQty >= 1)
                        ActionChip(
                          label: Text('Use 1 ${item.unit}'),
                          onPressed: () => setSheetState(() => consumeAmount = 1.0),
                          backgroundColor: consumeAmount == 1.0 ? const Color(0xFF18181B) : Colors.white,
                          labelStyle: TextStyle(
                            color: consumeAmount == 1.0 ? Colors.white : const Color(0xFF18181B),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      if (currentQty >= 2)
                        ActionChip(
                          label: Text('Use 2 ${item.unit}'),
                          onPressed: () => setSheetState(() => consumeAmount = 2.0),
                          backgroundColor: consumeAmount == 2.0 ? const Color(0xFF18181B) : Colors.white,
                          labelStyle: TextStyle(
                            color: consumeAmount == 2.0 ? Colors.white : const Color(0xFF18181B),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      if (currentQty >= 5)
                        ActionChip(
                          label: Text('Use 5 ${item.unit}'),
                          onPressed: () => setSheetState(() => consumeAmount = 5.0),
                          backgroundColor: consumeAmount == 5.0 ? const Color(0xFF18181B) : Colors.white,
                          labelStyle: TextStyle(
                            color: consumeAmount == 5.0 ? Colors.white : const Color(0xFF18181B),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ActionChip(
                        label: const Text('Use All'),
                        onPressed: () => setSheetState(() => consumeAmount = currentQty),
                        backgroundColor: consumeAmount == currentQty ? const Color(0xFFEF4444) : Colors.white,
                        labelStyle: TextStyle(
                          color: consumeAmount == currentQty ? Colors.white : const Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Remaining status preview
                  Row(
                    children: [
                      Icon(
                        remainingAfter == 0
                            ? Icons.error_outline_rounded
                            : (item.minQuantity != null && remainingAfter <= item.minQuantity!
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline_rounded),
                        size: 16,
                        color: remainingAfter == 0
                            ? Colors.red
                            : (item.minQuantity != null && remainingAfter <= item.minQuantity!
                                ? const Color(0xFFD97706)
                                : const Color(0xFF10B981)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        remainingAfter == 0
                            ? 'Will be out of stock after use'
                            : 'Remaining after use: $formattedRemain ${item.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: remainingAfter == 0
                              ? Colors.red
                              : (item.minQuantity != null && remainingAfter <= item.minQuantity!
                                  ? const Color(0xFFD97706)
                                  : Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Actions
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          side: const BorderSide(color: Color(0xFF18181B), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          _showRestockSheet(context, item, provider);
                        },
                        icon: const Icon(Icons.add_shopping_cart_outlined, size: 18, color: Color(0xFF18181B)),
                        label: const Text('Restock', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF18181B))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF18181B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () async {
                            Navigator.pop(sheetCtx);
                            final ok = await provider.updateItemQuantity(item.id, remainingAfter, reason: 'consume');
                            if (ok && context.mounted) {
                              AppFeedback.showSuccess(
                                context,
                                'Used $formattedConsume ${item.unit}. Remaining: $formattedRemain ${item.unit}',
                              );
                              if (item.minQuantity != null && remainingAfter <= item.minQuantity!) {
                                AppFeedback.showWarning(
                                  context,
                                  'Warning: Quantity has dropped to minimum level (≤ ${item.minQuantity} ${item.unit})',
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text(
                            'Confirm Use',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRestockSheet(BuildContext context, Item item, InventoryProvider provider) {
    double addAmount = 1.0;
    final controller = TextEditingController(text: '1');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final currentQty = item.quantity;
            final formattedCurrent = currentQty % 1 == 0 ? currentQty.toInt().toString() : currentQty.toString();

            return Container(
              padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.add_shopping_cart_outlined, color: Color(0xFF10B981), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Restock: ${item.name}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Current stock: $formattedCurrent ${item.unit}',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Quantity to add (${item.unit})',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      suffixText: item.unit,
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? 0;
                      setSheetState(() => addAmount = parsed);
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [1, 2, 5, 10].map((n) {
                      return ActionChip(
                        label: Text('+$n ${item.unit}'),
                        onPressed: () {
                          controller.text = n.toString();
                          setSheetState(() => addAmount = n.toDouble());
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: addAmount > 0
                          ? () async {
                              Navigator.pop(sheetCtx);
                              final newQty = item.quantity + addAmount;
                              final ok = await provider.updateItemQuantity(item.id, newQty, reason: 'restock');
                              if (ok && context.mounted) {
                                final formattedNew = newQty % 1 == 0 ? newQty.toInt().toString() : newQty.toString();
                                AppFeedback.showSuccess(
                                  context,
                                  'Added $addAmount ${item.unit}. Total: $formattedNew ${item.unit}',
                                );
                              }
                            }
                          : null,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Confirm Restock', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
                                  onTap: () => _showFullScreenImage(context, photoUrl),
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
                                ? () => _showConsumeSheet(context, item, provider)
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
                        _buildActiveLoanCard(context, provider, activeLoan),
                        const SizedBox(height: 20),
                      ],

                      // Storage Location & Breadcrumb Card (Module 1 & 4)
                      _buildStorageLocationCard(context, provider, item, parentBox, breadcrumbs),
                      const SizedBox(height: 20),

                      // Expiry Warning Alert Banner (Module 5)
                      if (item.expiryDate != null) ...[
                        _buildExpiryCard(context, item),
                        const SizedBox(height: 20),
                      ],

                      // Low Stock Alert Banner (Custom per-item threshold)
                      if (item.isLowStock) ...[
                        _buildLowStockCard(context, item),
                        const SizedBox(height: 20),
                      ],

                      // Asset & Warranty Details Card (Module 2 & 5)
                      _buildAssetDetailsCard(context, item),
                      const SizedBox(height: 20),

                      // Custom Attributes Card (Module 2)
                      _buildCustomAttributesCard(context, item),
                      const SizedBox(height: 20),

                      // Receipt & Warranty Proof Photos
                      if (item.receiptPhotos.isNotEmpty) ...[
                        _buildReceiptsCard(context, item.receiptPhotos),
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
                              _showRestockSheet(context, item, provider);
                            } else {
                              _showConsumeSheet(context, item, provider);
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

  Widget _buildActiveLoanCard(BuildContext context, InventoryProvider provider, LendingRecord loan) {
    final isOverdue = loan.isOverdue;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isOverdue ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOverdue ? const Color(0xFFFCA5A5) : const Color(0xFFBFDBFE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isOverdue ? Icons.warning_amber_rounded : Icons.handshake_outlined,
                    color: isOverdue ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOverdue ? 'Overdue Loan' : 'Currently Lent Out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isOverdue ? const Color(0xFF991B1B) : const Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
              if (isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'OVERDUE',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Borrower: ${loan.borrowerName}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          if (loan.borrowerContact.isNotEmpty)
            Text(
              'Contact: ${loan.borrowerContact}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          const SizedBox(height: 6),
          Text(
            'Lent on: ${DateFormat('MMM dd, yyyy').format(loan.lentDate)}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          if (loan.expectedReturnDate != null)
            Text(
              'Expected Return: ${DateFormat('MMM dd, yyyy').format(loan.expectedReturnDate!)}',
              style: TextStyle(
                color: isOverdue ? const Color(0xFFDC2626) : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStorageLocationCard(
    BuildContext context,
    InventoryProvider provider,
    Item item,
    Box? parentBox,
    List<Box> breadcrumbs,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF18181B)),
                  SizedBox(width: 8),
                  Text(
                    'Storage Location',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showMoveItemDialog(context, item),
                child: const Text(
                  'Change',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Interactive Smooth Horizontally Scrollable Breadcrumb Trail
          if (breadcrumbs.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (int i = 0; i < breadcrumbs.length; i++) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BoxDetailsScreen(boxId: breadcrumbs[i].id),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: i == breadcrumbs.length - 1
                              ? const Color(0xFF18181B)
                              : const Color(0xFFF4F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              breadcrumbs[i].type.icon,
                              size: 14,
                              color: i == breadcrumbs.length - 1 ? Colors.white : const Color(0xFF18181B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              breadcrumbs[i].name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: i == breadcrumbs.length - 1 ? Colors.white : const Color(0xFF18181B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < breadcrumbs.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey.shade400),
                      ),
                  ],
                ],
              ),
            )
          else
            Text(
              parentBox != null ? parentBox.name : 'Unknown Location',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildExpiryCard(BuildContext context, Item item) {
    final isExpired = item.isExpired;
    final daysLeft = item.daysUntilExpiry;

    Color bgColor;
    Color textColor;
    Color borderColor;
    String statusTitle;

    if (isExpired) {
      bgColor = const Color(0xFFFEF2F2);
      textColor = const Color(0xFFDC2626);
      borderColor = const Color(0xFFFCA5A5);
      statusTitle = 'Product has Expired!';
    } else if (daysLeft != null && daysLeft <= 15) {
      bgColor = const Color(0xFFFFFBEB);
      textColor = const Color(0xFFD97706);
      borderColor = const Color(0xFFFDE68A);
      statusTitle = 'Expires soon in $daysLeft days';
    } else {
      bgColor = const Color(0xFFF0FDF4);
      textColor = const Color(0xFF16A34A);
      borderColor = const Color(0xFFBBF7D0);
      statusTitle = 'Fresh • $daysLeft days remaining';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.event_busy_outlined, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Expiry date: ${DateFormat('MMMM dd, yyyy').format(item.expiryDate!)}',
                  style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockCard(BuildContext context, Item item) {
    final qty = item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity;
    final minQty = item.minQuantity! % 1 == 0 ? item.minQuantity!.toInt() : item.minQuantity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.production_quantity_limits_rounded, color: Color(0xFFD97706), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Low Stock Warning',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB45309), fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Current: $qty ${item.unit} • Threshold: ≤ $minQty ${item.unit}',
                  style: const TextStyle(color: Color(0xFF92400E), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetDetailsCard(BuildContext context, Item item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, size: 20, color: Color(0xFF18181B)),
              SizedBox(width: 8),
              Text(
                'Asset & Purchase Information',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price & Purchase Date
          Row(
            children: [
              Expanded(
                child: _buildDetailTile(
                  label: 'Purchase Price',
                  value: item.purchasePrice != null ? Provider.of<InventoryProvider>(context).formatPrice(item.purchasePrice) : 'Not recorded',
                  icon: Icons.attach_money_rounded,
                ),
              ),
              Expanded(
                child: _buildDetailTile(
                  label: 'Purchase Date',
                  value: item.purchaseDate != null ? DateFormat('MMM dd, yyyy').format(item.purchaseDate!) : 'Not recorded',
                  icon: Icons.calendar_today_outlined,
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.8),

          // Low Stock Alert Threshold
          Row(
            children: [
              Expanded(
                child: _buildDetailTile(
                  label: 'Low Stock Alert Threshold',
                  value: item.minQuantity != null
                      ? '≤ ${item.minQuantity! % 1 == 0 ? item.minQuantity!.toInt() : item.minQuantity} ${item.unit}'
                      : 'Not tracked',
                  icon: Icons.production_quantity_limits_rounded,
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.8),

          // Barcode & Serial Number
          if (item.barcode != null && item.barcode!.isNotEmpty) ...[
            _buildCopyableRow('Barcode (UPC/EAN)', item.barcode!, Icons.qr_code_2_rounded),
            const SizedBox(height: 12),
          ],
          if (item.serialNumber != null && item.serialNumber!.isNotEmpty) ...[
            _buildCopyableRow('Serial Number', item.serialNumber!, Icons.tag_rounded),
            const SizedBox(height: 12),
          ],

          // Warranty Info
          if (item.warrantyExpiryDate != null) ...[
            const Divider(height: 24, thickness: 0.8),
            Row(
              children: [
                Icon(
                  item.isWarrantyExpired ? Icons.shield_outlined : Icons.verified_user_outlined,
                  size: 20,
                  color: item.isWarrantyExpired ? Colors.red : const Color(0xFF10B981),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.isWarrantyExpired ? 'Warranty Expired' : 'Warranty Active',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: item.isWarrantyExpired ? Colors.red : const Color(0xFF059669),
                        ),
                      ),
                      Text(
                        'Valid until: ${DateFormat('MMM dd, yyyy').format(item.warrantyExpiryDate!)}${item.daysUntilWarrantyExpiry != null && item.daysUntilWarrantyExpiry! > 0 ? ' (${item.daysUntilWarrantyExpiry} days left)' : ''}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailTile({required String label, required String value, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCopyableRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 16),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            AppFeedback.showSuccess(context, 'Copied $label to clipboard');
          },
        ),
      ],
    );
  }

  Widget _buildCustomAttributesCard(BuildContext context, Item item) {
    final attributes = item.customAttributes;
    final hasAttributes = attributes.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.tune_rounded, size: 20, color: Color(0xFF18181B)),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Specifications & Attributes',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasAttributes) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF18181B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${attributes.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _showManageAttributesSheet(context, item),
                icon: Icon(hasAttributes ? Icons.edit_outlined : Icons.add_rounded, size: 15),
                label: Text(hasAttributes ? 'Manage' : 'Add'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (hasAttributes)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: attributes.entries.map((entry) {
                return InkWell(
                  onTap: () => _showManageAttributesSheet(
                    context,
                    item,
                    editKey: entry.key,
                    editValue: entry.value.toString(),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.key.toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE4E4E7)),
              ),
              child: Column(
                children: [
                  const Text(
                    'No specifications added yet',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3F3F46),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add custom details like Color, Size, Brand, or Specs.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF71717A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => _showManageAttributesSheet(context, item),
                    icon: const Icon(Icons.add, size: 15),
                    label: const Text('Add Specification'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF18181B),
                      side: const BorderSide(color: Color(0xFFD4D4D8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showManageAttributesSheet(
    BuildContext context,
    Item item, {
    String? editKey,
    String? editValue,
  }) {
    final keyController = TextEditingController(text: editKey ?? '');
    final valueController = TextEditingController(text: editValue ?? '');
    final provider = Provider.of<InventoryProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final latestItem = provider.getItemById(item.id) ?? item;
            final currentAttributes = Map<String, dynamic>.from(latestItem.customAttributes);
            final suggestedAttributes = [
              'Color',
              'Size',
              'Brand',
              'Model',
              'Material',
              'Weight',
              'RAM',
              'Storage',
              'Dimensions',
              'Voltage',
            ].where((attr) => !currentAttributes.containsKey(attr)).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4E4E7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.tune_rounded, size: 22, color: Color(0xFF18181B)),
                          const SizedBox(width: 8),
                          const Text(
                            'Specifications & Attributes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF18181B),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Customize attributes and metadata for this item.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF71717A)),
                      ),
                      const SizedBox(height: 16),

                      // Existing attributes list in sheet
                      if (currentAttributes.isNotEmpty) ...[
                        const Text(
                          'CURRENT SPECIFICATIONS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF71717A),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE4E4E7)),
                          ),
                          child: Column(
                            children: currentAttributes.entries.map((entry) {
                              return ListTile(
                                dense: true,
                                title: Text(
                                  entry.key.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                subtitle: Text(
                                  entry.value.toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF18181B),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF71717A)),
                                      onPressed: () {
                                        setSheetState(() {
                                          keyController.text = entry.key;
                                          valueController.text = entry.value.toString();
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFFEF4444)),
                                      onPressed: () async {
                                        final newAttrs = Map<String, dynamic>.from(latestItem.customAttributes)
                                          ..remove(entry.key);
                                        final updated = latestItem.copyWith(customAttributes: newAttrs);
                                        await provider.updateItem(updated);
                                        setSheetState(() {});
                                        if (context.mounted) {
                                          AppFeedback.showSuccess(context, 'Removed "${entry.key}"');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Quick suggestion chips
                      if (suggestedAttributes.isNotEmpty) ...[
                        const Text(
                          'SUGGESTED ATTRIBUTES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF71717A),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: suggestedAttributes.take(6).map((attr) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ActionChip(
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: const Color(0xFFF4F4F6),
                                  side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  avatar: const Icon(Icons.add, size: 14, color: Color(0xFF71717A)),
                                  label: Text(
                                    attr,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF3F3F46),
                                    ),
                                  ),
                                  onPressed: () {
                                    setSheetState(() {
                                      keyController.text = attr;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Input section for adding/editing an attribute
                      Text(
                        keyController.text.isNotEmpty && currentAttributes.containsKey(keyController.text)
                            ? 'EDIT ATTRIBUTE'
                            : 'ADD ATTRIBUTE',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF71717A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: keyController,
                        decoration: InputDecoration(
                          labelText: 'Attribute Name',
                          hintText: 'e.g. Color, RAM, Size, Material',
                          filled: true,
                          fillColor: const Color(0xFFF4F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: valueController,
                        decoration: InputDecoration(
                          labelText: 'Attribute Value',
                          hintText: 'e.g. Space Black, 16GB, XL',
                          filled: true,
                          fillColor: const Color(0xFFF4F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: FilledButton(
                          onPressed: () async {
                            final k = keyController.text.trim();
                            final v = valueController.text.trim();
                            if (k.isEmpty) {
                              AppFeedback.showError(ctx, 'Please enter an attribute name');
                              return;
                            }
                            if (v.isEmpty) {
                              AppFeedback.showError(ctx, 'Please enter an attribute value');
                              return;
                            }

                            final newAttrs = Map<String, dynamic>.from(latestItem.customAttributes);
                            newAttrs[k] = v;
                            final updated = latestItem.copyWith(customAttributes: newAttrs);
                            await provider.updateItem(updated);

                            setSheetState(() {
                              keyController.clear();
                              valueController.clear();
                            });

                            if (context.mounted) {
                              AppFeedback.showSuccess(context, 'Saved attribute "$k"');
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF18181B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Save Attribute', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReceiptsCard(BuildContext context, List<String> receiptPhotos) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.document_scanner_outlined, size: 20, color: Color(0xFF18181B)),
              SizedBox(width: 8),
              Text(
                'Receipts & Warranty Proof',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: receiptPhotos.length,
              itemBuilder: (context, idx) {
                final photoUrl = receiptPhotos[idx];
                return GestureDetector(
                  onTap: () => _showFullScreenImage(context, photoUrl),
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: AppImageView(
                      imageUrlOrPath: photoUrl,
                      borderRadius: BorderRadius.circular(14),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
