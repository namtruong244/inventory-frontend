part of 'inventory_provider.dart';

/// Read-only expiry, warranty and low-stock queries over the local item list.
extension InventoryAlerts on InventoryProvider {
  // ==========================================
  // MODULE 5: LIFECYCLE & EXPIRATION ALERTS
  // ==========================================

  List<Item> getExpiredItems() {
    return _items.where((i) => i.isExpired).toList();
  }

  List<Item> getExpiringItems({int withinDays = 30}) {
    final now = DateTime.now();
    return _items.where((i) {
      if (i.expiryDate == null || i.isExpired) return false;
      final diff = i.expiryDate!.difference(now).inDays;
      return diff >= 0 && diff <= withinDays;
    }).toList();
  }

  List<Item> getExpiringWarranties({int withinDays = 30}) {
    final now = DateTime.now();
    return _items.where((i) {
      if (i.warrantyExpiryDate == null || i.isWarrantyExpired) return false;
      final diff = i.warrantyExpiryDate!.difference(now).inDays;
      return diff >= 0 && diff <= withinDays;
    }).toList();
  }

  List<Item> getLowStockItems() {
    return _items.where((i) => i.isLowStock).toList();
  }

  int get totalAlertCount {
    return getExpiredItems().length +
        getExpiringItems(withinDays: _expiryWarningDays).length +
        getOverdueLoans().length +
        (_notifyLowStock ? getLowStockItems().length : 0);
  }
}
