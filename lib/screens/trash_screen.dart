import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';

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
      AppFeedback.showError(context, 'Could not restore "$name"');
    }
  }

  Future<void> _purge({
    String? itemId,
    String? boxId,
    required String name,
  }) async {
    final confirmed = await AppFeedback.showConfirmDialog(
      context,
      title: 'Delete permanently?',
      message: '"$name" will be removed for good. This cannot be undone.',
      confirmLabel: 'Delete',
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
      AppFeedback.showError(context, 'Could not delete "$name"');
    }
  }

  Future<void> _empty() async {
    final confirmed = await AppFeedback.showConfirmDialog(
      context,
      title: 'Empty trash?',
      message: 'Everything in the trash will be removed for good.',
      confirmLabel: 'Empty',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    final ok = await context.read<InventoryProvider>().emptyTrash();
    if (!mounted) return;
    if (ok) {
      _load();
    } else {
      AppFeedback.showError(context, 'Could not empty the trash');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _items.isEmpty && _boxes.isEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trash',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!isEmpty)
            TextButton(
              onPressed: _empty,
              child: const Text(
                'Empty',
                style: TextStyle(color: Color(0xFFDC2626)),
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
                  const Text('Could not load the trash'),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            )
          : isEmpty
          ? Center(
              child: Text(
                'Trash is empty',
                style: TextStyle(color: Colors.grey.shade600),
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
                      subtitle: 'Location · ${box.type.name}',
                      onRestore: () => _restore(boxId: box.id, name: box.name),
                      onPurge: () => _purge(boxId: box.id, name: box.name),
                    ),
                  for (final item in _items)
                    _row(
                      icon: Icons.inventory_2_outlined,
                      name: item.name,
                      subtitle: 'Item · ${item.quantity} ${item.unit}',
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
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Restore',
              icon: const Icon(Icons.restore_rounded),
              onPressed: onRestore,
            ),
            IconButton(
              tooltip: 'Delete permanently',
              icon: const Icon(
                Icons.delete_forever_outlined,
                color: Color(0xFFDC2626),
              ),
              onPressed: onPurge,
            ),
          ],
        ),
      ),
    );
  }
}
