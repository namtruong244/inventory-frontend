import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/trash_actions.dart';
import '../widgets/item_card.dart';
import '../widgets/location_picker_sheet.dart';
import '../widgets/move_item_sheet.dart';
import 'item_create_screen.dart';
import 'item_details_screen.dart';
import 'lending_tracker_screen.dart';
import '../widgets/app_refresh.dart';
import '../widgets/tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

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
              final q = _searchQuery.toLowerCase();
              displayedItems = displayedItems.where((i) =>
                i.name.toLowerCase().contains(q) ||
                i.description.toLowerCase().contains(q) ||
                (i.serialNumber != null && i.serialNumber!.toLowerCase().contains(q)) ||
                (i.barcode != null && i.barcode!.toLowerCase().contains(q))
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
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${provider.items.length} assets tracked',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (provider.boxes.isNotEmpty)
                      FilledButton.icon(
                        onPressed: () => _showSelectBoxToAddItem(provider),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(context.l10n.addItem),
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search field
                TextField(
                  onChanged: (val) => setState(() { _searchQuery = val.trim(); _visibleCount = _pageSize; }),
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: context.l10n.searchItemsBarcodesSerials,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
 tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
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
                    border: Border.all(color: context.colors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedBoxFilter,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
                        Icon(Icons.category_outlined, size: 56, color: context.colors.textMuted),
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
                      ],
                    ),
                  )
                else
                  ...displayedItems.take(_visibleCount).map((item) {
                    final parentBox = provider.getBoxById(item.boxId);
                    final breadcrumb = parentBox != null ? provider.getBreadcrumbString(parentBox.id) : '';

                    String meta = '${provider.formatQty(item.quantity, item.unit)} • ${item.status.displayName}';
                    if (item.isLowStock) {
                      meta += ' • LOW STOCK';
                    }
                    if (item.purchasePrice != null) meta += ' • ${provider.formatPrice(item.purchasePrice)}';
                    if (item.isExpired) {
                      meta += ' • EXPIRED';
                    } else if (item.daysUntilExpiry != null && item.daysUntilExpiry! <= 30) {
                      meta += ' • Expires in ${item.daysUntilExpiry}d';
                    }
                    if (breadcrumb.isNotEmpty) meta += '\nIn: $breadcrumb';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Slidable(
                          key: ValueKey(item.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.85,
                            children: [
                              // Move action
                              SlidableAction(
                                onPressed: (_) => MoveItemSheet.show(context, item),
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                icon: Icons.drive_file_move_outlined,
                                label: context.l10n.commonMove,
                              ),
                              // Lend or Return action
                              if (item.status == ItemStatus.lent)
                                SlidableAction(
                                  onPressed: (_) {
                                    final loan = provider.getActiveLoanForItem(item.id);
                                    if (loan != null) {
                                      provider.returnItem(loan.id);
                                      AppFeedback.showSuccess(context, context.l10n.itemMarkedAsReturned);
                                    }
                                  },
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  icon: Icons.assignment_turned_in_outlined,
                                  label: context.l10n.commonReturn,
                                )
                              else
                                SlidableAction(
                                  onPressed: (_) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LendingTrackerScreen(),
                                      ),
                                    );
                                  },
                                  backgroundColor: const Color(0xFFF59E0B),
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
                                backgroundColor: Colors.red.shade400,
                                foregroundColor: Colors.white,
                                icon: Icons.delete_outline,
                                label: context.l10n.commonDelete,
                              ),
                            ],
                          ),
                          child: ItemCard(
                            name: item.name,
                            description: item.description.isEmpty ? meta : '${item.description}\n$meta',
                            imageUrl: item.imageUrl,
                            enableClip: false,
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
    final isSelected = _statusFilterIndex == index;
    final theme = Theme.of(context);

    return Tappable(
      onTap: () => setState(() { _statusFilterIndex = index; _visibleCount = _pageSize; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.primary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<void> _showSelectBoxToAddItem(InventoryProvider provider) async {
    final selectedBox = await LocationPickerSheet.show(
      context,
      title: context.l10n.selectDestinationContainer,
      subtitle: context.l10n.chooseContainerOrScanIts,
      confirmButtonText: context.l10n.addItemHere,
    );
    if (!mounted || selectedBox == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemCreateScreen(boxId: selectedBox.id),
      ),
    );
  }
}
