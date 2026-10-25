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
  }) async {
    final localRecord = LendingRecord(
      itemId: itemId,
      borrowerName: borrowerName,
      borrowerContact: borrowerContact,
      lentDate: lentDate,
      expectedReturnDate: expectedReturnDate,
      notes: notes,
    );
    _lendingRecords.add(localRecord);

    final itemIndex = _items.indexWhere((i) => i.id == itemId);
    if (itemIndex != -1) {
      _items[itemIndex] = _items[itemIndex].copyWith(status: ItemStatus.lent);
    }
    _notify();

    try {
      final remoteRecord = await _apiService.lendItem(
        itemId: itemId,
        borrowerName: borrowerName,
        borrowerContact: borrowerContact,
        lentDate: lentDate,
        expectedReturnDate: expectedReturnDate,
        notes: notes,
      );
      // Replace with remote record
      final idx = _lendingRecords.indexOf(localRecord);
      if (idx != -1) {
        _lendingRecords[idx] = remoteRecord;
      }
      return true;
    } catch (e) {
      debugPrint('lendItem error: $e');
      return false;
    }
  }

  Future<bool> returnItem(String recordId, {String? newLocationId}) async {
    final recordIndex = _lendingRecords.indexWhere((l) => l.id == recordId);
    String? itemId;
    if (recordIndex != -1) {
      final record = _lendingRecords[recordIndex];
      itemId = record.itemId;
      _lendingRecords[recordIndex] = record.copyWith(actualReturnDate: DateTime.now());

      final itemIndex = _items.indexWhere((i) => i.id == record.itemId);
      if (itemIndex != -1) {
        _items[itemIndex] = _items[itemIndex].copyWith(
          status: ItemStatus.stored,
          boxId: newLocationId ?? _items[itemIndex].boxId,
        );
      }
      _notify();
    }

    try {
      await _apiService.returnItem(recordId);
      if (newLocationId != null && itemId != null) {
        await _apiService.moveItem(itemId, newLocationId);
      }
      return true;
    } catch (e) {
      debugPrint('returnItem error: $e');
      return false;
    }
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

  Future<String?> uploadMedia(String filePath, {String folder = 'items'}) async {
    try {
      return await _apiService.uploadMedia(filePath, folder: folder);
    } catch (e) {
      debugPrint('uploadMedia error: $e');
      return null;
    }
  }
}
