import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/add_item_flow.dart';
import '../widgets/app_refresh.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../utils/text_normalize.dart';
import '../widgets/soft_ui.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/items_list_parts.dart';
import '../utils/e2e.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  String _searchQuery = '';
  String? _selectedBoxFilter; // null: all, or specific boxId
  int _statusFilterIndex =
      0; // 0: All, 1: Stored, 2: In Use, 3: Lent, 4: Expiring/Expired

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
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<InventoryProvider>(
          builder: (context, provider, child) {
            List<Item> displayedItems = provider.items;

            // Filter by location
            if (_selectedBoxFilter != null) {
              displayedItems = displayedItems
                  .where((i) => i.boxId == _selectedBoxFilter)
                  .toList();
            }

            // Filter by status
            if (_statusFilterIndex == 1) {
              displayedItems = displayedItems
                  .where((i) => i.status == ItemStatus.stored)
                  .toList();
            } else if (_statusFilterIndex == 2) {
              displayedItems = displayedItems
                  .where((i) => i.status == ItemStatus.inUse)
                  .toList();
            } else if (_statusFilterIndex == 3) {
              displayedItems = displayedItems
                  .where((i) => i.status == ItemStatus.lent)
                  .toList();
            } else if (_statusFilterIndex == 4) {
              displayedItems = displayedItems
                  .where(
                    (i) =>
                        i.isExpired ||
                        (i.daysUntilExpiry != null && i.daysUntilExpiry! <= 30),
                  )
                  .toList();
            } else if (_statusFilterIndex == 5) {
              displayedItems = displayedItems
                  .where((i) => i.isLowStock)
                  .toList();
            }

            // Search query
            if (_searchQuery.isNotEmpty) {
              final q = normalizeVi(_searchQuery);
              displayedItems = displayedItems
                  .where(
                    (i) =>
                        containsNormalized(i.name, q) ||
                        containsNormalized(i.description, q) ||
                        containsNormalized(i.serialNumber, q) ||
                        containsNormalized(i.barcode, q),
                  )
                  .toList();
            }

            return AppRefresh(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  24,
                  8,
                  24,
                  AppBottomNav.bottomInset(context) + 64 + 32,
                ),
                children: [
                  ItemsListHeader(count: provider.items.length),
                  const SizedBox(height: 18),
                  e2eId(
                    'items_search',
                    SoftSearchField(
                      hint: context.l10n.searchItemsBarcodesSerials,
                      value: _searchQuery,
                      onChanged: (val) => setState(() {
                        _searchQuery = val.trim();
                        _visibleCount = _pageSize;
                      }),
                      onClear: () => setState(() => _searchQuery = ''),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      children: [
                        _buildStatusFilterChip(
                          0,
                          context.l10n.commonAll(provider.items.length),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusFilterChip(
                          1,
                          context.l10n.commonStored(
                            provider.items
                                .where((i) => i.status == ItemStatus.stored)
                                .length,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusFilterChip(
                          2,
                          context.l10n.inUse(
                            provider.items
                                .where((i) => i.status == ItemStatus.inUse)
                                .length,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusFilterChip(
                          3,
                          context.l10n.commonLent(
                            provider.items
                                .where((i) => i.status == ItemStatus.lent)
                                .length,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusFilterChip(
                          4,
                          context.l10n.alertsExpiring(
                            provider.getExpiredItems().length +
                                provider
                                    .getExpiringItems(
                                      withinDays: provider.expiryWarningDays,
                                    )
                                    .length,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusFilterChip(
                          5,
                          context.l10n.lowStock(
                            provider.getLowStockItems().length,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ItemsLocationFilter(
                    boxes: provider.boxes,
                    selectedBoxId: _selectedBoxFilter,
                    onChanged: (val) => setState(() {
                      _selectedBoxFilter = val;
                      _visibleCount = _pageSize;
                    }),
                  ),
                  const SizedBox(height: 18),

                  // Items list
                  if (displayedItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _searchQuery.isNotEmpty
                          ? EmptyStateCard(
                              icon: Icons.search_rounded,
                              title: context.l10n.noMatchingItemsFound,
                              subtitle:
                                  context.l10n.trySearchingWithAnotherName,
                            )
                          : EmptyStateCard(
                              icon: Icons.category_outlined,
                              title: context.l10n.noItemsFound,
                              subtitle: context.l10n.tapAddItemAboveTo,
                              actionLabel: provider.boxes.isEmpty
                                  ? context.l10n.createFirstLocation
                                  : context.l10n.addFirstItem,
                              onAction: () => startAddItemFlow(context),
                            ),
                    )
                  else
                    ...displayedItems.take(_visibleCount).map((item) {
                      final parentBox = provider.getBoxById(item.boxId);
                      final breadcrumb = parentBox != null
                          ? provider.getBreadcrumbString(parentBox.id)
                          : '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ItemListTile(
                          item: item,
                          provider: provider,
                          locationPath: breadcrumb,
                        ),
                      );
                    }),
                  if (displayedItems.length > _visibleCount)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusFilterChip(int index, String label) {
    const keys = ['all', 'stored', 'in_use', 'lent', 'expiring', 'low_stock'];
    return e2eId(
      'items_filter_${keys[index]}',
      SoftFilterChip(
        label: label,
        selected: _statusFilterIndex == index,
        onTap: () => setState(() {
          _statusFilterIndex = index;
          _visibleCount = _pageSize;
        }),
      ),
    );
  }
}
