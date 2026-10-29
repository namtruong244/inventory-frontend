import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../widgets/tappable.dart';
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

  Widget _buildStockCard(
    BuildContext context,
    Item item,
    InventoryProvider provider,
  ) {
    final c = context.colors;
    final min = item.minQuantity;
    final held = item.quantity + item.lentQuantity;
    final ratio = min != null && min > 0 ? held / (min * 2) : null;
    return SoftCard(
      child: Tappable(
        semanticLabel: context.l10n.stockHistory,
        onTap: () => StockHistorySheet.show(context, item),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      provider.formatQty(item.quantity, item.unit),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AppIcon(Icons.history, size: 20, color: c.textMuted),
                  AppIcon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: c.textMuted,
                  ),
                ],
              ),
              if (ratio != null) ...[
                const SizedBox(height: 12),
                SoftBar(
                  value: ratio,
                  color: item.isLowStock ? AppTones.amber : c.successStrong,
                  height: 8,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showItemOptionsMenu(
    BuildContext context,
    Item item,
    InventoryProvider provider,
  ) {
    final c = context.colors;
    TextStyle label([Color? color, FontWeight w = FontWeight.w500]) =>
        GoogleFonts.plusJakartaSans(fontWeight: w, fontSize: 14, color: color);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: c.surface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.fill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppIcon(
                        CategoryHelper.getCategoryIcon(item.categoryId),
                        size: 22,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: c.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            provider.formatQty(item.quantity, item.unit),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: c.border),
              ListTile(
                leading: AppIcon(Icons.edit_outlined, color: c.textPrimary),
                title: Text(context.l10n.editItemDetails, style: label()),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItemCreateScreen(
                        boxId: item.boxId,
                        existingItem: item,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: AppIcon(
                  Icons.drive_file_move_outlined,
                  color: c.textPrimary,
                ),
                title: Text(context.l10n.moveLocation, style: label()),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showMoveItemDialog(context, item);
                },
              ),
              if (item.status != ItemStatus.lent)
                ListTile(
                  leading: AppIcon(
                    Icons.handshake_outlined,
                    color: c.textPrimary,
                  ),
                  title: Text(context.l10n.lendItem, style: label()),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    LendItemSheet.show(context, initialItem: item);
                  },
                ),
              Divider(color: c.border),
              ListTile(
                leading: const AppIcon(
                  Icons.delete_outline_rounded,
                  color: AppTones.coral,
                ),
                title: Text(
                  context.l10n.deleteItem,
                  style: label(AppTones.coral, FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final confirm = await TrashActions.confirm(
                    context,
                    name: item.name,
                  );
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
                },
              ),
            ],
          ),
        ),
      ),
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

        return Scaffold(
          backgroundColor: context.colors.background,
          body: CustomScrollView(
            slivers: [
              // Custom Silver App Bar with Hero Image Carousel
              SliverAppBar(
                expandedHeight: item.photos.isNotEmpty ? 340 : 160,
                pinned: true,
                backgroundColor: context.colors.fill,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: context.colors.surface.withValues(
                      alpha: 0.85,
                    ),
                    child: IconButton(
                      tooltip: MaterialLocalizations.of(context)
                          .backButtonTooltip,
                      icon: AppIcon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: context.colors.textPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: context.l10n.moreOptions,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        shape: BoxShape.circle,
                        boxShadow: context.colors.cardShadow,
                      ),
                      child: AppIcon(
                        Icons.more_horiz_rounded,
                        size: 20,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    onPressed: () =>
                        _showItemOptionsMenu(context, item, provider),
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
                              onPageChanged: (idx) =>
                                  setState(() => _currentPhotoIndex = idx),
                              itemBuilder: (context, idx) {
                                final photoUrl = item.photos[idx];
                                return Tappable(
                                  semanticLabel: context.l10n.productPhotos,
                                  onTap: () =>
                                      showFullScreenImage(context, photoUrl),
                                  child: AppImageView(
                                    imageUrlOrPath: photoUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: Container(
                                      color: context.colors.primary,
                                      child: const Center(
                                        child: AppIcon(
                                          Icons.broken_image_outlined,
                                          color: Colors.white54,
                                          size: 48,
                                        ),
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
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      width: _currentPhotoIndex == idx ? 20 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _currentPhotoIndex == idx
                                            ? context.colors.surface
                                            : context.colors.surface.withValues(
                                                alpha: 0.4,
                                              ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Container(
                          color: context.colors.fill,
                          child: Center(
                            child: AppIcon(
                              Icons.image_outlined,
                              size: 64,
                              color: context.colors.textMuted,
                            ),
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
                          SoftChip.tone(
                            item.status.displayName,
                            item.status.color,
                            icon: item.status.icon,
                          ),
                          SoftChip(
                            label: item.categoryId,
                            background: context.colors.fill,
                            foreground: context.colors.textPrimary,
                            icon: CategoryHelper.getCategoryIcon(
                              item.categoryId,
                            ),
                          ),
                          if (item.isConsumable)
                            SoftChip(
                              label: context.l10n.commonConsumable,
                              background: context.colors.infoSoft,
                              foreground: context.colors.infoStrong,
                              icon: Icons.shopping_basket_outlined,
                            ),
                          if (item.isLowStock)
                            SoftChip(
                              label: context.l10n.settingsLowStock,
                              background: context.colors.warningSoft,
                              foreground: context.colors.warningStrong,
                              icon: Icons.warning_amber_rounded,
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Product Title
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: context.colors.textPrimary,
                          letterSpacing: -0.8,
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

                      // Stock level: big number, thin bar against the minimum, history drill-down
                      _buildStockCard(context, item, provider),
                      const SizedBox(height: 20),

                      // If currently Lent: Show Prominent Loan Details Card (Module 6)
                      for (final loan in provider.getActiveLoansForItem(
                        item.id,
                      )) ...[
                        buildActiveLoanCard(context, provider, loan),
                        const SizedBox(height: 20),
                      ],

                      // Storage Location & Breadcrumb Card (Module 1 & 4)
                      buildStorageLocationCard(
                        context,
                        provider,
                        item,
                        parentBox,
                        breadcrumbs,
                      ),
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
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: context.colors.cardShadow,
            ),
            child: Row(
              children: [
                // Move button
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.fill,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => _showMoveItemDialog(context, item),
                    icon: AppIcon(
                      Icons.drive_file_move_outlined,
                      size: 18,
                      color: context.colors.textPrimary,
                    ),
                    label: Text(
                      context.l10n.commonMove,
                      style: TextStyle(color: context.colors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Main Action Button (Dynamic based on isConsumable & status)
                Expanded(
                  flex: 2,
                  child: item.isConsumable
                      ? ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.accent,
                            foregroundColor: context.colors.onAccent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            if (item.quantity <= 0) {
                              showRestockSheet(context, item, provider);
                            } else {
                              showConsumeSheet(context, item, provider);
                            }
                          },
                          icon: AppIcon(
                            item.quantity <= 0
                                ? Icons.add_shopping_cart_outlined
                                : Icons.remove_circle_outline,
                            size: 18,
                          ),
                          label: Text(
                            item.quantity <= 0
                                ? context.l10n.outOfStockRestock
                                : context.l10n.commonConsume(item.unit),
                            ),
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.accent,
                            foregroundColor: context.colors.onAccent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () => _handleStatusToggle(
                            context,
                            item,
                            provider,
                            activeLoan,
                          ),
                          icon: AppIcon(
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
