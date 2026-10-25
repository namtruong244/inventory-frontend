part of 'inventory_provider.dart';

/// Offline mode: local snapshot of the inventory plus a queue of stock changes.
extension InventoryOffline on InventoryProvider {
  OfflineStore? get _store {
    final id = _apiService.currentUser?.id;
    return id == null || id.isEmpty ? null : OfflineStore(id);
  }

  /// True for failures where the server could not be reached (not API errors).
  bool _isNetworkError(Object e) => e is! ApiException;

  Future<void> _saveSnapshot() async {
    await _store?.saveSnapshot(InventorySnapshot(
      boxes: _boxes,
      items: _items,
      loans: _lendingRecords,
      categories: _categories,
    ));
  }

  /// Fills the lists from the device cache. Returns false when nothing is cached.
  Future<bool> _loadSnapshot() async {
    final store = _store;
    if (store == null) return false;
    final snap = await store.loadSnapshot();
    if (snap == null) return false;
    _boxes
      ..clear()
      ..addAll(snap.boxes);
    _items
      ..clear()
      ..addAll(snap.items);
    _lendingRecords
      ..clear()
      ..addAll(snap.loans);
    if (snap.categories.isNotEmpty) {
      _categories
        ..clear()
        ..addAll(snap.categories);
    }
    _pendingChanges = (await store.loadPending()).length;
    return true;
  }

  Future<void> _queueQuantityChange(String itemId, double quantity, String? reason) async {
    final store = _store;
    if (store == null) return;
    final pending = await store.loadPending();
    // Quantities are absolute, so only the latest value per item matters.
    pending.removeWhere((p) => p.itemId == itemId);
    pending.add(PendingQuantityChange(itemId, quantity, reason));
    await store.savePending(pending);
    _pendingChanges = pending.length;
    await _saveSnapshot();
    _notify();
  }

  /// Replays queued stock changes; keeps the ones that still cannot reach the server.
  Future<void> _flushPending() async {
    final store = _store;
    if (store == null) return;
    final pending = await store.loadPending();
    if (pending.isEmpty) return;
    final remaining = <PendingQuantityChange>[];
    for (final p in pending) {
      try {
        await _apiService.updateItemQuantity(p.itemId, p.quantity, reason: p.reason);
      } catch (e) {
        // Rejected changes (e.g. item deleted meanwhile) are dropped; unreachable ones retry later.
        if (_isNetworkError(e)) remaining.add(p);
      }
    }
    await store.savePending(remaining);
    _pendingChanges = remaining.length;
  }
}
