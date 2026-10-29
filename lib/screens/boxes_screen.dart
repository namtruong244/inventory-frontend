import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/trash_actions.dart';
import '../widgets/move_location_dialog.dart';
import 'box_create_screen.dart';
import '../widgets/item_box_actions.dart';
import 'box_details_screen.dart';
import '../widgets/app_refresh.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../utils/text_normalize.dart';
import '../widgets/app_icon.dart';
import '../widgets/soft_ui.dart';

part 'boxes_screen_parts.dart';

class BoxesScreen extends StatefulWidget {
  const BoxesScreen({super.key});

  @override
  State<BoxesScreen> createState() => _BoxesScreenState();
}

class _BoxesScreenState extends State<BoxesScreen> {
  /// setState entry point for the extension in the part file.
  void _update(VoidCallback fn) => setState(fn);

  String _searchQuery = '';
  int _filterIndex =
      0; // 0: All (Tree), 1: Rooms, 2: Cabinets/Shelves, 3: Boxes/Drawers
  bool _isTreeView = true;
  final Set<String> _expandedBoxIds = {};
  bool _initializedExpanded = false;

  void _initExpandedIfNeeded(InventoryProvider provider) {
    if (!_initializedExpanded && provider.boxes.isNotEmpty) {
      // By default, expand root nodes so hierarchy is immediately visible
      for (final box in provider.boxes) {
        if (box.parentId == null) {
          _expandedBoxIds.add(box.id);
        }
      }
      _initializedExpanded = true;
    }
  }

  void _toggleExpand(String boxId) {
    setState(() {
      if (_expandedBoxIds.contains(boxId)) {
        _expandedBoxIds.remove(boxId);
      } else {
        _expandedBoxIds.add(boxId);
      }
    });
  }

  void _expandAll(InventoryProvider provider) {
    setState(() {
      for (final box in provider.boxes) {
        if (provider.getBoxesIn(box.id).isNotEmpty) {
          _expandedBoxIds.add(box.id);
        }
      }
    });
  }

