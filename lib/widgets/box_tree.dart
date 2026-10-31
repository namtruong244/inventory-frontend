import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../screens/box_create_screen.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_feedback.dart';
import 'app_icon.dart';
import 'move_location_dialog.dart';
import 'tappable.dart';
import 'trash_actions.dart';

/// Foreground / background pair for the tile of a storage type.
({Color fg, Color bg}) boxTypeTone(StorageType type) {
  switch (type) {
    case StorageType.room:
      return (fg: AppTones.sky, bg: AppTones.skySoft);
    case StorageType.cabinet:
      return (fg: AppTones.amber, bg: AppTones.amberSoft);
    case StorageType.shelf:
      return (fg: AppTones.matcha, bg: AppTones.matchaSoft);
    case StorageType.box:
      return (fg: AppTones.lilac, bg: AppTones.lilacSoft);
    case StorageType.drawer:
      return (fg: AppTones.coral, bg: AppTones.coralSoft);
    case StorageType.other:
      return (fg: AppTones.slate, bg: AppTones.slateSoft);
  }
}

/// Swipe actions (move / edit / delete) shared by every box row.
class BoxSlidable extends StatelessWidget {
  final Box box;
  final InventoryProvider provider;
  final Widget child;

  const BoxSlidable({
    super.key,
    required this.box,
    required this.provider,
    required this.child,
  });

