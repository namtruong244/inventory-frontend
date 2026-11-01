import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import '../widgets/alerts_parts.dart';
import '../widgets/app_refresh.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/soft_ui.dart';
import 'item_details_screen.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  /// Summary filter: expired | lowSoon | overdue | warranty; null shows all.
  String? _filter;

  void _toggle(String key) =>
      setState(() => _filter = _filter == key ? null : key);

  static String _num(double v) => v % 1 == 0 ? '${v.toInt()}' : '$v';

  bool _shows(String key) => _filter == null || _filter == key;

  void _openItem(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItemDetailsScreen(itemId: item.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final c = context.colors;
    final l10n = context.l10n;

    final expired = provider.getExpiredItems();
    final expiring = provider.getExpiringItems(
      withinDays: provider.expiryWarningDays,
    );
    final warranties = provider.getExpiringWarranties(
      withinDays: provider.warrantyWarningDays,
    );
    final overdue = provider.getOverdueLoans();
    final lowStock = provider.notifyLowStock
        ? provider.getLowStockItems()
        : <Item>[];
    final total =
        expired.length +
        expiring.length +
        warranties.length +
        overdue.length +
        lowStock.length;

    final danger = AlertTone.danger(c);
    final warning = AlertTone.warning(c);
    final info = AlertTone.info(c);

    Widget summary() => Row(
      children: [
        for (final (i, t) in [
          ('expired', expired.length, l10n.alertsSummaryExpired, danger),
          (
            'lowSoon',
            lowStock.length + expiring.length,
            l10n.alertsSummaryLowSoon,
            warning,
          ),
          ('overdue', overdue.length, l10n.alertsSummaryOverdue, danger),
          ('warranty', warranties.length, l10n.alertsSummaryWarranty, info),
        ].indexed) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: AlertSummaryTile(
              filterKey: t.$1,
              count: t.$2,
              label: t.$3,
              tone: t.$4,
              selected: _filter == t.$1,
              onTap: () => _toggle(t.$1),
            ),
          ),
        ],
      ],
    );

    final sections = <Widget>[
      if (_shows('expired') && expired.isNotEmpty)
        AlertSectionCard(
          icon: Icons.dangerous_outlined,
          title: l10n.expiredItems,
          count: expired.length,
          tone: danger,
          rows: [
            for (final item in expired)
              AlertRow(
                id: 'alert_row_${item.name}',
                icon: Icons.dangerous_outlined,
                name: item.name,
                sub: l10n.expiredAgoOn(
                  -item.daysUntilExpiry!,
                  formatDate(context, item.expiryDate!),
                ),
                subColor: danger.strong,
                onTap: () => _openItem(item),
              ),
          ],
        ),
      if (_shows('lowSoon') && expiring.isNotEmpty)
        AlertSectionCard(
          icon: Icons.hourglass_top_rounded,
          title: l10n.expiringSoonPerishables,
          count: expiring.length,
          tone: warning,
          rows: [
            for (final item in expiring)
              AlertRow(
                id: 'alert_row_${item.name}',
                icon: Icons.hourglass_top_rounded,
                name: item.name,
                sub: l10n.expiresInOn(
                  item.daysUntilExpiry!,
                  formatDate(context, item.expiryDate!),
                ),
                subColor: warning.strong,
                onTap: () => _openItem(item),
              ),
          ],
        ),
      if (_shows('lowSoon') && lowStock.isNotEmpty)
        AlertSectionCard(
          icon: Icons.production_quantity_limits_rounded,
          title: l10n.lowStockWarnings,
          count: lowStock.length,
          tone: warning,
          rows: [
            for (final item in lowStock)
              AlertRow(
                id: 'alert_row_${item.name}',
                icon: Icons.production_quantity_limits_rounded,
                name: item.name,
                sub: l10n.alertLowStockSub(
                  _num(item.quantity),
                  item.unit,
                  _num(item.minQuantity!),
                ),
                subColor: warning.strong,
                progress: item.stockRatio ?? 0,
                onTap: () => _openItem(item),
              ),
          ],
        ),
      if (_shows('overdue') && overdue.isNotEmpty)
        AlertSectionCard(
          icon: Icons.assignment_late_outlined,
          title: l10n.overdueBorrowedItems,
          count: overdue.length,
          tone: danger,
          rows: [
            for (final loan in overdue)
              () {
                final item = provider.getItemById(loan.itemId);
                final name = item?.name ?? l10n.borrowedItem;
                return AlertRow(
                  id: 'alert_row_$name',
                  icon: Icons.assignment_late_outlined,
                  name: name,
                  sub: l10n.alertOverdueSub(
                    loan.borrowerName,
                    -daysBetweenToday(loan.expectedReturnDate!),
                  ),
                  subColor: danger.strong,
                  onTap: () {
                    if (item != null) _openItem(item);
                  },
                );
              }(),
          ],
        ),
      if (_shows('warranty') && warranties.isNotEmpty)
        AlertSectionCard(
          icon: Icons.security_outlined,
          title: l10n.warrantiesEndingSoon,
          count: warranties.length,
          tone: info,
          rows: [
            for (final item in warranties)
              AlertRow(
                id: 'alert_row_${item.name}',
                icon: Icons.security_outlined,
                name: item.name,
                sub: l10n.alertWarrantySub(
                  item.daysUntilWarrantyExpiry!,
                  formatDate(context, item.warrantyExpiryDate!),
                ),
                subColor: info.strong,
                onTap: () => _openItem(item),
              ),
          ],
        ),
    ];

    return Scaffold(
      backgroundColor: c.background,
      appBar: SoftTopAppBar(title: l10n.lifecycleAlerts, backId: 'alerts_back'),
      body: AppRefresh(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 48),
          children: [
            if (total == 0)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: EmptyStateCard(
                  icon: Icons.verified_rounded,
                  title: l10n.allGood,
                  subtitle: l10n.noItemsAreExpiredExpiring,
                ),
              )
            else ...[
              summary(),
              for (final s in sections) ...[const SizedBox(height: 16), s],
            ],
          ],
        ),
      ),
    );
  }
}
