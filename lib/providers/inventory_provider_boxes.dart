part of 'inventory_provider.dart';

/// Storage hierarchy (boxes) management.
extension InventoryBoxes on InventoryProvider {
  // ==========================================
  // MODULE 1: HIERARCHY & LOCATION MANAGEMENT
  // ==========================================

  Future<bool> addBox(Box box) async {
    _boxes.add(box);
    _notify();
    // A rejected create stays in the list until the next sync replaces it.
    return _commit(
      PendingOp('createBox', {'box': box.toJson()}),
      () => _apiService.createBox(box),
    );
  }

  Future<bool> updateBox(Box updatedBox) async {
    final index = _boxes.indexWhere((b) => b.id == updatedBox.id);
    if (index != -1) {
      _boxes[index] = updatedBox;
      _notify();
    }
    return _commit(
      PendingOp('updateBox', {'box': updatedBox.toJson()}),
      () async {
        final saved = await _apiService.updateBox(updatedBox);
        final i = _boxes.indexWhere((x) => x.id == saved.id);
        if (i != -1) _boxes[i] = saved;
        _notify();
      },
    );
  }

  /// Returns true on success. On API failure the local state is restored.
  /// Without [cascade] the server refuses to delete a box that still has contents.
  Future<bool> deleteBox(String boxId, {bool cascade = false}) async {
    final boxesSnapshot = List<Box>.from(_boxes);
    final itemsSnapshot = List<Item>.from(_items);
    final loansSnapshot = List<LendingRecord>.from(_lendingRecords);

    final doomed = <String>{boxId};
    var frontier = <String>[boxId];
    while (frontier.isNotEmpty) {
      final children = _boxes
          .where((b) => b.parentId != null && frontier.contains(b.parentId))
          .map((b) => b.id)
          .where(doomed.add)
          .toList();
      frontier = children;
    }
    final removedItemIds = _items
        .where((i) => doomed.contains(i.boxId))
        .map((i) => i.id)
        .toSet();
    _items.removeWhere((i) => removedItemIds.contains(i.id));
    _lendingRecords.removeWhere((l) => removedItemIds.contains(l.itemId));
    _boxes.removeWhere((b) => doomed.contains(b.id));
    _notify();

    final ok = await _commit(
      PendingOp('deleteBox', {'id': boxId, 'cascade': cascade}),
      () => _apiService.deleteBox(boxId, cascade: cascade),
    );
    if (!ok) {
      _boxes
        ..clear()
        ..addAll(boxesSnapshot);
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

  List<Box> getRootBoxes() {
    return _boxes.where((b) => b.parentId == null).toList();
  }

  List<Box> getBoxesIn(String parentId) {
    return _boxes.where((b) => b.parentId == parentId).toList();
  }

  Box? getBoxById(String id) {
    try {
      return _boxes.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Box? getBoxByLabel(String label) {
    final query = label.toLowerCase().trim();
    try {
      return _boxes.firstWhere(
        (b) => b.label.toLowerCase() == query || b.id.toLowerCase() == query,
      );
    } catch (_) {
      return null;
    }
  }

  List<Box> getBreadcrumb(String locationId) {
    final List<Box> path = [];
    String? currentId = locationId;

    while (currentId != null) {
      final currentBox = getBoxById(currentId);
      if (currentBox == null) break;
      path.insert(0, currentBox);
      currentId = currentBox.parentId;
    }

    return path;
  }

  String getBreadcrumbString(String locationId) {
    final path = getBreadcrumb(locationId);
    if (path.isEmpty) return AppL10n.current.commonUnassigned;
    return path.map((b) => b.name).join(' › ');
  }

  bool canMoveLocation(String locationId, String? targetParentId) {
    if (targetParentId == null) return true;
    if (locationId == targetParentId) return false;

    String? current = targetParentId;
    while (current != null) {
      if (current == locationId) return false;
      final parent = getBoxById(current);
      current = parent?.parentId;
    }
    return true;
  }

  bool bulkMoveLocation(String locationId, String? newParentId) {
    if (!canMoveLocation(locationId, newParentId)) {
      return false;
    }

    final index = _boxes.indexWhere((b) => b.id == locationId);
    if (index != -1) {
      _boxes[index] = _boxes[index].copyWith(
        parentId: newParentId,
        clearParent: newParentId == null,
      );
      _notify();
    }

    _commit(
      PendingOp('moveBox', {'id': locationId, 'parentId': newParentId}),
      () => _apiService.moveBox(locationId, newParentId),
    );
    return true;
  }

  int countTotalItemsIn(String locationId) {
    int total = _items.where((i) => i.boxId == locationId).length;
    final subBoxes = getBoxesIn(locationId);
    for (var sub in subBoxes) {
      total += countTotalItemsIn(sub.id);
    }
    return total;
  }
}