  void _collapseAll() {
    setState(() {
      _expandedBoxIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<InventoryProvider>(
          builder: (context, provider, child) {
            _initExpandedIfNeeded(provider);

            List<Box> displayedBoxes = provider.boxes;

            // Apply tab filter
            if (_filterIndex == 1) {
              displayedBoxes = displayedBoxes
                  .where(
                    (b) => b.type == StorageType.room || b.parentId == null,
                  )
                  .toList();
            } else if (_filterIndex == 2) {
              displayedBoxes = displayedBoxes
                  .where(
                    (b) =>
                        b.type == StorageType.cabinet ||
                        b.type == StorageType.shelf,
                  )
                  .toList();
            } else if (_filterIndex == 3) {
              displayedBoxes = displayedBoxes
                  .where(
                    (b) =>
                        b.type == StorageType.box ||
                        b.type == StorageType.drawer,
                  )
                  .toList();
            }

            // Apply search query
            if (_searchQuery.isNotEmpty) {
              final q = normalizeVi(_searchQuery);
              displayedBoxes = displayedBoxes
                  .where(
                    (b) =>
                        containsNormalized(b.name, q) ||
                        containsNormalized(b.description, q) ||
                        containsNormalized(b.label, q),
                  )
                  .toList();
            }

            final showTree =
                _isTreeView && _filterIndex == 0 && _searchQuery.isEmpty;

            return AppRefresh(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                children: [
                  // Top Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.storageHierarchy,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.8,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${provider.boxes.length} locations & containers',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: context.colors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Search field
                  SoftSearchField(
                    hint: context.l10n.searchLocationsRoomsContainers,
                    value: _searchQuery,
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.trim()),
                    onClear: () => setState(() => _searchQuery = ''),
                  ),
                  const SizedBox(height: 14),

                  // Filter Chips & Tree Toggle
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                0,
                                context.l10n.commonAll(provider.boxes.length),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                1,
                                context.l10n.commonRooms(
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
                                context.l10n.cabinetsShelves(
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
                                context.l10n.boxesDrawers(
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
                      ),
                      if (_filterIndex == 0 && _searchQuery.isEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: context.colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: context.colors.cardShadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: _isTreeView
                                    ? context.l10n.switchToFlatList
                                    : context.l10n.switchToTreeView,
                                icon: AppIcon(
                                  _isTreeView
                                      ? Icons.account_tree_rounded
                                      : Icons.view_agenda_outlined,
                                  size: 18,
                                  color: context.colors.textPrimary,
                                ),
                                onPressed: () {
                                  setState(() => _isTreeView = !_isTreeView);
                                },
                              ),
                              if (_isTreeView)
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  tooltip: _expandedBoxIds.isEmpty
                                      ? context.l10n.expandAll
                                      : context.l10n.collapseAll,
                                  icon: AppIcon(
                                    _expandedBoxIds.isEmpty
                                        ? Icons.unfold_more_rounded
                                        : Icons.unfold_less_rounded,
                                    size: 18,
                                    color: context.colors.textSecondary,
                                  ),
                                  onPressed: () {
                                    if (_expandedBoxIds.isEmpty) {
                                      _expandAll(provider);
                                    } else {
                                      _collapseAll();
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Boxes Display (Tree View or Flat List)
                  if (provider.boxes.isEmpty)
                    _buildEmptyState(
                      title: context.l10n.noLocationsYet,
                      subtitle: context.l10n.tapNewLocationAboveTo,
                      actionLabel: context.l10n.createFirstLocation,
                      onAction: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BoxCreateScreen(),
                        ),
                      ),
                    )
                  else if (displayedBoxes.isEmpty)
                    _buildEmptyState(
                      title: context.l10n.noMatchingLocationsFound,
                      subtitle: context.l10n.trySearchingWithADifferent,
                    )
                  else if (showTree)
                    ..._buildHierarchyTree(provider)
                  else
                    ...displayedBoxes.map(
                      (box) => _buildFlatBoxCard(box, provider),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildHierarchyTree(InventoryProvider provider) {
    final rootBoxes = provider.getRootBoxes();
    final List<Widget> widgets = [];

    // Also include any orphan boxes whose parent does not exist
    final allKnownIds = provider.boxes.map((b) => b.id).toSet();
    final orphans = provider.boxes
        .where((b) => b.parentId != null && !allKnownIds.contains(b.parentId))
        .toList();
    final topLevel = [...rootBoxes, ...orphans];

    for (final root in topLevel) {
      widgets.addAll(_buildTreeNode(root, provider, depth: 0));
    }

    return widgets;
  }

  List<Widget> _buildTreeNode(
    Box box,
    InventoryProvider provider, {
    required int depth,
  }) {
    final children = provider.getBoxesIn(box.id);
    final hasChildren = children.isNotEmpty;
    final isExpanded = _expandedBoxIds.contains(box.id);
    final itemCount = provider.countTotalItemsIn(box.id);

    final List<Widget> items = [];

    items.add(
      Padding(
        padding: EdgeInsets.only(
          left: (depth * 20.0).clamp(0.0, 100.0),
          bottom: 10.0,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Slidable(
            key: ValueKey(box.id),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.65,
              children: [
                SlidableAction(
                  onPressed: (_) => MoveLocationDialog.show(context, box),
                  backgroundColor: AppTones.slate,
                  foregroundColor: Colors.white,
                  icon: Icons.drive_file_move_outlined,
                  label: context.l10n.commonMove,
                ),
                SlidableAction(
                  onPressed: (_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BoxCreateScreen(existingBox: box),
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
                    final confirmed = await TrashActions.confirm(
                      context,
                      name: box.name,
                      isBox: true,
                      hasContents: true,
                    );
                    if (confirmed && mounted) {
                      final ok = await provider.deleteBox(
                        box.id,
                        cascade: true,
                      );
                      if (!mounted) return;
                      if (ok) {
                        TrashActions.showMoved(
                          context,
                          provider,
                          name: box.name,
                          boxId: box.id,
                        );
                      } else {
                        AppFeedback.showError(
                          context,
                          context.l10n.couldNotDeletePleaseTry2(box.name),
                        );
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
            child: Material(
              color: context.colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: depth == 0
                      ? context.colors.border
                      : context.colors.border,
                  width: depth == 0 ? 1.2 : 1.0,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onLongPress: () => showBoxActionsSheet(context, box),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BoxDetailsScreen(boxId: box.id),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // Expand/collapse arrow or spacer
                      if (hasChildren)
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _toggleExpand(box.id),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: AnimatedRotation(
                              turns: isExpanded ? 0.25 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: AppIcon(
                                Icons.chevron_right_rounded,
                                size: 22,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else if (depth > 0)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: AppIcon(
                            Icons.subdirectory_arrow_right_rounded,
                            size: 16,
                            color: context.colors.textMuted,
                          ),
                        )
                      else
                        const SizedBox(width: 8),

                      // Box Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: depth == 0
                              ? context.colors.fill
                              : context.colors.fill,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppIcon(
                          box.type.icon,
                          color: context.colors.textPrimary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Box details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              box.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: depth == 0
                                    ? FontWeight.w600
                                    : FontWeight.w600,
                                fontSize: depth == 0 ? 15 : 14,
                                color: context.colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${box.type.displayName} • ${context.l10n.itemsCountLabel(itemCount)}${children.isNotEmpty ? ' • ${context.l10n.subContainersCountLabel(children.length)}' : ''}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quick add container button
                      IconButton(
                        tooltip: context.l10n.addSubContainer,
                        visualDensity: VisualDensity.compact,
                        icon: AppIcon(
                          Icons.add_rounded,
                          size: 20,
                          color: context.colors.textSecondary,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BoxCreateScreen(parentId: box.id),
                            ),
                          );
                        },
                      ),

                      // Forward arrow
                      AppIcon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: context.colors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (hasChildren && isExpanded) {
      for (final child in children) {
        items.addAll(_buildTreeNode(child, provider, depth: depth + 1));
      }
    }

    return items;
  }
}
