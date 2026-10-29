part of 'inventory_provider.dart';

/// Plain-text inventory report built from the local state.
extension InventoryReports on InventoryProvider {
  String generateInventoryReport() {
    final buffer = StringBuffer();
    final now = DateTime.now();
    buffer.writeln('========================================');
    buffer.writeln('       ${AppL10n.current.reportTitle}');
    buffer.writeln(
      AppL10n.current.reportGenerated(
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      ),
    );
    buffer.writeln(AppL10n.current.commonManager(_userName, _userRole));
    buffer.writeln(AppL10n.current.serverBackend(_apiService.baseUrl));
    buffer.writeln('========================================\n');

    buffer.writeln(AppL10n.current.reportOverview);
    buffer.writeln(AppL10n.current.reportTotalContainers(_boxes.length));
    buffer.writeln(AppL10n.current.reportTotalItems(_items.length));
    buffer.writeln(
      AppL10n.current.reportTotalValue(formatPrice(totalInventoryValue)),
    );
    buffer.writeln(AppL10n.current.reportActiveLent(getActiveLoans().length));
    buffer.writeln(AppL10n.current.reportOverdueLent(getOverdueLoans().length));
    buffer.writeln(AppL10n.current.reportExpired(getExpiredItems().length));
    buffer.writeln(
      '${AppL10n.current.reportExpiringSoon(_expiryWarningDays, getExpiringItems(withinDays: _expiryWarningDays).length)}\n',
    );

    buffer.writeln(AppL10n.current.reportCategories);
    for (final cat in _categories) {
      final count = getItemCountForCategory(cat);
      buffer.writeln(AppL10n.current.reportCategoryLine(cat, count));
    }
    buffer.writeln('');

    buffer.writeln(AppL10n.current.reportCurrentItems);
    for (final item in _items) {
      final box = getBoxById(item.boxId);
      final priceStr = item.purchasePrice != null
          ? AppL10n.current.reportPrice(formatPrice(item.purchasePrice))
          : '';
      buffer.writeln(
        '- ${item.name} (${formatQty(item.quantity, item.unit)}$priceStr) -> [${box?.name ?? AppL10n.current.reportNoLocation}]',
      );
    }

    buffer.writeln('\n========================================');
    buffer.writeln(AppL10n.current.endOfReport);
    return buffer.toString();
  }
}
