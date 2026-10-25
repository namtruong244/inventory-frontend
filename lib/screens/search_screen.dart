import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_image_view.dart';
import '../widgets/box_card.dart';
import 'box_details_screen.dart';
import 'item_create_screen.dart';
import 'item_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedFilter = 'All'; // 'All', 'Stored', 'In Use', 'Lent', 'Perishable'

  final List<String> _filters = ['All', 'Stored', 'In Use', 'Lent', 'Perishable'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF18181B), size: 16),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20, color: Color(0xFFA1A1AA)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Search items, serial, barcode, boxes...',
                      hintStyle: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, fontWeight: FontWeight.normal),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _query = val.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                if (_query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
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
                  color: const Color(0xFFF8F9FA),
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF18181B) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF18181B) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFF18181B),
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
    if (_query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Search your entire inventory',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              'Find items by name, barcode, serial number, or storage location',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Matching Boxes
    final matchingBoxes = provider.boxes.where((b) {
      return b.name.toLowerCase().contains(_query) ||
          b.description.toLowerCase().contains(_query) ||
          b.label.toLowerCase().contains(_query);
    }).toList();

    // Matching Items (Full-text search)
    var matchingItems = provider.items.where((i) {
      final matchesQuery = i.name.toLowerCase().contains(_query) ||
          i.description.toLowerCase().contains(_query) ||
          i.categoryId.toLowerCase().contains(_query) ||
          (i.serialNumber != null && i.serialNumber!.toLowerCase().contains(_query)) ||
          (i.barcode != null && i.barcode!.toLowerCase().contains(_query)) ||
          i.customAttributes.entries.any((entry) =>
              entry.key.toLowerCase().contains(_query) ||
              entry.value.toString().toLowerCase().contains(_query));

      if (!matchesQuery) return false;

      // Status filters
      if (_selectedFilter == 'Stored') return i.status == ItemStatus.stored;
      if (_selectedFilter == 'In Use') return i.status == ItemStatus.inUse;
      if (_selectedFilter == 'Lent') return i.status == ItemStatus.lent;
      if (_selectedFilter == 'Perishable') return i.expiryDate != null;

      return true;
    }).toList();

    if (matchingBoxes.isEmpty && matchingItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No results for "$_query"',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Try a different name, serial number, or barcode',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        // Storage Containers Match
        if (matchingBoxes.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.meeting_room_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                'Storage Locations (${matchingBoxes.length})',
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
              const Icon(Icons.category_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                'Items (${matchingItems.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...matchingItems.map((item) {
            final breadcrumb = provider.getBreadcrumbString(item.boxId);

            return GestureDetector(
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
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF18181B),
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
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                          const SizedBox(height: 10),

                          // Breadcrumb Path display
                          GestureDetector(
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
                                color: const Color(0xFFF4F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF18181B)),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      breadcrumb,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF18181B),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
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
                                'Qty: ${provider.formatQty(item.quantity, item.unit)}${item.purchasePrice != null ? ' • ${provider.formatPrice(item.purchasePrice)}' : ''}${item.barcode != null ? ' • UPC: ${item.barcode}' : ''}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ItemCreateScreen(boxId: item.boxId, existingItem: item),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF18181B),
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
    );
  }
}
