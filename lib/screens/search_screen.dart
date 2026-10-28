import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_image_view.dart';
import '../widgets/box_card.dart';
import 'box_details_screen.dart';
import 'item_create_screen.dart';
import 'item_details_screen.dart';
import '../widgets/app_refresh.dart';
import '../widgets/tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../utils/text_normalize.dart';
import '../widgets/app_icon.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  // Stable ids; the label shown comes from [_filterLabel].
  String _selectedFilter = 'all';

  final List<String> _filters = ['all', 'stored', 'inUse', 'lent', 'perishable'];

  String _filterLabel(BuildContext context, String id) => switch (id) {
        'stored' => context.l10n.commonStored2,
        'inUse' => context.l10n.inUse2,
        'lent' => context.l10n.commonLent3,
        'perishable' => context.l10n.commonPerishable,
        _ => context.l10n.commonAll2,
      };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
 tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: AppIcon(Icons.arrow_back_ios_new_rounded, color: context.colors.textPrimary, size: 16),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: context.colors.cardShadow,
            ),
            child: Row(
              children: [
                AppIcon(Icons.search, size: 20, color: context.colors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: context.l10n.searchItemsSerialBarcodeBoxes,
                      hintStyle: TextStyle(color: context.colors.textMuted, fontSize: 13, fontWeight: FontWeight.normal),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _query = normalizeVi(val.trim());
                      });
                    },
                  ),
                ),
                if (_query.isNotEmpty)
                  Tappable(
                    semanticLabel: MaterialLocalizations.of(context).clearButtonTooltip,
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: context.colors.border,
                        shape: BoxShape.circle,
                      ),
                      child: AppIcon(Icons.close_rounded, size: 16, color: context.colors.textSecondary),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Consumer<InventoryProvider>(
          builder: (context, provider, child) {
            // Filter chips header
            return Column(
              children: [
                Container(
                  color: context.colors.fill,
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Tappable(
                          onTap: () => setState(() => _selectedFilter = filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? context.colors.accent : context.colors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _filterLabel(context, filter),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? context.colors.onAccent : context.colors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                Expanded(
                  child: _buildSearchResults(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, InventoryProvider provider) {
    // A status filter alone is a valid search ("everything that is lent out").
    if (_query.isEmpty && _selectedFilter == 'all') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(Icons.search_rounded, size: 56, color: context.colors.border),
            const SizedBox(height: 12),
            Text(
              context.l10n.searchYourEntireInventory,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.colors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.findItemsByNameBarcode,
              style: TextStyle(fontSize: 13, color: context.colors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Matching Boxes
    // (locations have no status, so a filter without a keyword lists items only)
    final matchingBoxes = _query.isEmpty
        ? <Box>[]
        : provider.boxes.where((b) {
            return containsNormalized(b.name, _query) ||
                containsNormalized(b.description, _query) ||
                containsNormalized(b.label, _query);
          }).toList();

    // Matching Items (Full-text search)
    var matchingItems = provider.items.where((i) {
      final matchesQuery = _query.isEmpty ||
          containsNormalized(i.name, _query) ||
          containsNormalized(i.description, _query) ||
          containsNormalized(i.categoryId, _query) ||
          containsNormalized(i.serialNumber, _query) ||
          containsNormalized(i.barcode, _query) ||
          i.customAttributes.entries.any((entry) =>
              containsNormalized(entry.key, _query) ||
              containsNormalized(entry.value.toString(), _query));

      if (!matchesQuery) return false;

      // Status filters
      if (_selectedFilter == 'stored') return i.status == ItemStatus.stored;
      if (_selectedFilter == 'inUse') return i.status == ItemStatus.inUse;
      if (_selectedFilter == 'lent') return i.status == ItemStatus.lent;
      if (_selectedFilter == 'perishable') return i.expiryDate != null;

      return true;
    }).toList();

    if (matchingBoxes.isEmpty && matchingItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(Icons.inventory_2_outlined, size: 56, color: context.colors.border),
            const SizedBox(height: 12),
            Text(
              context.l10n.noResultsFor(_query),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.tryADifferentNameSerial,
              style: TextStyle(fontSize: 13, color: context.colors.textMuted),
            ),
          ],
        ),
      );
    }

    return AppRefresh(child: ListView(
 physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        // Storage Containers Match
        if (matchingBoxes.isNotEmpty) ...[
          Row(
            children: [
              const AppIcon(Icons.meeting_room_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                context.l10n.storageLocations(matchingBoxes.length),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...matchingBoxes.map((box) {
            final breadcrumb = provider.getBreadcrumbString(box.id);
            final itemsCount = provider.countTotalItemsIn(box.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: BoxCard(
                name: box.name,
                description: '$breadcrumb\n$itemsCount items stored',
                label: box.label,
                type: box.type,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BoxDetailsScreen(boxId: box.id),
                    ),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 20),
        ],

        // Items Match with Full Breadcrumb Navigation
        if (matchingItems.isNotEmpty) ...[
          Row(
            children: [
              const AppIcon(Icons.category_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                context.l10n.commonItems(matchingItems.length),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...matchingItems.map((item) {
            final breadcrumb = provider.getBreadcrumbString(item.boxId);

            return Tappable(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemDetailsScreen(itemId: item.id),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: context.colors.cardShadow,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.imageUrl != null) ...[
                      AppImageView(
                        imageUrlOrPath: item.imageUrl!,
                        width: 58,
                        height: 58,
                        borderRadius: BorderRadius.circular(14),
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item Name + Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: item.status.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.status.displayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: item.status.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (item.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                            ),
                          ],
                          const SizedBox(height: 10),

                          // Breadcrumb Path display
                          Tappable(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BoxDetailsScreen(boxId: item.boxId),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: context.colors.fill,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppIcon(Icons.location_on_outlined, size: 14, color: context.colors.textPrimary),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      breadcrumb,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: context.colors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  AppIcon(Icons.chevron_right, size: 14, color: context.colors.textSecondary),
                                ],
                              ),
                            ),
                          ),

                          // Actions & Metadata row
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${context.l10n.qtyValue(provider.formatQty(item.quantity, item.unit))}${item.purchasePrice != null ? ' • ${provider.formatPrice(item.purchasePrice)}' : ''}${item.barcode != null ? ' • UPC: ${item.barcode}' : ''}',
                                style: TextStyle(color: context.colors.textMuted, fontSize: 11),
                              ),
                              Tappable(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ItemCreateScreen(boxId: item.boxId, existingItem: item),
                                    ),
                                  );
                                },
                                child: Text(
                                  context.l10n.commonEdit,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    ));
  }
}
