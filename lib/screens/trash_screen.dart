import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../widgets/app_icon.dart';

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
    final isEmpty = _items.isEmpty && _boxes.isEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.commonTrash,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!isEmpty)
            TextButton(
              onPressed: _empty,
              child: Text(
                context.l10n.commonEmpty,
                style: TextStyle(color: AppTones.coral),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _failed
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.couldNotLoadTheTrash),
                  TextButton(onPressed: _load, child: Text(context.l10n.commonRetry)),
                ],
              ),
            )
          : isEmpty
          ? Center(
              child: Text(
                context.l10n.trashIsEmpty,
                style: TextStyle(color: context.colors.textSecondary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final box in _boxes)
                    _row(
                      icon: box.type.icon,
                      name: box.name,
                      subtitle: context.l10n.commonLocation(box.type.name),
                      onRestore: () => _restore(boxId: box.id, name: box.name),
                      onPurge: () => _purge(boxId: box.id, name: box.name),
                    ),
                  for (final item in _items)
                    _row(
                      icon: Icons.inventory_2_outlined,
                      name: item.name,
                      subtitle: context.l10n.commonItem2(item.quantity, item.unit),
                      onRestore: () =>
                          _restore(itemId: item.id, name: item.name),
                      onPurge: () => _purge(itemId: item.id, name: item.name),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _row({
    required IconData icon,
    required String name,
    required String subtitle,
    required VoidCallback onRestore,
    required VoidCallback onPurge,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.colors.border),
      ),
      child: ListTile(
        leading: AppIcon(icon),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: context.l10n.commonRestore,
              icon: const AppIcon(Icons.restore_rounded),
              onPressed: onRestore,
            ),
            IconButton(
              tooltip: context.l10n.deletePermanently2,
              icon: const AppIcon(
                Icons.delete_forever_outlined,
                color: AppTones.coral,
              ),
              onPressed: onPurge,
            ),
          ],
        ),
      ),
    );
  }
}
