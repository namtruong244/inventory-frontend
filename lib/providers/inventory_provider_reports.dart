part of 'inventory_provider.dart';

/// Plain-text inventory report built from the local state.
extension InventoryReports on InventoryProvider {
  String generateInventoryReport() {
    final buffer = StringBuffer();
    final now = DateTime.now();
    buffer.writeln('========================================');
    buffer.writeln('       INVENTORY STATUS REPORT');
    buffer.writeln(
        'Generated: ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
    buffer.writeln('Manager: $_userName ($_userRole)');
    buffer.writeln('Server Backend: ${_apiService.baseUrl}');
    buffer.writeln('========================================\n');

    buffer.writeln('1. OVERVIEW STATISTICS:');
    buffer.writeln('- Total Storage Containers: ${_boxes.length}');
    buffer.writeln('- Total Inventory Items: ${_items.length}');
    buffer.writeln(
        '- Total Estimated Value: ${formatPrice(totalInventoryValue)}');
    buffer.writeln('- Active Lent Items: ${getActiveLoans().length}');
    buffer.writeln('- Overdue Lent Items: ${getOverdueLoans().length}');
    buffer.writeln('- Expired Items: ${getExpiredItems().length}');
    buffer.writeln(
        '- Expiring Soon (within $_expiryWarningDays days): ${getExpiringItems(withinDays: _expiryWarningDays).length}\n');

    buffer.writeln('2. CATEGORIES BREAKDOWN:');
    for (final cat in _categories) {
      final count = getItemCountForCategory(cat);
      buffer.writeln('- $cat: $count items');
    }
    buffer.writeln('');

    buffer.writeln('3. CURRENT INVENTORY ITEMS:');
    for (final item in _items) {
      final box = getBoxById(item.boxId);
      final priceStr = item.purchasePrice != null
          ? ' | Price: ${formatPrice(item.purchasePrice)}'
          : '';
      buffer.writeln(
          '- ${item.name} (${formatQty(item.quantity, item.unit)}$priceStr) -> [${box?.name ?? "No Location"}]');
    }

    buffer.writeln('\n========================================');
    buffer.writeln('End of report');
    return buffer.toString();
  }
}
