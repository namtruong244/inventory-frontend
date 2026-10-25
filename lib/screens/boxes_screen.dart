import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/export_barcodes_sheet.dart';
import '../widgets/move_location_dialog.dart';
import 'box_create_screen.dart';
import 'box_details_screen.dart';

class BoxesScreen extends StatefulWidget {
  const BoxesScreen({super.key});

  @override
  State<BoxesScreen> createState() => _BoxesScreenState();
}

class _BoxesScreenState extends State<BoxesScreen> {
  String _searchQuery = '';
  int _filterIndex = 0; // 0: All (Tree), 1: Rooms, 2: Cabinets/Shelves, 3: Boxes/Drawers
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: Consumer<InventoryProvider>(
          builder: (context, provider, child) {
            _initExpandedIfNeeded(provider);

            List<Box> displayedBoxes = provider.boxes;

            // Apply tab filter
            if (_filterIndex == 1) {
              displayedBoxes = displayedBoxes.where((b) => b.type == StorageType.room || b.parentId == null).toList();
            } else if (_filterIndex == 2) {
              displayedBoxes = displayedBoxes.where((b) => b.type == StorageType.cabinet || b.type == StorageType.shelf).toList();
            } else if (_filterIndex == 3) {
              displayedBoxes = displayedBoxes.where((b) => b.type == StorageType.box || b.type == StorageType.drawer).toList();
            }

            // Apply search query
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              displayedBoxes = displayedBoxes.where((b) =>
                b.name.toLowerCase().contains(q) ||
                b.description.toLowerCase().contains(q) ||
                b.label.toLowerCase().contains(q)
              ).toList();
            }

            final showTree = _isTreeView && _filterIndex == 0 && _searchQuery.isEmpty;

            return ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                            'Storage Hierarchy',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: const Color(0xFF18181B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.boxes.length} locations & containers',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF71717A),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.outlined(
                          tooltip: 'Export all QR codes',
                          onPressed: provider.boxes.isEmpty
                              ? null
                              : () => ExportBarcodesSheet.showAll(context),
                          icon: const Icon(Icons.qr_code_2_rounded, size: 20),
                          style: IconButton.styleFrom(
                            foregroundColor: const Color(0xFF18181B),
                            side: const BorderSide(color: Color(0xFFE4E4E7)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.all(11),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BoxCreateScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('New Location'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF18181B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Search field
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search locations, rooms, containers...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF71717A)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF18181B), width: 1.5),
                    ),
                  ),
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
                            _buildFilterChip(0, 'All (${provider.boxes.length})'),
                            const SizedBox(width: 8),
                            _buildFilterChip(1, 'Rooms (${provider.boxes.where((b) => b.type == StorageType.room || b.parentId == null).length})'),
                            const SizedBox(width: 8),
                            _buildFilterChip(2, 'Cabinets & Shelves (${provider.boxes.where((b) => b.type == StorageType.cabinet || b.type == StorageType.shelf).length})'),
                            const SizedBox(width: 8),
                            _buildFilterChip(3, 'Boxes & Drawers (${provider.boxes.where((b) => b.type == StorageType.box || b.type == StorageType.drawer).length})'),
                          ],
                        ),
                      ),
                    ),
                    if (_filterIndex == 0 && _searchQuery.isEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE4E4E7)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: _isTreeView ? 'Switch to Flat List' : 'Switch to Tree View',
                              icon: Icon(
                                _isTreeView ? Icons.account_tree_rounded : Icons.view_agenda_outlined,
                                size: 18,
                                color: const Color(0xFF18181B),
                              ),
                              onPressed: () {
                                setState(() => _isTreeView = !_isTreeView);
                              },
                            ),
                            if (_isTreeView)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: _expandedBoxIds.isEmpty ? 'Expand all' : 'Collapse all',
                                icon: Icon(
                                  _expandedBoxIds.isEmpty ? Icons.unfold_more_rounded : Icons.unfold_less_rounded,
                                  size: 18,
                                  color: const Color(0xFF71717A),
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
                    title: 'No locations yet',
                    subtitle: 'Tap "New Location" above to create your first room or box',
                  )
                else if (displayedBoxes.isEmpty)
                  _buildEmptyState(
                    title: 'No matching locations found',
                    subtitle: 'Try searching with a different name or label',
                  )
                else if (showTree)
                  ..._buildHierarchyTree(provider)
                else
                  ...displayedBoxes.map((box) => _buildFlatBoxCard(box, provider)),
              ],
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
    final orphans = provider.boxes.where((b) => b.parentId != null && !allKnownIds.contains(b.parentId)).toList();
    final topLevel = [...rootBoxes, ...orphans];

    for (final root in topLevel) {
      widgets.addAll(_buildTreeNode(root, provider, depth: 0));
    }

    return widgets;
  }

  List<Widget> _buildTreeNode(Box box, InventoryProvider provider, {required int depth}) {
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
          borderRadius: BorderRadius.circular(20),
          child: Slidable(
            key: ValueKey(box.id),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.65,
              children: [
                SlidableAction(
                  onPressed: (_) => MoveLocationDialog.show(context, box),
                  backgroundColor: const Color(0xFF64748B),
                  foregroundColor: Colors.white,
                  icon: Icons.drive_file_move_outlined,
                  label: 'Move',
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
                  backgroundColor: const Color(0xFF18181B),
                  foregroundColor: Colors.white,
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                ),
                SlidableAction(
                  onPressed: (_) async {
                    final confirmed = await AppFeedback.showConfirmDialog(
                      context,
                      title: 'Delete Location',
                      message: 'Are you sure you want to delete "${box.name}"? All nested containers and items inside will also be deleted.',
                      confirmLabel: 'Delete Box',
                      isDestructive: true,
                      icon: Icons.delete_outline,
                    );
                    if (confirmed && mounted) {
                      final ok = await provider.deleteBox(box.id, cascade: true);
                      if (!mounted) return;
                      if (ok) {
                        AppFeedback.showSuccess(context, 'Location "${box.name}" deleted successfully');
                      } else {
                        AppFeedback.showError(context, 'Could not delete "${box.name}". Please try again.');
                      }
                    }
                  },
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: 'Delete',
                ),
              ],
            ),
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: depth == 0 ? const Color(0xFFE4E4E7) : const Color(0xFFE2E8F0),
                  width: depth == 0 ? 1.2 : 1.0,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BoxDetailsScreen(boxId: box.id),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                size: 22,
                                color: Color(0xFF71717A),
                              ),
                            ),
                          ),
                        )
                      else if (depth > 0)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.subdirectory_arrow_right_rounded,
                            size: 16,
                            color: Color(0xFFA1A1AA),
                          ),
                        )
                      else
                        const SizedBox(width: 8),

                      // Box Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: depth == 0 ? const Color(0xFFF4F4F5) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          box.type.icon,
                          color: const Color(0xFF18181B),
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
                              style: GoogleFonts.inter(
                                fontWeight: depth == 0 ? FontWeight.w700 : FontWeight.w600,
                                fontSize: depth == 0 ? 15 : 14,
                                color: const Color(0xFF18181B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${box.type.displayName} • $itemCount ${itemCount == 1 ? 'item' : 'items'}${children.isNotEmpty ? ' • ${children.length} sub-containers' : ''}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF71717A),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quick add container button
                      IconButton(
                        tooltip: 'Add sub-container',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.add_rounded, size: 20, color: Color(0xFF71717A)),
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
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Color(0xFFA1A1AA),
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

  Widget _buildFlatBoxCard(Box box, InventoryProvider provider) {
    final itemCount = provider.countTotalItemsIn(box.id);
    final subBoxCount = provider.getBoxesIn(box.id).length;
    final breadcrumbList = provider.getBreadcrumb(box.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Slidable(
          key: ValueKey(box.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.65,
            children: [
              SlidableAction(
                onPressed: (_) => MoveLocationDialog.show(context, box),
                backgroundColor: const Color(0xFF64748B),
                foregroundColor: Colors.white,
                icon: Icons.drive_file_move_outlined,
                label: 'Move',
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
                backgroundColor: const Color(0xFF18181B),
                foregroundColor: Colors.white,
                icon: Icons.edit_outlined,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: (_) async {
                  final confirmed = await AppFeedback.showConfirmDialog(
                    context,
                    title: 'Delete Location',
                    message: 'Are you sure you want to delete "${box.name}"? All nested containers and items inside will also be deleted.',
                    confirmLabel: 'Delete Box',
                    isDestructive: true,
                    icon: Icons.delete_outline,
                  );
                  if (confirmed && mounted) {
                    final ok = await provider.deleteBox(box.id, cascade: true);
                    if (!mounted) return;
                    if (ok) {
                      AppFeedback.showSuccess(context, 'Location "${box.name}" deleted successfully');
                    } else {
                      AppFeedback.showError(context, 'Could not delete "${box.name}". Please try again.');
                    }
                  }
                },
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: 'Delete',
              ),
            ],
          ),
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFE4E4E7), width: 1.0),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BoxDetailsScreen(boxId: box.id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            box.type.icon,
                            color: const Color(0xFF18181B),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                box.name,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: const Color(0xFF18181B),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${box.type.displayName} • $itemCount ${itemCount == 1 ? 'item' : 'items'}${subBoxCount > 0 ? ' • $subBoxCount nested' : ''}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF71717A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF4F4F5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF18181B),
                            size: 16,
                          ),
                        ),
                      ],
                    ),

                    // Full Breadcrumb Row without truncation
                    if (box.parentId != null && breadcrumbList.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE4E4E7)),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Icon(Icons.route_outlined, size: 14, color: Color(0xFF71717A)),
                              const SizedBox(width: 6),
                              Text(
                                'Path: ',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF71717A),
                                ),
                              ),
                              for (int i = 0; i < breadcrumbList.length; i++) ...[
                                if (i > 0)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      size: 14,
                                      color: Color(0xFFA1A1AA),
                                    ),
                                  ),
                                Text(
                                  breadcrumbList[i].name,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: i == breadcrumbList.length - 1 ? FontWeight.w600 : FontWeight.w400,
                                    color: i == breadcrumbList.length - 1 ? const Color(0xFF18181B) : const Color(0xFF52525B),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: const Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF71717A)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _filterIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF18181B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF18181B) : const Color(0xFFE4E4E7),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : const Color(0xFF27272A),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
