import 'package:intl/intl.dart';

/// Utility methods for formatting currency and unit quantities across the app.
class AppFormatters {
  /// Formats currency with thousands separator and proper decimal behavior.
  /// For VNĐ (₫ or VND): uses thousand separator '.' without decimals (e.g. `2.650 ₫`, `42.000 ₫`).
  /// For USD ($), EUR (€), etc.: uses standard international formatting.
  static String formatCurrency(num? amount, String currencySymbol) {
    if (amount == null) return '';
    final isVnd =
        currencySymbol == '₫' || currencySymbol.toUpperCase() == 'VND';

    if (isVnd) {
      final intVal = amount.round();
      final formatted = NumberFormat('#,###', 'vi_VN').format(intVal);
      return '$formatted ₫';
    } else {
      final formatted = NumberFormat('#,##0.00', 'en_US').format(amount);
      return '$currencySymbol$formatted';
    }
  }

  /// Formats quantity with proper English pluralization for units.
  /// Example:
  /// - 1 pcs -> '1 pc'
  /// - 5 pcs -> '5 pcs'
  /// - 1 box -> '1 box'
  /// - 2 box -> '2 boxes' (or keeps unit as-is if customized)
  static String formatQuantity(num quantity, String unit) {
    final countStr = quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toString();
    final cleanUnit = unit.trim().toLowerCase();

    if (cleanUnit == 'pcs' || cleanUnit == 'pc') {
      return quantity == 1 ? '1 pc' : '$countStr pcs';
    }
    return '$countStr ${unit.trim()}';
  }
}