  Future<void> _delete(BuildContext context) async {
    final confirmed = await TrashActions.confirm(
      context,
      name: box.name,
      isBox: true,
      hasContents: true,
    );
    if (!confirmed || !context.mounted) return;
    final ok = await provider.deleteBox(box.id, cascade: true);
    if (!context.mounted) return;
    if (ok) {
      TrashActions.showMoved(context, provider, name: box.name, boxId: box.id);
    } else {
      AppFeedback.showError(
        context,
        context.l10n.couldNotDeletePleaseTry2(box.name),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
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
            onPressed: (_) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BoxCreateScreen(existingBox: box),
              ),
            ),
            backgroundColor: context.colors.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit_outlined,
            label: context.l10n.commonEdit,
          ),
          SlidableAction(
            onPressed: (_) => _delete(context),
            backgroundColor: AppTones.coral,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: context.l10n.commonDelete,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Chevron that expands/collapses a node, or a plain "open" chevron.
class _TrailingChevron extends StatelessWidget {
  final Box box;
  final bool hasChildren;
  final bool expanded;
  final VoidCallback? onToggle;
  final double size;

  const _TrailingChevron({
    required this.box,
    required this.hasChildren,
    required this.expanded,
    required this.onToggle,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textSecondary;
    if (!hasChildren || onToggle == null) {
      return AppIcon(Icons.chevron_right_rounded, size: size, color: color);
    }
    return e2eId(
      'box_expand_${box.name}',
      Tappable(
        semanticLabel: expanded
            ? context.l10n.collapseAll
            : context.l10n.expandAll,
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedRotation(
            turns: expanded ? 0.75 : 0.25,
            duration: const Duration(milliseconds: 200),
            child: AppIcon(
              Icons.chevron_right_rounded,
              size: size,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Root-level row / flat-list row (design BoxRow): 44 tile, name, meta.
class BoxTreeRow extends StatelessWidget {
  final Box box;
  final String meta;
  final String? path;
  final bool hasChildren;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onToggle;

  const BoxTreeRow({
    super.key,
    required this.box,
    required this.meta,
    required this.onTap,
    required this.onLongPress,
    this.path,
    this.hasChildren = false,
    this.expanded = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = boxTypeTone(box.type);
    // The expand chevron is a sibling of the tappable body so it keeps its own
    // semantics node (a merged parent would swallow its id and hit area).
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
      child: Row(
        children: [
          Expanded(
            child: e2eId(
              'box_card_${box.name}',
              Tappable(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                onLongPress: onLongPress,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: tone.bg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: AppIcon(box.type.icon, size: 22, color: tone.fg),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            box.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: c.textSecondary,
                            ),
                          ),
                          if (path != null) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                AppIcon(
                                  Icons.route_outlined,
                                  size: 12,
                                  color: c.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    path!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: c.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _TrailingChevron(
            box: box,
            hasChildren: hasChildren,
            expanded: expanded,
            onToggle: onToggle,
            size: 18,
          ),
        ],
      ),
    );
  }
}

/// Nested row inside an expanded card, with L-shaped guide lines.
class BoxTreeNodeRow extends StatelessWidget {
  final Box box;
  final String meta;
  final int depth;

  /// For each ancestor level below the root: does its guide line continue?
  final List<bool> continues;
  final bool isLast;
  final int alertCount;
  final bool hasChildren;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onToggle;

  const BoxTreeNodeRow({
    super.key,
    required this.box,
    required this.meta,
    required this.depth,
    required this.continues,
    required this.isLast,
    required this.onTap,
    required this.onLongPress,
    this.alertCount = 0,
    this.hasChildren = false,
    this.expanded = false,
    this.onToggle,
  });

  static const double _step = 31;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = boxTypeTone(box.type);
    final guideWidth = _step * (depth - 1) + 22;
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 6),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: guideWidth,
              child: CustomPaint(
                painter: _GuidePainter(
                  color: c.border,
                  continues: continues,
                  isLast: isLast,
                  depth: depth,
                  step: _step,
                ),
              ),
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: e2eId(
                          'box_card_${box.name}',
                          Tappable(
                            behavior: HitTestBehavior.opaque,
                            onTap: onTap,
                            onLongPress: onLongPress,
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: tone.bg,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: AppIcon(
                                    box.type.icon,
                                    size: 18,
                                    color: tone.fg,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        box.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: c.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        meta,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: c.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (alertCount > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: c.dangerSoft,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '$alertCount',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: c.dangerStrong,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      _TrailingChevron(
                        box: box,
                        hasChildren: hasChildren,
                        expanded: expanded,
                        onToggle: onToggle,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  final Color color;
  final List<bool> continues;
  final bool isLast;
  final int depth;
  final double step;

  _GuidePainter({
    required this.color,
    required this.continues,
    required this.isLast,
    required this.depth,
    required this.step,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final mid = size.height / 2;
    // Ancestor lines that keep running past this row.
    for (var i = 0; i < continues.length; i++) {
      if (continues[i]) {
        canvas.drawRect(Rect.fromLTWH(9 + step * i, 0, 2, size.height), p);
      }
    }
    final x = 9 + step * (depth - 1);
    canvas.drawRect(Rect.fromLTWH(x, 0, 2, isLast ? mid + 1 : size.height), p);
    canvas.drawRect(Rect.fromLTWH(x, mid - 1, 12, 2), p);
  }

  @override
  bool shouldRepaint(_GuidePainter old) =>
      old.color != color ||
      old.isLast != isLast ||
      old.depth != depth ||
      old.continues.length != continues.length ||
      !_same(old.continues, continues);

  static bool _same(List<bool> a, List<bool> b) {
    for (var i = 0; i < a.length && i < b.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Tree / list segmented toggle from the title row.
class BoxViewToggle extends StatelessWidget {
  final bool isTree;
  final ValueChanged<bool> onChanged;

  const BoxViewToggle({
    super.key,
    required this.isTree,
    required this.onChanged,
  });

  Widget _cell(
    BuildContext context, {
    required IconData icon,
    required bool selected,
    required String tooltip,
    required String id,
    required VoidCallback onTap,
  }) {
    final c = context.colors;
    return e2eId(
      id,
      Tappable(
        semanticLabel: tooltip,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 32,
            decoration: BoxDecoration(
              color: selected ? c.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected ? c.cardShadow : null,
            ),
            child: AppIcon(
              icon,
              size: 18,
              color: selected ? c.textPrimary : c.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _cell(
            context,
            icon: Icons.account_tree_rounded,
            selected: isTree,
            tooltip: context.l10n.switchToTreeView,
            id: 'boxes_view_tree',
            onTap: () => onChanged(true),
          ),
          const SizedBox(width: 2),
          _cell(
            context,
            icon: Icons.view_agenda_outlined,
            selected: !isTree,
            tooltip: context.l10n.switchToFlatList,
            id: 'boxes_view_list',
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}
