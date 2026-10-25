import 'package:flutter/material.dart';

import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

void showCurrencyPicker(BuildContext context, InventoryProvider provider) {
  final currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': context.l10n.usDollar},
    {'code': 'VND', 'symbol': '₫', 'name': context.l10n.vietnameseDong},
    {'code': 'EUR', 'symbol': '€', 'name': context.l10n.commonEuro},
    {'code': 'GBP', 'symbol': '£', 'name': context.l10n.britishPound},
    {'code': 'JPY', 'symbol': '¥', 'name': context.l10n.japaneseYen},
  ];

  showSelectionSheet(
    context: context,
    title: context.l10n.selectCurrency,
    subtitle: context.l10n.appliedToPriceCalculationsAsset,
    items: currencies.map((c) => c['symbol']!).toList(),
    currentValue: provider.currency,
    displayBuilder: (sym) {
      final item = currencies.firstWhere((c) => c['symbol'] == sym);
      return '${item['symbol']} (${item['code']} - ${item['name']})';
    },
    onSelected: (sym) {
      provider.setCurrency(sym);
      AppFeedback.showSuccess(context, context.l10n.currencyChangedTo(sym));
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
    title: context.l10n.defaultItemUnit,
    subtitle: context.l10n.defaultMeasuringUnitWhenCreating,
    items: units.map((u) => u['code']!).toList(),
    currentValue: provider.defaultUnit,
    displayBuilder: (code) {
      final item = units.firstWhere((u) => u['code'] == code);
      return '${item['code']} (${item['name']})';
    },
    onSelected: (unit) {
      provider.setDefaultUnit(unit);
      AppFeedback.showSuccess(context, context.l10n.defaultUnitSetTo(unit));
    },
  );
}

void showExpiryDaysPicker(BuildContext context, InventoryProvider provider) {
  final daysOptions = [7, 14, 30, 60, 90];

  showSelectionSheet<int>(
    context: context,
    title: context.l10n.expiryWarningWindow,
    subtitle: context.l10n.howManyDaysBeforeExpiration,
    items: daysOptions,
    currentValue: provider.expiryWarningDays,
    displayBuilder: (days) => '$days days before expiration / warranty ends',
    onSelected: (days) {
      provider.setExpiryWarningDays(days);
      AppFeedback.showSuccess(context, context.l10n.alertWindowSetToDays(days));
    },
  );
}


void showWarrantyDaysPicker(BuildContext context, InventoryProvider provider) {
  showSelectionSheet<int>(
    context: context,
    title: context.l10n.warrantyWarningWindow,
    subtitle: context.l10n.howManyDaysBeforeWarranty,
    items: const [7, 14, 30, 60, 90],
    currentValue: provider.warrantyWarningDays,
    displayBuilder: (days) => '$days days before warranty ends',
    onSelected: (days) {
      provider.setWarrantyWarningDays(days);
      AppFeedback.showSuccess(context, context.l10n.warrantyWindowSetToDays(days));
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
    title: context.l10n.timeZone,
    subtitle: context.l10n.alertsTreatTodayInThis,
    items: zones,
    currentValue: zones.contains(provider.timezone) ? provider.timezone : zones.first,
    displayBuilder: (tz) => tz,
    onSelected: (tz) {
      provider.setTimezone(tz);
      AppFeedback.showSuccess(context, context.l10n.timeZoneSetTo(tz));
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
        decoration: BoxDecoration(
          color: context.colors.surface,
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
                      color: context.colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
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
                            color: isSelected ? context.colors.fill : context.colors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isSelected ? context.colors.primary : context.colors.border,
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                              title: Text(
                                displayBuilder(item),
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: context.colors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(Icons.check_circle_rounded, color: context.colors.textPrimary, size: 20)
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
