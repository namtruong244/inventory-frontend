part of 'inventory_provider.dart';

/// Trash: soft-deleted items and boxes that can be restored or purged.
extension InventoryTrash on InventoryProvider {
  Future<({List<Item> items, List<Box> boxes})?> fetchTrash() async {
    try {
      return await _apiService.getTrash();
    } catch (e) {
      debugPrint('getTrash error: $e');
      return null;
    }
  }

  /// Restores a trashed item or box, then resyncs so the live lists include it.
  Future<bool> restoreFromTrash({String? itemId, String? boxId}) async {
    try {
      if (itemId != null) await _apiService.restoreTrashItem(itemId);
      if (boxId != null) await _apiService.restoreTrashBox(boxId);
      await fetchAllData();
      return true;
    } catch (e) {
      debugPrint('restoreFromTrash error: $e');
      return false;
    }
  }

  Future<bool> purgeFromTrash({String? itemId, String? boxId}) async {
    try {
      if (itemId != null) await _apiService.purgeTrashItem(itemId);
      if (boxId != null) await _apiService.purgeTrashBox(boxId);
      return true;
    } catch (e) {
      debugPrint('purgeFromTrash error: $e');
      return false;
    }
  }

  Future<bool> emptyTrash() async {
    try {
      await _apiService.emptyTrash();
      return true;
    } catch (e) {
      debugPrint('emptyTrash error: $e');
      return false;
    }
  }
}
