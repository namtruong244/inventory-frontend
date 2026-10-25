part of 'inventory_provider.dart';

/// Offline mode: local snapshot of the inventory plus an ordered queue of changes.
///
/// Ids are generated on the device and sent with every create, so replaying the queue
/// needs no id mapping and the backend can treat a repeated create as a no-op.
extension InventoryOffline on InventoryProvider {
  OfflineStore? get _store {
    final id = _apiService.currentUser?.id;
    return id == null || id.isEmpty ? null : OfflineStore(id);
  }

  /// True for failures where the server could not be reached (not API errors).
  bool _isNetworkError(Object e) => e is! ApiException;

  Future<void> _saveSnapshot() async {
    await _store?.saveSnapshot(
      InventorySnapshot(
        boxes: _boxes,
        items: _items,
        loans: _lendingRecords,
        categories: _categories,
      ),
    );
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

  Future<void> _enqueue(PendingOp op) async {
    final store = _store;
    if (store == null) return;
    final pending = await store.loadPending();
    pending.add(op);
    await store.savePending(pending);
    _pendingChanges = pending.length;
    _isOffline = true;
    _isConnected = false;
    await _saveSnapshot();
    _notify();
  }

  /// Cheap reachability check, at most every 15 seconds while offline.
  Future<bool> _probeServer() async {
    final now = DateTime.now();
    if (_lastProbe != null &&
        now.difference(_lastProbe!) < const Duration(seconds: 15)) {
      return false;
    }
    _lastProbe = now;
    try {
      await _apiService.get('/health').timeout(const Duration(seconds: 3));
    } catch (e) {
      // Any HTTP answer, even an error, means the server is reachable.
      if (_isNetworkError(e)) return false;
    }
    _isOffline = false;
    _isConnected = true;
    _errorMessage = null;
    _notify();
    return true;
  }

  /// True when the next change must be queued instead of sent: the server is known to be
  /// unreachable, or earlier changes are still waiting (to keep the original order).
  Future<bool> _mustQueue() async {
    if (_isOffline && !await _probeServer()) return true;
    if (_pendingChanges > 0) await _flushPending();
    return _pendingChanges > 0;
  }

  /// Sends a mutation, or queues [op] when the server cannot be reached.
  /// Returns true if it was applied or queued, false if the server rejected it.
  Future<bool> _commit(PendingOp op, Future<void> Function() call) async {
    if (await _mustQueue()) {
      await _enqueue(op);
      return true;
    }
    try {
      await call();
      return true;
    } catch (e) {
      if (_isNetworkError(e)) {
        await _enqueue(op);
        return true;
      }
      debugPrint('${op.type} error: $e');
      return false;
    }
  }

  /// Replays the queue in order. Stops at the first unreachable-server error and keeps
  /// the rest; changes the server rejects (e.g. target deleted meanwhile) are dropped.
  Future<void> _flushPending() async {
    final store = _store;
    if (store == null) return;
    final pending = await store.loadPending();
    if (pending.isEmpty) return;
    var rejected = 0;
    var done = 0;
    for (final op in pending) {
      try {
        await _applyPending(op);
      } catch (e) {
        if (_isNetworkError(e)) break;
        debugPrint('Dropped offline ${op.type}: $e');
        rejected++;
      }
      done++;
    }
    final remaining = pending.sublist(done);
    await store.savePending(remaining);
    _pendingChanges = remaining.length;
    if (rejected > 0) {
      _errorMessage = '$rejected offline change(s) were rejected by the server';
    }
  }

  Map<String, dynamic> _map(Object? v) => Map<String, dynamic>.from(v as Map);

  Future<void> _applyPending(PendingOp op) async {
    final a = op.args;
    switch (op.type) {
      case 'createBox':
        await _apiService.createBox(Box.fromJson(_map(a['box'])));
      case 'updateBox':
        await _apiService.updateBox(Box.fromJson(_map(a['box'])));
      case 'moveBox':
        await _apiService.moveBox(a['id'] as String, a['parentId'] as String?);
      case 'deleteBox':
        await _apiService.deleteBox(
          a['id'] as String,
          cascade: a['cascade'] == true,
        );
      case 'createItem':
        await _apiService.createItem(Item.fromJson(_map(a['item'])));
      case 'updateItem':
        await _apiService.updateItem(Item.fromJson(_map(a['item'])));
      case 'moveItem':
        await _apiService.moveItem(a['id'] as String, a['boxId'] as String);
      case 'deleteItem':
        await _apiService.deleteItem(a['id'] as String);
      case 'quantity':
        await _apiService.updateItemQuantity(
          a['id'] as String,
          (a['quantity'] as num).toDouble(),
          reason: a['reason'] as String?,
        );
      case 'lend':
        final r = LendingRecord.fromJson(_map(a['record']));
        await _apiService.lendItem(
          id: r.id,
          itemId: r.itemId,
          borrowerName: r.borrowerName,
          borrowerContact: r.borrowerContact,
          lentDate: r.lentDate,
          expectedReturnDate: r.expectedReturnDate,
          notes: r.notes,
          quantity: r.isPartial ? r.quantity : null,
        );
      case 'returnLoan':
        await _apiService.returnItem(a['id'] as String);
      case 'createCategory':
        await _apiService.createCategory(a['name'] as String);
      case 'deleteCategory':
        await _apiService.deleteCategory(a['name'] as String);
    }
  }
}
