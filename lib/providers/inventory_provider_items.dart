part of 'inventory_provider.dart';

/// Item catalog and category management.
extension InventoryItems on InventoryProvider {
  // ==========================================
  // MODULE 2: ITEM CATALOG & ASSET TRACKING
  // ==========================================

  Future<bool> addCategory(String category) async {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return false;
    final exists = _categories.any((c) => c.toLowerCase() == trimmed.toLowerCase());
    if (!exists) {
      _categories.add(trimmed);
      _notify();
      try {
        await _apiService.createCategory(trimmed);
      } catch (e) {
        debugPrint('createCategory error: $e');
      }
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
      try {
        await _apiService.deleteCategory(trimmed);
      } catch (e) {
        debugPrint('deleteCategory error: $e');
      }
      return true;
    }
    return false;
  }

  int getItemCountForCategory(String category) {
    return _items.where((i) => i.categoryId.toLowerCase() == category.toLowerCase()).length;
  }

  double get totalInventoryValue {
    return _items.fold(0.0, (sum, item) => sum + ((item.purchasePrice ?? 0.0) * item.quantity));
  }

  Future<bool> addItem(Item item) async {
    if (item.categoryId.isNotEmpty &&
        !_categories.any((c) => c.toLowerCase() == item.categoryId.toLowerCase())) {
      _categories.add(item.categoryId);
    }

    try {
      final created = await _apiService.createItem(item);
      _items.add(created);
      _notify();
      return true;
    } catch (e) {
      debugPrint('createItem error: $e');
      _items.add(item);
      _notify();
      return false;
    }
  }

  Future<bool> updateItem(Item updatedItem) async {
    final index = _items.indexWhere((i) => i.id == updatedItem.id);
    if (index != -1) {
      if (updatedItem.categoryId.isNotEmpty &&
          !_categories.any((c) => c.toLowerCase() == updatedItem.categoryId.toLowerCase())) {
        _categories.add(updatedItem.categoryId);
      }
      _items[index] = updatedItem;
      _notify();
    }

    try {
      final res = await _apiService.updateItem(updatedItem);
      if (index != -1) {
        _items[index] = res;
        _notify();
      }
      return true;
    } catch (e) {
      debugPrint('updateItem error: $e');
      return false;
    }
  }

  Future<bool> deleteItem(String itemId) async {
    final itemsSnapshot = List<Item>.from(_items);
    final loansSnapshot = List<LendingRecord>.from(_lendingRecords);
    _items.removeWhere((i) => i.id == itemId);
    _lendingRecords.removeWhere((l) => l.itemId == itemId);
    _notify();

    try {
      await _apiService.deleteItem(itemId);
      return true;
    } catch (e) {
      debugPrint('deleteItem error: $e');
      _items
        ..clear()
        ..addAll(itemsSnapshot);
      _lendingRecords
        ..clear()
        ..addAll(loansSnapshot);
      _notify();
      return false;
    }
  }

  Future<bool> moveItem(String itemId, String newLocationId) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(boxId: newLocationId);
      _notify();
    }

    try {
      await _apiService.moveItem(itemId, newLocationId);
      return true;
    } catch (e) {
      debugPrint('moveItem error: $e');
      return false;
    }
  }

  Future<StockHistory?> getItemMovements(String itemId) async {
    try {
      return await _apiService.getItemMovements(itemId);
    } catch (e) {
      debugPrint('getItemMovements error: $e');
      return null;
    }
  }

  Future<bool> updateItemQuantity(String itemId, double quantity,
      {String? reason}) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _notify();
    }

    try {
      await _apiService.updateItemQuantity(itemId, quantity, reason: reason);
      return true;
    } catch (e) {
      debugPrint('updateItemQuantity error: $e');
      return false;
    }
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
            (i.serialNumber != null && i.serialNumber!.toLowerCase().trim() == trimmed) ||
            i.id.toLowerCase() == trimmed,
      );
    } catch (_) {
      return null;
    }
  }
}
