import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_image_view.dart';
import '../widgets/app_refresh.dart';
import '../widgets/box_tree.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/search_parts.dart';
import '../widgets/soft_ui.dart';
import 'box_details_screen.dart';
import 'item_details_screen.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../utils/text_normalize.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _rawQuery = '';
  // Stable ids; the label shown comes from [_filterLabel].
  String _selectedFilter = 'all';

  final List<String> _filters = [
    'all',
    'items',
    'locations',
    'stored',
    'inUse',
    'lent',
    'perishable',
  ];

  String _filterLabel(BuildContext context, String id) => switch (id) {
    'items' => context.l10n.searchFilterItems,
    'locations' => context.l10n.searchFilterLocations,
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
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Consumer<InventoryProvider>(
            builder: (context, provider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
                    child: SearchInputRow(
                      hint: context.l10n.searchItemsSerialBarcodeBoxes,
                      controller: _searchController,
                      hasText: _query.isNotEmpty,
                      onChanged: (val) => setState(() {
                        _rawQuery = val.trim();
                        _query = normalizeVi(_rawQuery);
                      }),
                      onClear: () {
                        _searchController.clear();
                        setState(() {
                          _rawQuery = '';
                          _query = '';
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SearchFilterBar(
                      filters: [
                        for (final f in _filters) (f, _filterLabel(context, f)),
                      ],
                      selected: _selectedFilter,
                      onSelected: (f) => setState(() => _selectedFilter = f),
                    ),
                  ),
                  Expanded(child: _buildSearchResults(context, provider)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _centered(Widget child) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: child,
    ),
  );

  Widget _buildSearchResults(BuildContext context, InventoryProvider provider) {
    final l10n = context.l10n;
    // A filter alone is a valid search ("everything that is lent out").
    if (_query.isEmpty && _selectedFilter == 'all') {
      return _centered(
        EmptyStateCard(
          icon: Icons.search_rounded,
          title: l10n.searchYourEntireInventory,
          subtitle: l10n.findItemsByNameBarcode,
        ),
      );
    }

    final onlyItems =
        _selectedFilter != 'all' && _selectedFilter != 'locations';
    final onlyBoxes = _selectedFilter == 'locations';

    // Locations have no status, so status filters list items only.
    final matchingBoxes = onlyItems
        ? <Box>[]
        : provider.boxes.where((b) {
            return _query.isEmpty ||
                containsNormalized(b.name, _query) ||
                containsNormalized(b.description, _query) ||
                containsNormalized(b.label, _query);
          }).toList();

    final matchingItems = onlyBoxes
        ? <Item>[]
        : provider.items.where((i) {
            final matchesQuery =
                _query.isEmpty ||
                containsNormalized(i.name, _query) ||
                containsNormalized(i.description, _query) ||
                containsNormalized(i.categoryId, _query) ||
                containsNormalized(i.serialNumber, _query) ||
                containsNormalized(i.barcode, _query) ||
                i.customAttributes.entries.any(
                  (entry) =>
                      containsNormalized(entry.key, _query) ||
                      containsNormalized(entry.value.toString(), _query),
                );
            if (!matchesQuery) return false;
            return switch (_selectedFilter) {
              'stored' => i.status == ItemStatus.stored,
              'inUse' => i.status == ItemStatus.inUse,
              'lent' => i.status == ItemStatus.lent,
              'perishable' => i.expiryDate != null,
              _ => true,
            };
          }).toList();

    if (matchingBoxes.isEmpty && matchingItems.isEmpty) {
      return _centered(
        EmptyStateCard(
          icon: Icons.inventory_2_outlined,
          title: l10n.noResultsFor(_rawQuery),
          subtitle: l10n.tryADifferentNameSerial,
        ),
      );
    }

    // Typed text and its accent-free form, e.g. “Cáp”, “cap”.
    final variants = {_rawQuery, _query}.where((v) => v.isNotEmpty).toList();

    return AppRefresh(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        children: [
          if (variants.length > 1) ...[
            SearchAccentHint(variants: variants.map((v) => '“$v”').join(', ')),
            const SizedBox(height: 18),
          ],
          if (matchingItems.isNotEmpty)
            SearchResultGroup(
              title: l10n.searchGroupItems,
              count: matchingItems.length,
              rows: [
                for (final item in matchingItems) _itemRow(provider, item),
              ],
            ),
          if (matchingItems.isNotEmpty && matchingBoxes.isNotEmpty)
            const SizedBox(height: 18),
          if (matchingBoxes.isNotEmpty)
            SearchResultGroup(
              title: l10n.searchGroupLocations,
              count: matchingBoxes.length,
              rows: [for (final box in matchingBoxes) _boxRow(provider, box)],
            ),
        ],
      ),
    );
  }

  Widget _itemRow(InventoryProvider provider, Item item) {
    final c = context.colors;
    return SearchResultRow(
      key: ValueKey('item_${item.id}'),
      id: 'search_result_item_${item.name}',
      tile: item.imageUrl != null
          ? AppImageView(
              imageUrlOrPath: item.imageUrl!,
              width: 42,
              height: 42,
              borderRadius: BorderRadius.circular(14),
              fit: BoxFit.cover,
            )
          : SoftIconTile(
              CategoryHelper.getCategoryIcon(item.categoryId),
              color: c.textPrimary,
              size: 42,
            ),
      name: item.name,
      normalizedQuery: _query,
      sub: provider.getBreadcrumbString(item.boxId),
      badge: context.l10n.qtyValue(
        provider.formatQty(item.quantity, item.unit),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemDetailsScreen(itemId: item.id)),
      ),
    );
  }

  Widget _boxRow(InventoryProvider provider, Box box) {
    final tone = boxTypeTone(box.type);
    final parentPath = box.parentId == null
        ? ''
        : provider.getBreadcrumbString(box.parentId!);
    return SearchResultRow(
      key: ValueKey('box_${box.id}'),
      id: 'search_result_box_${box.name}',
      tile: SoftIconTile(
        box.type.icon,
        color: tone.fg,
        background: tone.bg,
        size: 42,
      ),
      name: box.name,
      normalizedQuery: _query,
      sub: parentPath.isEmpty
          ? box.type.displayName
          : '${box.type.displayName} · $parentPath',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BoxDetailsScreen(boxId: box.id)),
      ),
    );
  }
}
