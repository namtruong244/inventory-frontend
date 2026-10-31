part of 'boxes_screen.dart';

/// Tree and flat-list builders for the Box tab.
extension _BoxesScreenParts on _BoxesScreenState {
  Widget _buildFilterChip(int index, String label) => SoftFilterChip(
    label: label,
    selected: _filterIndex == index,
    onTap: () => _update(() => _filterIndex = index),
  );

  void _open(Box box) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => BoxDetailsScreen(boxId: box.id)),
  );

  int _descendantCount(InventoryProvider p, String id) {
    var n = 0;
    for (final child in p.getBoxesIn(id)) {
      n += 1 + _descendantCount(p, child.id);
    }
    return n;
  }

  String _meta(InventoryProvider p, Box box, int containers) {
    final parts = [
      context.l10n.itemsCountLabel(p.countTotalItemsIn(box.id)),
      if (containers > 0) context.l10n.subContainersCountLabel(containers),
    ];
    return parts.join(' · ');
  }

  int _alertCount(InventoryProvider p, String boxId) =>
      p.getItemsIn(boxId).where((i) => i.isLowStock || i.isExpired).length;

  List<Widget> _buildHierarchyTree(InventoryProvider provider) {
    // Orphans (parent missing) are shown at the top level too.
    final known = provider.boxes.map((b) => b.id).toSet();
    final topLevel = [
      ...provider.getRootBoxes(),
      ...provider.boxes.where(
        (b) => b.parentId != null && !known.contains(b.parentId),
      ),
    ];
    return [
      for (final root in topLevel) ...[
        _buildRootCard(root, provider),
        const SizedBox(height: 12),
      ],
    ];
  }

  Widget _buildRootCard(Box root, InventoryProvider provider) {
    final children = provider.getBoxesIn(root.id);
    final expanded = children.isNotEmpty && _expandedBoxIds.contains(root.id);
    return SoftCard(
      radius: expanded ? 24 : 20,
      child: Column(
        children: [
          BoxSlidable(
            box: root,
            provider: provider,
            child: Material(
              color: context.colors.surface,
              child: BoxTreeRow(
                box: root,
                meta: _meta(
                  provider,
                  root,
                  _descendantCount(provider, root.id),
                ),
                hasChildren: children.isNotEmpty,
                expanded: expanded,
                onTap: () => _open(root),
                onLongPress: () => showBoxActionsSheet(context, root),
                onToggle: () => _toggleExpand(root.id),
              ),
            ),
          ),
          if (expanded) ...[
            ..._buildChildNodes(root, provider, 1, const []),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildChildNodes(
    Box parent,
    InventoryProvider provider,
    int depth,
    List<bool> continues,
  ) {
    final children = provider.getBoxesIn(parent.id);
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      final box = children[i];
      final isLast = i == children.length - 1;
      final sub = provider.getBoxesIn(box.id);
      final expanded = sub.isNotEmpty && _expandedBoxIds.contains(box.id);
      out.add(
        BoxSlidable(
          box: box,
          provider: provider,
          child: Material(
            color: context.colors.surface,
            child: BoxTreeNodeRow(
              box: box,
              meta: _meta(provider, box, sub.length),
              depth: depth,
              continues: continues,
              isLast: isLast,
              alertCount: _alertCount(provider, box.id),
              hasChildren: sub.isNotEmpty,
              expanded: expanded,
              onTap: () => _open(box),
              onLongPress: () => showBoxActionsSheet(context, box),
              onToggle: () => _toggleExpand(box.id),
            ),
          ),
        ),
      );
      if (expanded) {
        out.addAll(
          _buildChildNodes(box, provider, depth + 1, [...continues, !isLast]),
        );
      }
    }
    return out;
  }

  Widget _buildFlatRow(Box box, InventoryProvider provider) {
    final crumbs = box.parentId == null
        ? const <Box>[]
        : provider.getBreadcrumb(box.id);
    // Breadcrumb ends with the box itself; show only its ancestors.
    final path = crumbs.length > 1
        ? crumbs.take(crumbs.length - 1).map((b) => b.name).join(' › ')
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        radius: 20,
        child: BoxSlidable(
          box: box,
          provider: provider,
          child: Material(
            color: context.colors.surface,
            child: BoxTreeRow(
              box: box,
              meta: _meta(provider, box, provider.getBoxesIn(box.id).length),
              path: path,
              onTap: () => _open(box),
              onLongPress: () => showBoxActionsSheet(context, box),
            ),
          ),
        ),
      ),
    );
  }
}
