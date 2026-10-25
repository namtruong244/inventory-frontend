part of 'inventory_provider.dart';

/// Lending tracker and barcode/QR scan lookup.
extension InventoryLending on InventoryProvider {
  // ==========================================
  // MODULE 6: LENDING & BORROWING TRACKER
  // ==========================================

  List<LendingRecord> getActiveLoans() {
    return _lendingRecords.where((l) => l.isActive).toList();
  }

  List<LendingRecord> getOverdueLoans() {
    return _lendingRecords.where((l) => l.isOverdue).toList();
  }

  List<LendingRecord> getLendingHistoryForItem(String itemId) {
    return _lendingRecords.where((l) => l.itemId == itemId).toList();
  }

  LendingRecord? getActiveLoanForItem(String itemId) {
    try {
      return _lendingRecords.firstWhere(
        (l) => l.itemId == itemId && l.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> lendItem({
    required String itemId,
    required String borrowerName,
    String borrowerContact = '',
    required DateTime lentDate,
    DateTime? expectedReturnDate,
    String notes = '',
    double? quantity,
  }) async {
    final itemIndex = _items.indexWhere((i) => i.id == itemId);
    final originalItem = itemIndex != -1 ? _items[itemIndex] : null;
    final stock = itemIndex != -1 ? _items[itemIndex].quantity : 0.0;
    // Mirrors the backend: 0 < quantity < stock lends only part of the stock.
    final isPartial = quantity != null && quantity > 0 && quantity < stock;
    final localRecord = LendingRecord(
      itemId: itemId,
      borrowerName: borrowerName,
      borrowerContact: borrowerContact,
      lentDate: lentDate,
      expectedReturnDate: expectedReturnDate,
      notes: notes,
      quantity: isPartial ? quantity : stock,
      isPartial: isPartial,
    );
    _lendingRecords.add(localRecord);

    if (itemIndex != -1) {
      _items[itemIndex] = isPartial
          ? _items[itemIndex].copyWith(quantity: stock - quantity)
          : _items[itemIndex].copyWith(status: ItemStatus.lent);
    }
    _notify();

    final ok = await _commit(
      PendingOp('lend', {'record': localRecord.toJson()}),
      () => _apiService.lendItem(
        id: localRecord.id,
        itemId: itemId,
        borrowerName: borrowerName,
        borrowerContact: borrowerContact,
        lentDate: lentDate,
        expectedReturnDate: expectedReturnDate,
        notes: notes,
        quantity: isPartial ? quantity : null,
      ),
    );
    if (!ok) {
      // Rejected by the server: undo the optimistic change.
      _lendingRecords.removeWhere((l) => l.id == localRecord.id);
      if (itemIndex != -1) _items[itemIndex] = originalItem!;
      _notify();
    }
    return ok;
  }

  Future<bool> returnItem(String recordId, {String? newLocationId}) async {
    final recordIndex = _lendingRecords.indexWhere((l) => l.id == recordId);
    String? itemId;
    if (recordIndex != -1) {
      final record = _lendingRecords[recordIndex];
      itemId = record.itemId;
      _lendingRecords[recordIndex] = record.copyWith(
        actualReturnDate: DateTime.now(),
      );

      final itemIndex = _items.indexWhere((i) => i.id == record.itemId);
      if (itemIndex != -1) {
        final item = _items[itemIndex];
        _items[itemIndex] = record.isPartial
            ? item.copyWith(quantity: item.quantity + record.quantity)
            : item.copyWith(
                status: ItemStatus.stored,
                boxId: newLocationId ?? item.boxId,
              );
      }
      _notify();
    }

    final ok = await _commit(
      PendingOp('returnLoan', {'id': recordId}),
      () => _apiService.returnItem(recordId),
    );
    if (ok && newLocationId != null && itemId != null) {
      final target = newLocationId;
      await _commit(
        PendingOp('moveItem', {'id': itemId, 'boxId': target}),
        () => _apiService.moveItem(itemId!, target),
      );
    }
    return ok;
  }

  // ==========================================
  // MODULE 7: SCANNING & LOOKUP
  // ==========================================

  Future<ScanLookupResult?> lookupScanCode(String code) async {
    try {
      final res = await _apiService.lookupScan(code);
      if (res != null) {
        return ScanLookupResult.fromJson(res);
      }
    } catch (e) {
      debugPrint('lookupScanCode remote error: $e');
    }

    // Local fallback
    final box = getBoxByLabel(code);
    if (box != null) {
      return ScanLookupResult(type: 'box', payload: box.toJson());
    }
    final item = getItemByBarcode(code);
    if (item != null) {
      return ScanLookupResult(type: 'item', payload: item.toJson());
    }
    return null;
  }

  Future<String?> uploadMedia(
    String filePath, {
    String folder = 'items',
  }) async {
    try {
      return await _apiService.uploadMedia(filePath, folder: folder);
    } catch (e) {
      debugPrint('uploadMedia error: $e');
      return null;
    }
  }
}
