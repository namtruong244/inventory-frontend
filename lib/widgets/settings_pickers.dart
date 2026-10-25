import 'package:flutter/material.dart';

import '../providers/inventory_provider.dart';
import 'app_feedback.dart';

void showCurrencyPicker(BuildContext context, InventoryProvider provider) {
  final currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'VND', 'symbol': '₫', 'name': 'Vietnamese Dong'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
  ];

  showSelectionSheet(
    context: context,
    title: 'Select Currency',
    subtitle: 'Applied to price calculations & asset valuation',
    items: currencies.map((c) => c['symbol']!).toList(),
    currentValue: provider.currency,
    displayBuilder: (sym) {
      final item = currencies.firstWhere((c) => c['symbol'] == sym);
      return '${item['symbol']} (${item['code']} - ${item['name']})';
    },
    onSelected: (sym) {
      provider.setCurrency(sym);
      AppFeedback.showSuccess(context, 'Currency changed to $sym');
    },
  );
}

void showDefaultUnitPicker(BuildContext context, InventoryProvider provider) {
  final units = [
    {'code': 'pcs', 'name': 'Pieces'},
    {'code': 'box', 'name': 'Boxes'},
    {'code': 'pack', 'name': 'Packs'},
    {'code': 'kg', 'name': 'Kilograms'},
    {'code': 'set', 'name': 'Sets'},
    {'code': 'pair', 'name': 'Pairs'},
    {'code': 'bottle', 'name': 'Bottles'},
    {'code': 'm', 'name': 'Meters'},
  ];

  showSelectionSheet(
    context: context,
    title: 'Default Item Unit',
    subtitle: 'Default measuring unit when creating new items',
    items: units.map((u) => u['code']!).toList(),
    currentValue: provider.defaultUnit,
    displayBuilder: (code) {
      final item = units.firstWhere((u) => u['code'] == code);
      return '${item['code']} (${item['name']})';
    },
    onSelected: (unit) {
      provider.setDefaultUnit(unit);
      AppFeedback.showSuccess(context, 'Default unit set to "$unit"');
    },
  );
}

void showExpiryDaysPicker(BuildContext context, InventoryProvider provider) {
  final daysOptions = [7, 14, 30, 60, 90];

  showSelectionSheet<int>(
    context: context,
    title: 'Expiry Warning Window',
    subtitle: 'How many days before expiration to alert you',
    items: daysOptions,
    currentValue: provider.expiryWarningDays,
    displayBuilder: (days) => '$days days before expiration / warranty ends',
    onSelected: (days) {
      provider.setExpiryWarningDays(days);
      AppFeedback.showSuccess(context, 'Alert window set to $days days');
    },
  );
}


void showWarrantyDaysPicker(BuildContext context, InventoryProvider provider) {
  showSelectionSheet<int>(
    context: context,
    title: 'Warranty Warning Window',
    subtitle: 'How many days before warranty ends to alert you',
    items: const [7, 14, 30, 60, 90],
    currentValue: provider.warrantyWarningDays,
    displayBuilder: (days) => '$days days before warranty ends',
    onSelected: (days) {
      provider.setWarrantyWarningDays(days);
      AppFeedback.showSuccess(context, 'Warranty window set to $days days');
    },
  );
}


void showTimezonePicker(BuildContext context, InventoryProvider provider) {
  const zones = [
    'UTC',
    'Asia/Ho_Chi_Minh',
    'Asia/Bangkok',
    'Asia/Singapore',
    'Asia/Tokyo',
    'Australia/Sydney',
    'Europe/London',
    'Europe/Berlin',
    'America/New_York',
    'America/Chicago',
    'America/Los_Angeles',
  ];
  showSelectionSheet<String>(
    context: context,
    title: 'Time Zone',
    subtitle: 'Alerts treat "today" in this time zone',
    items: zones,
    currentValue: zones.contains(provider.timezone) ? provider.timezone : zones.first,
    displayBuilder: (tz) => tz,
    onSelected: (tz) {
      provider.setTimezone(tz);
      AppFeedback.showSuccess(context, 'Time zone set to $tz');
    },
  );
}

void showSelectionSheet<T>({
  required BuildContext context,
  required String title,
  required String subtitle,
  required List<T> items,
  required T currentValue,
  required String Function(T) displayBuilder,
  required Function(T) onSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final bottomPadding = MediaQuery.of(sheetContext).padding.bottom;
      final maxHeight = MediaQuery.of(sheetContext).size.height * 0.75;

      return Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding > 0 ? 8 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: items.map((item) {
                        final isSelected = item == currentValue;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: isSelected ? const Color(0xFFF4F4F6) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF18181B) : Colors.grey.shade200,
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                              title: Text(
                                displayBuilder(item),
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: const Color(0xFF18181B),
                                  fontSize: 14,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF18181B), size: 20)
                                  : null,
                              onTap: () {
                                Navigator.pop(sheetContext);
                                onSelected(item);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
