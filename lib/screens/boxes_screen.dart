import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import '../utils/text_normalize.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_icon.dart';
import '../widgets/app_refresh.dart';
import '../widgets/box_tree.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/item_box_actions.dart';
import '../widgets/soft_ui.dart';
import '../widgets/state_views.dart';
import '../widgets/tappable.dart';
import 'box_create_screen.dart';
import 'box_details_screen.dart';

part 'boxes_screen_parts.dart';

class BoxesScreen extends StatefulWidget {
  const BoxesScreen({super.key});

  @override
  State<BoxesScreen> createState() => _BoxesScreenState();
}

class _BoxesScreenState extends State<BoxesScreen> {
  String _searchQuery = '';
  int _filterIndex =
      0; // 0: All (Tree), 1: Rooms, 2: Cabinets/Shelves, 3: Boxes/Drawers
  bool _isTreeView = true;
  final Set<String> _expandedBoxIds = {};
  bool _initializedExpanded = false;

  /// setState entry point for the extension in the part file.
  void _update(VoidCallback fn) => setState(fn);

  void _initExpandedIfNeeded(InventoryProvider provider) {
    if (!_initializedExpanded && provider.boxes.isNotEmpty) {
      // By default, expand root nodes so hierarchy is immediately visible
      for (final box in provider.boxes) {
        if (box.parentId == null) _expandedBoxIds.add(box.id);
      }
      _initializedExpanded = true;
    }
  }

  void _toggleExpand(String boxId) {
    setState(() {
      if (!_expandedBoxIds.remove(boxId)) _expandedBoxIds.add(boxId);
    });
  }

  void _expandAll(InventoryProvider provider) {
    setState(() {
      for (final box in provider.boxes) {
        if (provider.getBoxesIn(box.id).isNotEmpty) _expandedBoxIds.add(box.id);
      }
    });
  }

  void _collapseAll() => setState(_expandedBoxIds.clear);

  List<Box> _displayed(InventoryProvider provider) {
    var list = provider.boxes;
    if (_filterIndex == 1) {
      list = list
          .where((b) => b.type == StorageType.room || b.parentId == null)
          .toList();
    } else if (_filterIndex == 2) {
      list = list
          .where(
            (b) => b.type == StorageType.cabinet || b.type == StorageType.shelf,
          )
          .toList();
    } else if (_filterIndex == 3) {
      list = list
          .where(
            (b) => b.type == StorageType.box || b.type == StorageType.drawer,
          )
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = normalizeVi(_searchQuery);
      list = list
          .where(
            (b) =>
                containsNormalized(b.name, q) ||
                containsNormalized(b.description, q) ||
                containsNormalized(b.label, q),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<InventoryProvider>(
          builder: (context, provider, child) {
            _initExpandedIfNeeded(provider);
            final displayed = _displayed(provider);
            final showTree =
                _isTreeView && _filterIndex == 0 && _searchQuery.isEmpty;
            final roots = provider.boxes
                .where((b) => b.parentId == null)
                .length;
            final failed =
                !provider.isLoading &&
                !provider.isConnected &&
                !provider.isOffline;

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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.storageHierarchy,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.locationsItemsSubtitle(
                                provider.boxes.length,
                                provider.items.length,
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      BoxViewToggle(
                        isTree: _isTreeView,
                        onChanged: (v) => setState(() => _isTreeView = v),
                      ),
                    ],
                  ),
                  if (failed) ...[
                    const SizedBox(height: 20),
                    ConnectionErrorBanner(
                      onRetry: () => provider.fetchAllData(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  e2eId(
                    'boxes_search',
                    SoftSearchField(
                      hint: l10n.searchLocationsRoomsContainers,
                      value: _searchQuery,
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.trim()),
                      onClear: () => setState(() => _searchQuery = ''),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          0,
                          l10n.commonAll(provider.boxes.length),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          1,
                          l10n.commonRooms(
                            provider.boxes
                                .where(
                                  (b) =>
                                      b.type == StorageType.room ||
                                      b.parentId == null,
                                )
                                .length,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          2,
                          l10n.cabinetsShelves(
                            provider.boxes
                                .where(
                                  (b) =>
                                      b.type == StorageType.cabinet ||
                                      b.type == StorageType.shelf,
                                )
                                .length,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          3,
                          l10n.boxesDrawers(
                            provider.boxes
                                .where(
                                  (b) =>
                                      b.type == StorageType.box ||
                                      b.type == StorageType.drawer,
                                )
                                .length,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (provider.boxes.isEmpty && provider.isLoading)
                    const SkeletonList(count: 4)
                  else if (provider.boxes.isEmpty)
                    EmptyStateCard(
                      icon: Icons.inventory_2_outlined,
                      title: l10n.noLocationsYet,
                      subtitle: l10n.tapNewLocationAboveTo,
                      actionLabel: l10n.createFirstLocation,
                      onAction: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BoxCreateScreen(),
                        ),
                      ),
                    )
                  else if (displayed.isEmpty)
                    EmptyStateCard(
                      icon: Icons.search_rounded,
                      title: l10n.noMatchingLocationsFound,
                      subtitle: l10n.trySearchingWithADifferent,
                    )
                  else ...[
                    _buildToolbar(
                      provider,
                      showTree ? roots : displayed.length,
                      showTree,
                    ),
                    const SizedBox(height: 12),
                    if (showTree)
                      ..._buildHierarchyTree(provider)
                    else
                      ...displayed.map((b) => _buildFlatRow(b, provider)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildToolbar(InventoryProvider provider, int count, bool showTree) {
    final c = context.colors;
    final collapsed = _expandedBoxIds.isEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.l10n.locationsCountLabel(count),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: c.textSecondary,
          ),
        ),
        if (showTree)
          e2eId(
            'boxes_expand_all',
            Tappable(
              behavior: HitTestBehavior.opaque,
              onTap: () => collapsed ? _expandAll(provider) : _collapseAll(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    AppIcon(
                      collapsed
                          ? Icons.unfold_more_rounded
                          : Icons.unfold_less_rounded,
                      size: 16,
                      color: c.textPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      collapsed
                          ? context.l10n.expandAll
                          : context.l10n.collapseAll,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
