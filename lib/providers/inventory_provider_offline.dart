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

  /// True for failures where the server could not be reached or is failing
  /// temporarily (network, timeout, 5xx, 408, 429, non-JSON answer).
  bool _isNetworkError(Object e) => isNetworkError(e);

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
    final settings = await store.loadSettings();
    if (settings != null) _applySettings(settings);
    _pendingChanges = (await store.loadPending()).length;
    _failedOps = await store.loadFailed();
    return true;
  }

  /// Startup: fills the lists from the device cache before any network request, so the
  /// app has content even when the server answers slowly or not at all.
  Future<void> _restoreFromCache() async {
    final user = _apiService.currentUser;
    if (!_apiService.isAuthenticated || user == null) return;
    _userName = user.name;
    _userRole = user.role;
    if (await _loadSnapshot()) _notify();
  }

  /// Switches to offline mode: shows the cached data (the lists already hold it when
  /// [_restoreFromCache] ran) and says so in the banner.
  Future<void> _goOffline() async {
    final hadCache =
        await _loadSnapshot() || _boxes.isNotEmpty || _items.isNotEmpty;
    _isOffline = true;
    _isConnected = false;
    _errorMessage = hadCache
        ? AppL10n.current.syncOffline
        : AppL10n.current.cannotReachTheServer;
    _notify();
  }

  /// Active and overdue loans, plus the most recent returned ones (best effort).
  Future<List<LendingRecord>> _fetchLoans() async {
    final results = await Future.wait([
      _apiService.getActiveLoans(),
      _apiService.getOverdueLoans(),
    ]);
    final loans = <LendingRecord>[];
    final seenIds = <String>{};
    for (final record in [...results[0], ...results[1]]) {
      if (seenIds.add(record.id)) loans.add(record);
    }
    try {
      for (final h in await _apiService.getReturnedLoans()) {
        if (seenIds.add(h.id)) loans.add(h);
      }
    } catch (_) {}
    return loans;
  }

  Future<void> _enqueue(PendingOp op) async {
    final store = _store;
    if (store == null) return;
    _pendingChanges = await store.enqueue(op);
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

  /// Reachability check that ignores the 15 s throttle (explicit user action).
  Future<bool> _probeServerNow() async {
    _lastProbe = null;
    return _probeServer();
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
    _reloadedAfterConflict = false;
    if (await _mustQueue()) {
      await _enqueue(op);
      return true;
    }
    try {
      await call();
      await _refreshItemVersion(op);
      return true;
    } catch (e) {
      if (_isNetworkError(e)) {
        await _enqueue(op);
        return true;
      }
      debugPrint('${op.type} error: $e');
      if (e is ApiException &&
          e.statusCode == 409 &&
          op.type.startsWith('update')) {
        // Changed elsewhere: show the latest version instead of the stale edit.
        _errorMessage = AppL10n.current.thisWasChangedElsewhereShowing;
        await fetchAllData();
        _reloadedAfterConflict = true;
      }
      return false;
    }
  }

  /// [_commit] plus the undo of the optimistic change: when the server rejects the
  /// mutation [restore] puts the previous state back (a 409 already reloaded the data).
  Future<bool> _commitOrRollback(
    PendingOp op,
    Future<void> Function() call,
    void Function() restore,
  ) async {
    final ok = await _commit(op, call);
    if (!ok && !_reloadedAfterConflict) {
      restore();
      _notify();
    }
    return ok;
  }

  /// The server bumps an item's updatedAt on quantity, move and loan changes. Pick the new
  /// value up so a later offline edit of the same item is not rejected as a stale write.
  Future<void> _refreshItemVersion(PendingOp op) async {
    final a = op.args;
    final String? itemId;
    switch (op.type) {
      case 'moveItem' || 'quantity' || 'adjustQuantity':
        itemId = a['id'] as String?;
      case 'lend':
        itemId = _map(a['record'])['itemId'] as String?;
      case 'returnLoan':
        itemId = _lendingRecords
            .where((l) => l.id == a['id'])
            .firstOrNull
            ?.itemId;
      default:
        return;
    }
    if (itemId == null) return;
    try {
      final latest = await _apiService.getItemById(itemId);
      final i = _items.indexWhere((x) => x.id == itemId);
      if (i != -1) {
        _items[i] = _items[i].copyWith(updatedAt: latest.updatedAt);
        _notify();
      }
    } catch (_) {
      // Best effort: the next full sync refreshes it.
    }
  }

  /// Replays the queue in order, one flush at a time (a second caller waits for the
  /// running one). Each finished op is removed by id, so changes queued meanwhile survive.
  ///  * unreachable server / 5xx / 429: stop, keep everything;
  ///  * 401: stop, keep everything, the session-expired flow sends the user to sign in;
  ///  * business 4xx: drop the op (409 on an edit is parked for the user to decide);
  ///  * broken op (parse/cast error): retried up to [maxPoisonAttempts], then parked.
  Future<void> _flushPending() async {
    final running = _flushing;
    if (running != null) return running.future;
    final done = _flushing = Completer<void>();
    try {
      await _runFlush();
    } finally {
      _flushing = null;
      done.complete();
    }
  }

  Future<void> _runFlush() async {
    final store = _store;
    if (store == null) return;
    var rejected = 0;
    var parked = 0;
    final touched = <String>{};
    final seen = <String>{};
    while (true) {
      final queue = await store.loadPending();
      _pendingChanges = queue.length;
      final op = queue.where((o) => !seen.contains(o.id)).firstOrNull;
      if (op == null) break;
      seen.add(op.id);
      try {
        await _applyPending(op, touched);
        _pendingChanges = await store.removePending(op.id);
        continue;
      } catch (e) {
        final kind = classifySyncError(e);
        debugPrint('Offline ${op.type} failed ($kind): $e');
        if (kind == SyncFailure.retry || kind == SyncFailure.auth) break;
        if (kind == SyncFailure.reject) {
          final conflict = e is ApiException && e.statusCode == 409;
          if (conflict && op.type.startsWith('update')) {
            _pendingChanges = await store.parkFailed(op, friendlyError(e));
            parked++;
          } else {
            _pendingChanges = await store.removePending(op.id);
            rejected++;
            _syncNotices = [
              ..._syncNotices,
              AppL10n.current.opRejectedBecause(
                describePendingOp(op),
                friendlyError(e),
              ),
            ];
          }
          continue;
        }
        // Poison: keep the order, but give up on the op after a few tries.
        if (op.attempts + 1 >= maxPoisonAttempts) {
          _pendingChanges = await store.parkFailed(op, friendlyError(e));
          parked++;
          continue;
        }
        await store.mutatePending((q) {
          final i = q.indexWhere((o) => o.id == op.id);
          if (i != -1) q[i] = q[i].copyWith(attempts: op.attempts + 1);
        });
        break;
      }
    }
    _failedOps = await store.loadFailed();
    if (rejected > 0) {
      _errorMessage = AppL10n.current.changesRejectedByServer(rejected);
    }
    if (parked > 0) {
      _errorMessage = AppL10n.current.changesNeedAttention(parked);
    }
  }

  /// Why the server dropped some offline changes (shown until dismissed).
  List<String> get syncNotices => List.unmodifiable(_syncNotices);

  void dismissSyncNotices() {
    _syncNotices = [];
    _notify();
  }

  /// App came back to the foreground: sync when offline or changes are waiting.
  Future<void> onAppResumed() async {
    if (!_apiService.isAuthenticated || _sessionExpired || _isSyncing) return;
    if (_isOffline || _pendingChanges > 0) await fetchAllData();
  }

  /// While offline (or with queued changes) probe the server now and then, so the queue
  /// flushes without the user touching anything. Stops itself once everything is synced.
  void startAutoSync({Duration every = const Duration(seconds: 30)}) {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(every, (_) => onAppResumed());
  }

  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  /// Retries the offline queue now (the banner's "Sync now").
  Future<void> syncNow() => fetchAllData();

  /// Changes that could not be applied and wait for the user to keep or discard.
  List<PendingOp> get failedOps => List.unmodifiable(_failedOps);

  Future<void> loadFailedOps() async {
    _failedOps = await _store?.loadFailed() ?? [];
    _notify();
  }

  /// Drops a failed change ("keep the server's version").
  Future<void> discardFailedOp(String opId) async {
    final store = _store;
    if (store == null) return;
    final list = await store.loadFailed()
      ..removeWhere((o) => o.id == opId);
    await store.saveFailed(list);
    _failedOps = list;
    _notify();
  }

  /// Re-queues a failed change as is, skipping the version check ("keep mine").
  Future<void> retryFailedOp(String opId) async {
    final store = _store;
    if (store == null) return;
    final list = await store.loadFailed();
    final op = list.where((o) => o.id == opId).firstOrNull;
    if (op == null) return;
    list.removeWhere((o) => o.id == opId);
    await store.saveFailed(list);
    _failedOps = list;
    await _enqueue(PendingOp(op.type, {...op.args, 'force': true}));
    await _flushPending();
    _notify();
  }

  Map<String, dynamic> _map(Object? v) => Map<String, dynamic>.from(v as Map);

  /// [touched] holds the ids already changed by earlier ops of this flush: those edits
  /// come from this device, so they must not make a later edit look stale.
  Future<void> _applyPending(PendingOp op, Set<String> touched) async {
    final a = op.args;
    bool check(String id) => a['force'] != true && !touched.contains(id);
    switch (op.type) {
      case 'createBox':
        await _apiService.createBox(Box.fromJson(_map(a['box'])));
      case 'updateBox':
        final box = Box.fromJson(_map(a['box']));
        await _apiService.updateBox(box, checkVersion: check(box.id));
        touched.add(box.id);
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
        final item = Item.fromJson(_map(a['item']));
        await _apiService.updateItem(item, checkVersion: check(item.id));
        touched.add(item.id);
      case 'moveItem':
        await _apiService.moveItem(a['id'] as String, a['boxId'] as String);
        touched.add(a['id'] as String);
      case 'deleteItem':
        await _apiService.deleteItem(a['id'] as String);
      case 'quantity':
        // Queued by older builds: absolute value.
        await _apiService.updateItemQuantity(
          a['id'] as String,
          (a['quantity'] as num).toDouble(),
          reason: a['reason'] as String?,
        );
        touched.add(a['id'] as String);
      case 'adjustQuantity':
        await _apiService.adjustItemQuantity(
          a['id'] as String,
          (a['delta'] as num).toDouble(),
          reason: a['reason'] as String?,
          idempotencyKey: a['key'] as String?,
        );
        touched.add(a['id'] as String);
      case 'lend':
        final r = LendingRecord.fromJson(_map(a['record']));
        touched.add(r.itemId);
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
        final loan = _lendingRecords.where((l) => l.id == a['id']).firstOrNull;
        if (loan != null) touched.add(loan.itemId);
      case 'updateSettings':
        await _apiService.updateSettings(_map(a['delta']));
      case 'createCategory':
        await _apiService.createCategory(a['name'] as String);
      case 'deleteCategory':
        await _apiService.deleteCategory(a['name'] as String);
    }
  }
}

/// Plain-language name of a queued change for the UI, e.g. "Edit item: Drill".
String describePendingOp(PendingOp op) {
  final l = AppL10n.current;
  final a = op.args;
  final target = a['item'] ?? a['box'];
  final name = target is Map ? target['name'] : null;
  final label = switch (op.type) {
    'createItem' => l.opCreateItem,
    'updateItem' => l.opUpdateItem,
    'deleteItem' => l.opDeleteItem,
    'moveItem' => l.opMoveItem,
    'quantity' || 'adjustQuantity' => l.opChangeQuantity,
    'createBox' => l.opCreateBox,
    'updateBox' => l.opUpdateBox,
    'moveBox' => l.opMoveBox,
    'deleteBox' => l.opDeleteBox,
    'updateSettings' => l.opUpdateSettings,
    'lend' => l.opLend,
    'returnLoan' => l.opReturnLoan,
    'createCategory' => l.opCreateCategory,
    'deleteCategory' => l.opDeleteCategory,
    _ => op.type,
  };
  return name != null ? '$label: $name' : label;
}
