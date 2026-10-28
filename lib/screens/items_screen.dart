import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/add_item_flow.dart';
import '../widgets/app_feedback.dart';
import '../widgets/trash_actions.dart';
import '../widgets/item_box_actions.dart';
import '../widgets/item_card.dart';
import '../widgets/lend_item_sheet.dart';
import '../widgets/move_item_sheet.dart';
import 'item_create_screen.dart';
import 'item_details_screen.dart';
import '../widgets/app_refresh.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../utils/text_normalize.dart';
import '../widgets/app_icon.dart';
import '../widgets/soft_ui.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  String _searchQuery = '';
  String? _selectedBoxFilter; // null: all, or specific boxId
  int _statusFilterIndex = 0; // 0: All, 1: Stored, 2: In Use, 3: Lent, 4: Expiring/Expired

  static const int _pageSize = 30;
  int _visibleCount = _pageSize;
  ScrollController? _scrollController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reuse the tab's primary controller so tapping the tab scrolls to top.
    final controller = PrimaryScrollController.maybeOf(context);
    if (controller != _scrollController) {
      _scrollController?.removeListener(_onScroll);
      _scrollController = controller?..addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  /// Reveals the next page of items when the list is scrolled near its end.
  void _onScroll() {
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return;
    final position = controller.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      setState(() => _visibleCount += _pageSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<InventoryProvider>(
          builder: (context, provider, child) {
            List<Item> displayedItems = provider.items;

            // Filter by location
            if (_selectedBoxFilter != null) {
              displayedItems = displayedItems.where((i) => i.boxId == _selectedBoxFilter).toList();
            }

            // Filter by status
            if (_statusFilterIndex == 1) {
              displayedItems = displayedItems.where((i) => i.status == ItemStatus.stored).toList();
            } else if (_statusFilterIndex == 2) {
              displayedItems = displayedItems.where((i) => i.status == ItemStatus.inUse).toList();
            } else if (_statusFilterIndex == 3) {
              displayedItems = displayedItems.where((i) => i.status == ItemStatus.lent).toList();
            } else if (_statusFilterIndex == 4) {
              displayedItems = displayedItems.where((i) => i.isExpired || (i.daysUntilExpiry != null && i.daysUntilExpiry! <= 30)).toList();
            } else if (_statusFilterIndex == 5) {
              displayedItems = displayedItems.where((i) => i.isLowStock).toList();
            }

            // Search query
            if (_searchQuery.isNotEmpty) {
              final q = normalizeVi(_searchQuery);
              displayedItems = displayedItems.where((i) =>
                containsNormalized(i.name, q) ||
                containsNormalized(i.description, q) ||
                containsNormalized(i.serialNumber, q) ||
                containsNormalized(i.barcode, q)
              ).toList();
            }

            return AppRefresh(child: ListView(
 physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.itemCatalog,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.assetsTracked(provider.items.length),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search field
                SoftSearchField(
                  hint: context.l10n.searchItemsBarcodesSerials,
                  value: _searchQuery,
                  onChanged: (val) => setState(() { _searchQuery = val.trim(); _visibleCount = _pageSize; }),
                  onClear: () => setState(() => _searchQuery = ''),
                ),
                const SizedBox(height: 16),

                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusFilterChip(0, context.l10n.commonAll(provider.items.length)),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip(1, context.l10n.commonStored(provider.items.where((i) => i.status == ItemStatus.stored).length)),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip(2, context.l10n.inUse(provider.items.where((i) => i.status == ItemStatus.inUse).length)),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip(3, context.l10n.commonLent(provider.items.where((i) => i.status == ItemStatus.lent).length)),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip(4, context.l10n.alertsExpiring(provider.getExpiredItems().length + provider.getExpiringItems(withinDays: provider.expiryWarningDays).length)),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip(5, context.l10n.lowStock(provider.getLowStockItems().length)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Location selector dropdown filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: context.colors.cardShadow,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedBoxFilter,
                      isExpanded: true,
                      icon: const AppIcon(Icons.keyboard_arrow_down_rounded),
                      hint: Text(context.l10n.allStorageLocations),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(context.l10n.allStorageLocations, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        ...provider.boxes.map((b) => DropdownMenuItem<String?>(
                          value: b.id,
                          child: Text('${b.type.displayName}: ${b.name}'),
                        )),
                      ],
                      onChanged: (val) {
                        setState(() { _selectedBoxFilter = val; _visibleCount = _pageSize; });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Items list
                if (displayedItems.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        AppIcon(Icons.category_outlined, size: 56, color: context.colors.textMuted),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty ? context.l10n.noMatchingItemsFound : context.l10n.noItemsFound,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? context.l10n.trySearchingWithAnotherName
                              : context.l10n.tapAddItemAboveTo,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.colors.textSecondary),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => startAddItemFlow(context),
                            child: Text(
                              provider.boxes.isEmpty
                                  ? context.l10n.createFirstLocation
                                  : context.l10n.addFirstItem,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  ...displayedItems.take(_visibleCount).map((item) {
                    final parentBox = provider.getBoxById(item.boxId);
                    final breadcrumb = parentBox != null ? provider.getBreadcrumbString(parentBox.id) : '';

                    final c = context.colors;
                    final tags = <Widget>[
                      if (item.isLowStock)
                        SoftChip.tone(context.l10n.tagLowStock, AppTones.amber, icon: Icons.production_quantity_limits_rounded),
                      if (item.isExpired)
                        SoftChip.tone(context.l10n.tagExpired, AppTones.coral, icon: Icons.event_busy_outlined)
                      else if (item.daysUntilExpiry != null && item.daysUntilExpiry! <= 30)
                        SoftChip.tone(context.l10n.expiresInShort(item.daysUntilExpiry!), AppTones.amber, icon: Icons.event_outlined),
                    ];
                    final min = item.minQuantity;
                    final description = [
                      if (breadcrumb.isNotEmpty) context.l10n.inPlacePath(breadcrumb),
                      if (item.purchasePrice != null) provider.formatPrice(item.purchasePrice),
                    ].join(' • ');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SoftCard(
                        child: Slidable(
                          key: ValueKey(item.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.85,
                            children: [
                              // Move action
                              SlidableAction(
                                onPressed: (_) => MoveItemSheet.show(context, item),
                                backgroundColor: AppTones.lilac,
                                foregroundColor: Colors.white,
                                icon: Icons.drive_file_move_outlined,
                                label: context.l10n.commonMove,
                              ),
                              // Lend or Return action
                              if (item.status == ItemStatus.lent)
                                SlidableAction(
                                  onPressed: (_) {
                                    final loan = provider.getActiveLoanForItem(item.id);
                                    if (loan != null) confirmAndReturnLoan(context, loan, itemName: item.name);
                                  },
                                  backgroundColor: AppTones.matcha,
                                  foregroundColor: Colors.white,
                                  icon: Icons.assignment_turned_in_outlined,
                                  label: context.l10n.commonReturn,
                                )
                              else
                                SlidableAction(
                                  onPressed: (_) => LendItemSheet.show(context, initialItem: item),
                                  backgroundColor: AppTones.amber,
                                  foregroundColor: Colors.white,
                                  icon: Icons.assignment_ind_outlined,
                                  label: context.l10n.commonLend,
                                ),

                              SlidableAction(
                                onPressed: (_) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ItemCreateScreen(boxId: item.boxId, existingItem: item),
                                    ),
                                  );
                                },
                                backgroundColor: context.colors.primary,
                                foregroundColor: Colors.white,
                                icon: Icons.edit_outlined,
                                label: context.l10n.commonEdit,
                              ),
                              SlidableAction(
                                onPressed: (_) async {
                                  final confirmed = await TrashActions.confirm(context, name: item.name);
                                  if (confirmed && context.mounted) {
                                    final ok = await provider.deleteItem(item.id);
                                    if (!context.mounted) return;
                                    if (ok) {
                                      TrashActions.showMoved(context, provider, name: item.name, itemId: item.id);
                                    } else {
                                      AppFeedback.showError(context, context.l10n.couldNotDeletePleaseTry2(item.name));
                                    }
                                  }
                                },
                                backgroundColor: AppTones.coral,
                                foregroundColor: Colors.white,
                                icon: Icons.delete_outline,
                                label: context.l10n.commonDelete,
                              ),
                            ],
                          ),
                          child: ItemCard(
                            name: item.name,
                            description: description,
                            quantityText: provider.formatQty(item.quantity, item.unit),
                            status: SoftChip.tone(item.status.displayName, item.status.color, dot: true),
                            tags: tags,
                            stockRatio: min != null && min > 0 ? (item.quantity + item.lentQuantity) / (min * 2) : null,
                            stockColor: item.isLowStock ? AppTones.amber : c.successStrong,
                            imageUrl: item.imageUrl,
                            enableClip: false,
                            onLongPress: () => showItemActionsSheet(context, item),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ItemDetailsScreen(itemId: item.id),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }),
                if (displayedItems.length > _visibleCount)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
                  ),
              ],
            ));
          },
        ),
      ),
    );
  }

  Widget _buildStatusFilterChip(int index, String label) {
    return SoftFilterChip(
      label: label,
      selected: _statusFilterIndex == index,
      onTap: () => setState(() { _statusFilterIndex = index; _visibleCount = _pageSize; }),
    );
  }

}
