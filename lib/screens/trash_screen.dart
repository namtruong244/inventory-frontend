import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../utils/e2e.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/soft_ui.dart';
import '../widgets/state_views.dart';
import '../widgets/trash_actions.dart';
import '../widgets/trash_parts.dart';
import '../widgets/box_tree.dart' show boxTypeTone;

/// Soft-deleted items and boxes, with restore and permanent delete.
class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  List<Item> _items = [];
  List<Box> _boxes = [];
  bool _loading = true;
  bool _failed = false;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    final trash = await context.read<InventoryProvider>().fetchTrash();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _failed = trash == null;
      _items = trash?.items ?? [];
      _boxes = trash?.boxes ?? [];
    });
  }

  Future<void> _restore({
    String? itemId,
    String? boxId,
    required String name,
  }) async {
    final ok = await context.read<InventoryProvider>().restoreFromTrash(
      itemId: itemId,
      boxId: boxId,
    );
    if (!mounted) return;
    if (ok) {
      AppFeedback.showSuccess(context, '"$name" restored');
      _load();
    } else {
      AppFeedback.showError(context, context.l10n.couldNotRestore(name));
    }
  }

  Future<void> _purge({
    String? itemId,
    String? boxId,
    required String name,
  }) async {
    final confirmed = await AppFeedback.showConfirmDialog(
      context,
      title: context.l10n.deletePermanently,
      message: '"$name" will be removed for good. This cannot be undone.',
      confirmLabel: context.l10n.commonDelete,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    final ok = await context.read<InventoryProvider>().purgeFromTrash(
      itemId: itemId,
      boxId: boxId,
    );
    if (!mounted) return;
    if (ok) {
      _load();
    } else {
      AppFeedback.showError(context, context.l10n.couldNotDelete(name));
    }
  }

  Future<void> _empty() async {
    final confirmed = await AppFeedback.showConfirmDialog(
      context,
      title: context.l10n.emptyTrash,
      message: context.l10n.everythingInTheTrashWill,
      confirmLabel: context.l10n.commonEmpty,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    final ok = await context.read<InventoryProvider>().emptyTrash();
    if (!mounted) return;
    if (ok) {
      _load();
    } else {
      AppFeedback.showError(context, context.l10n.couldNotEmptyTheTrash);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final isEmpty = _items.isEmpty && _boxes.isEmpty;
    // Newest deletion first; rows without a date keep boxes-then-items order.
    final entries = <({Box? box, Item? item, DateTime? at})>[
      for (final b in _boxes) (box: b, item: null, at: b.deletedAt),
      for (final i in _items) (box: null, item: i, at: i.deletedAt),
    ];
    final order = {for (var k = 0; k < entries.length; k++) entries[k]: k};
    entries.sort((x, y) {
      if (x.at != null && y.at != null) {
        final d = y.at!.compareTo(x.at!);
        if (d != 0) return d;
      }
      return order[x]!.compareTo(order[y]!);
    });
    final showBoxes = _filter != 'items';
    final showItems = _filter != 'locations';
    final shownEmpty =
        (!showBoxes || _boxes.isEmpty) && (!showItems || _items.isEmpty);
    return Scaffold(
      backgroundColor: c.background,
      appBar: SoftTopAppBar(title: l10n.commonTrash, backId: 'trash_back'),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: SkeletonList(),
            )
          : _failed
          ? ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              children: [
                ErrorStateCard(
                  title: l10n.couldNotLoadTheTrash,
                  body: l10n.trashLoadErrorBody,
                  onRetry: _load,
                ),
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                      children: [
                        if (isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: EmptyStateCard(
                              icon: Icons.delete_outline_rounded,
                              title: l10n.trashIsEmpty,
                              subtitle: l10n.trashEmptySubtitle,
                            ),
                          )
                        else ...[
                          const TrashInfoBanner(),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _chip(
                                'all',
                                l10n.trashFilterAll(
                                  _items.length + _boxes.length,
                                ),
                              ),
                              _chip(
                                'items',
                                l10n.trashFilterItems(_items.length),
                              ),
                              _chip(
                                'locations',
                                l10n.trashFilterLocations(_boxes.length),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (shownEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: EmptyStateCard(
                                icon: Icons.delete_outline_rounded,
                                title: l10n.trashIsEmpty,
                                subtitle: l10n.trashEmptySubtitle,
                              ),
                            ),
                          for (final e in entries)
                            if (e.box != null ? showBoxes : showItems)
                              Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: e.box != null
                                    ? _boxRow(e.box!)
                                    : _itemRow(e.item!),
                              ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (!isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: e2eId(
                      'trash_empty',
                      TrashActionButton(
                        label: l10n.trashEmptyAction,
                        icon: Icons.delete_outline_rounded,
                        danger: true,
                        height: 52,
                        onTap: _empty,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  static int? _daysSince(DateTime? at) =>
      at == null ? null : DateTime.now().difference(at).inDays.clamp(0, 100000);

  String _when(DateTime? at) {
    final d = _daysSince(at);
    if (d == null) return '';
    return ' · ${d == 0 ? context.l10n.trashDeletedToday : context.l10n.trashDeletedDaysAgo(d)}';
  }

  int? _daysLeft(DateTime? at) {
    final d = _daysSince(at);
    return d == null ? null : (TrashActions.retentionDays - d).clamp(0, 30);
  }

  Widget _boxRow(Box box) {
    final tone = boxTypeTone(box.type);
    return TrashRowCard(
      icon: box.type.icon,
      iconColor: tone.fg,
      iconBackground: tone.bg,
      name: box.name,
      subtitle:
          context.l10n.commonLocation(box.type.displayName) +
          _when(box.deletedAt),
      daysLeft: _daysLeft(box.deletedAt),
      onRestore: () => _restore(boxId: box.id, name: box.name),
      onPurge: () => _purge(boxId: box.id, name: box.name),
    );
  }

  Widget _itemRow(Item item) {
    // "1 pc" / "2 pcs": count and pluralized unit for the l10n template.
    final qty = AppFormatters.formatQuantity(
      item.quantity,
      item.unit,
    ).split(' ');
    return TrashRowCard(
      icon: CategoryHelper.getCategoryIcon(item.categoryId),
      name: item.name,
      subtitle:
          context.l10n.commonItem2(qty.first, qty.skip(1).join(' ')) +
          _when(item.deletedAt),
      daysLeft: _daysLeft(item.deletedAt),
      onRestore: () => _restore(itemId: item.id, name: item.name),
      onPurge: () => _purge(itemId: item.id, name: item.name),
    );
  }

  Widget _chip(String key, String label) => e2eId(
    'trash_filter_$key',
    SoftFilterChip(
      label: label,
      selected: _filter == key,
      onTap: () => setState(() => _filter = key),
    ),
  );
}
