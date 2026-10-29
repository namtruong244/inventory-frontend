import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'item_details_screen.dart';
import '../widgets/app_refresh.dart';
import '../widgets/soft_ui.dart';
import '../widgets/tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../utils/date_format.dart';
import '../widgets/app_icon.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final c = context.colors;

    final expiredItems = provider.getExpiredItems();
    final expiringSoon = provider.getExpiringItems(
      withinDays: provider.expiryWarningDays,
    );
    final expiringWarranties = provider.getExpiringWarranties(
      withinDays: provider.warrantyWarningDays,
    );
    final overdueLoans = provider.getOverdueLoans();
    final lowStockItems = provider.notifyLowStock
        ? provider.getLowStockItems()
        : <Item>[];

    final totalAlerts =
        expiredItems.length +
        expiringSoon.length +
        expiringWarranties.length +
        overdueLoans.length +
        lowStockItems.length;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: c.surface,
                shape: BoxShape.circle,
                boxShadow: c.cardShadow,
              ),
              child: AppIcon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: c.textPrimary,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(context.l10n.lifecycleAlerts),
        centerTitle: true,
      ),
      body: totalAlerts == 0
          ? _buildAllClear(context)
          : AppRefresh(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                children: [
                  _buildSummary(context, [
                    _Group(
                      context.l10n.expiredItems,
                      expiredItems.length,
                      AppTones.coral,
                    ),
                    _Group(
                      context.l10n.expiringSoonPerishables,
                      expiringSoon.length,
                      AppTones.amber,
                    ),
                    _Group(
                      context.l10n.warrantiesEndingSoon,
                      expiringWarranties.length,
                      AppTones.sky,
                    ),
                    _Group(
                      context.l10n.overdueBorrowedItems,
                      overdueLoans.length,
                      AppTones.lilac,
                    ),
                    _Group(
                      context.l10n.lowStockWarnings,
                      lowStockItems.length,
                      AppTones.amber,
                    ),
                  ], totalAlerts),
                  const SizedBox(height: 24),
                  if (expiredItems.isNotEmpty)
                    _section(
                      context,
                      context.l10n.expiredItems,
                      expiredItems.length,
                      AppTones.coral,
                      [
                        for (final item in expiredItems)
                          _tile(
                            context,
                            icon: Icons.dangerous_outlined,
                            tone: AppTones.coral,
                            title: item.name,
                            subtitle: provider.getBreadcrumbString(item.boxId),
                            chip: context.l10n.expiredAgoOn(
                              DateTime.now()
                                  .difference(item.expiryDate!)
                                  .inDays,
                              formatDate(context, item.expiryDate!),
                            ),
                            onTap: () => _openItem(context, item),
                          ),
                      ],
                    ),
                  if (expiringSoon.isNotEmpty)
                    _section(
                      context,
                      context.l10n.expiringSoonPerishables,
                      expiringSoon.length,
                      AppTones.amber,
                      [
                        for (final item in expiringSoon)
                          _expiringTile(context, item, provider),
                      ],
                    ),
                  if (expiringWarranties.isNotEmpty)
                    _section(
                      context,
                      context.l10n.warrantiesEndingSoon,
                      expiringWarranties.length,
                      AppTones.sky,
                      [
                        for (final item in expiringWarranties)
                          _tile(
                            context,
                            icon: Icons.security_outlined,
                            tone: AppTones.sky,
                            title: item.name,
                            subtitle: provider.getBreadcrumbString(item.boxId),
                            chip: context.l10n.warrantyEndsInDays(
                              item.warrantyExpiryDate!
                                  .difference(DateTime.now())
                                  .inDays,
                            ),
                            onTap: () => _openItem(context, item),
                          ),
                      ],
                    ),
                  if (overdueLoans.isNotEmpty)
                    _section(
                      context,
                      context.l10n.overdueBorrowedItems,
                      overdueLoans.length,
                      AppTones.lilac,
                      [
                        for (final loan in overdueLoans)
                          _tile(
                            context,
                            icon: Icons.assignment_late_outlined,
                            tone: AppTones.lilac,
                            title:
                                provider.getItemById(loan.itemId)?.name ??
                                context.l10n.borrowedItem,
                            subtitle: context.l10n.commonBorrower(
                              loan.borrowerName,
                              loan.borrowerContact,
                            ),
                            chip: context.l10n.daysOverdueCount(
                              DateTime.now()
                                  .difference(loan.expectedReturnDate!)
                                  .inDays,
                            ),
                            onTap: () {
                              final item = provider.getItemById(loan.itemId);
                              if (item != null) _openItem(context, item);
                            },
                          ),
                      ],
                    ),
                  if (lowStockItems.isNotEmpty)
                    _section(
                      context,
                      context.l10n.lowStockWarnings,
                      lowStockItems.length,
                      AppTones.amber,
                      [
                        for (final item in lowStockItems)
                          _lowStockTile(context, item, provider),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  void _openItem(BuildContext context, Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItemDetailsScreen(itemId: item.id)),
    );
  }

  Widget _buildAllClear(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SoftRing(
              value: 1,
              color: c.accent,
              size: 120,
              stroke: 10,
              center: AppIcon(
                Icons.verified_rounded,
                size: 48,
                color: AppTones.matcha,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.allGood,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noItemsAreExpiredExpiring,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Big total with a ring split into one arc per alert group, plus group chips.
  Widget _buildSummary(BuildContext context, List<_Group> groups, int total) {
    final c = context.colors;
    final active = groups.where((g) => g.count > 0).toList();
    return SoftCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: CustomPaint(
              painter: _SegmentRing([
                for (final g in active) (g.count / total, g.color),
              ], c.fill),
              child: Center(
                child: Text(
                  '$total',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final g in active)
                  SoftChip.tone('${g.count} · ${g.label}', g.color, dot: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    int count,
    Color color,
    List<Widget> tiles,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                SoftChip.tone('$count', color),
              ],
            ),
          ),
          ...tiles,
        ],
      ),
    );
  }

  Widget _expiringTile(
    BuildContext context,
    Item item,
    InventoryProvider provider,
  ) {
    final daysLeft = item.expiryDate!.difference(DateTime.now()).inDays;
    return _tile(
      context,
      icon: Icons.hourglass_top_rounded,
      tone: daysLeft <= 3 ? AppTones.coral : AppTones.amber,
      title: item.name,
      subtitle: provider.getBreadcrumbString(item.boxId),
      chip: context.l10n.expiresInOn(
        daysLeft,
        formatDate(context, item.expiryDate!),
      ),
      // Fuller bar = closer to the deadline within the warning window.
      progress:
          1 -
          (daysLeft /
                  (provider.expiryWarningDays <= 0
                      ? 30
                      : provider.expiryWarningDays))
              .clamp(0.0, 1.0),
      onTap: () => _openItem(context, item),
    );
  }

  Widget _lowStockTile(
    BuildContext context,
    Item item,
    InventoryProvider provider,
  ) {
    final qty = item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity;
    final minQty = item.minQuantity! % 1 == 0
        ? item.minQuantity!.toInt()
        : item.minQuantity;
    final min = item.minQuantity!;
    return _tile(
      context,
      icon: Icons.production_quantity_limits_rounded,
      tone: AppTones.amber,
      title: item.name,
      subtitle: provider.getBoxById(item.boxId) != null
          ? provider.getBreadcrumbString(item.boxId)
          : context.l10n.commonStorage,
      chip: context.l10n.onlyRemainingThreshold(
        qty,
        item.unit,
        minQty ?? 0,
        item.unit,
      ),
      progress: min > 0
          ? ((item.quantity + item.lentQuantity) / min).clamp(0.0, 1.0)
          : 0,
      onTap: () => _openItem(context, item),
    );
  }

  /// One alert row: tinted icon tile, name + location, colored detail chip,
  /// optional progress bar and a trailing chevron. The whole card is tappable.
  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color tone,
    required String title,
    required String subtitle,
    required String chip,
    required VoidCallback onTap,
    double? progress,
  }) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        child: Tappable(
          semanticLabel: title,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    SoftIconTile(icon, color: tone),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: c.textPrimary,
                            ),
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          SoftChip.tone(chip, tone),
                        ],
                      ),
                    ),
                    AppIcon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: c.textMuted,
                    ),
                  ],
                ),
                if (progress != null) ...[
                  const SizedBox(height: 12),
                  SoftBar(value: progress, color: tone, height: 5),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Group {
  final String label;
  final int count;
  final Color color;
  const _Group(this.label, this.count, this.color);
}

class _SegmentRing extends CustomPainter {
  final List<(double, Color)> segments;
  final Color track;
  _SegmentRing(this.segments, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, 6.2832, false, paint..color = track);
    const gap = 0.14;
    var start = -1.5708;
    for (final (share, color) in segments) {
      final sweep = share * 6.2832;
      final drawn = segments.length > 1
          ? (sweep - gap).clamp(0.05, 7.0)
          : sweep;
      canvas.drawArc(
        rect,
        start + (segments.length > 1 ? gap / 2 : 0),
        drawn,
        false,
        paint..color = color,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_SegmentRing old) =>
      old.segments != segments || old.track != track;
}
