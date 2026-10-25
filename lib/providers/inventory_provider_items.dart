part of 'inventory_provider.dart';

/// Item catalog and category management.
extension InventoryItems on InventoryProvider {
  // ==========================================
  // MODULE 2: ITEM CATALOG & ASSET TRACKING
  // ==========================================

  Future<bool> addCategory(String category) async {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return false;
    final exists = _categories.any(
      (c) => c.toLowerCase() == trimmed.toLowerCase(),
    );
    if (!exists) {
      _categories.add(trimmed);
      _notify();
      await _commit(
        PendingOp('createCategory', {'name': trimmed}),
        () => _apiService.createCategory(trimmed),
      );
      return true;
    }
    return false;
  }

  Future<bool> deleteCategory(String category) async {
    final trimmed = category.trim();
    if (_categories.contains(trimmed)) {
      _categories.remove(trimmed);
      for (int i = 0; i < _items.length; i++) {
        if (_items[i].categoryId.toLowerCase() == trimmed.toLowerCase()) {
          _items[i] = _items[i].copyWith(categoryId: 'General');
        }
      }
      _notify();
      await _commit(
        PendingOp('deleteCategory', {'name': trimmed}),
        () => _apiService.deleteCategory(trimmed),
      );
      return true;
    }
    return false;
  }

  int getItemCountForCategory(String category) {
    return _items
        .where((i) => i.categoryId.toLowerCase() == category.toLowerCase())
        .length;
  }

  double get totalInventoryValue {
    return _items.fold(
      0.0,
      (sum, item) => sum + ((item.purchasePrice ?? 0.0) * item.quantity),
    );
  }

  Future<bool> addItem(Item item) async {
    if (item.categoryId.isNotEmpty &&
        !_categories.any(
          (c) => c.toLowerCase() == item.categoryId.toLowerCase(),
        )) {
      _categories.add(item.categoryId);
    }

    _items.add(item);
    _notify();
    // A rejected create stays in the list until the next sync replaces it.
    return _commit(
      PendingOp('createItem', {'item': item.toJson()}),
      () => _apiService.createItem(item),
    );
  }

  Future<bool> updateItem(Item updatedItem) async {
    final index = _items.indexWhere((i) => i.id == updatedItem.id);
    if (index != -1) {
      if (updatedItem.categoryId.isNotEmpty &&
          !_categories.any(
            (c) => c.toLowerCase() == updatedItem.categoryId.toLowerCase(),
          )) {
        _categories.add(updatedItem.categoryId);
      }
      _items[index] = updatedItem;
      _notify();
    }

    return _commit(
      PendingOp('updateItem', {'item': updatedItem.toJson()}),
      () async {
        final saved = await _apiService.updateItem(updatedItem);
        final i = _items.indexWhere((x) => x.id == saved.id);
        if (i != -1) _items[i] = saved;
        _notify();
      },
    );
  }

  Future<bool> deleteItem(String itemId) async {
    final itemsSnapshot = List<Item>.from(_items);
    final loansSnapshot = List<LendingRecord>.from(_lendingRecords);
    _items.removeWhere((i) => i.id == itemId);
    _lendingRecords.removeWhere((l) => l.itemId == itemId);
    _notify();

    final ok = await _commit(
      PendingOp('deleteItem', {'id': itemId}),
      () => _apiService.deleteItem(itemId),
    );
    if (!ok) {
      _items
        ..clear()
        ..addAll(itemsSnapshot);
      _lendingRecords
        ..clear()
        ..addAll(loansSnapshot);
      _notify();
    }
    return ok;
  }

  Future<bool> moveItem(String itemId, String newLocationId) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(boxId: newLocationId);
      _notify();
    }

    return _commit(
      PendingOp('moveItem', {'id': itemId, 'boxId': newLocationId}),
      () => _apiService.moveItem(itemId, newLocationId),
    );
  }

  Future<StockHistory?> getItemMovements(String itemId) async {
    try {
      return await _apiService.getItemMovements(itemId);
    } catch (e) {
      debugPrint('getItemMovements error: $e');
      return null;
    }
  }

  Future<bool> updateItemQuantity(
    String itemId,
    double quantity, {
    String? reason,
  }) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index == -1) return false;
    // Queued as a delta so two devices consuming stock offline add up
    // instead of the last absolute value winning.
    final delta = quantity - _items[index].quantity;
    _items[index] = _items[index].copyWith(quantity: quantity);
    _notify();
    if (delta == 0) return true;

    return _commit(
      PendingOp('adjustQuantity', {
        'id': itemId,
        'delta': delta,
        'reason': reason,
      }),
      () => _apiService.adjustItemQuantity(itemId, delta, reason: reason),
    );
  }

  List<Item> getItemsIn(String boxId) {
    return _items.where((i) => i.boxId == boxId).toList();
  }

  Item? getItemById(String id) {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  Item? getItemByBarcode(String barcode) {
    final trimmed = barcode.trim().toLowerCase();
    try {
      return _items.firstWhere(
        (i) =>
            (i.barcode != null && i.barcode!.toLowerCase().trim() == trimmed) ||
            (i.serialNumber != null &&
                i.serialNumber!.toLowerCase().trim() == trimmed) ||
            i.id.toLowerCase() == trimmed,
      );
    } catch (_) {
      return null;
    }
  }
}
