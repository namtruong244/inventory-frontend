import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';
import 'soft_sheet.dart';

/// Bottom sheet showing an item's stock movements as a timeline.
class StockHistorySheet extends StatelessWidget {
  final Item item;

  const StockHistorySheet({super.key, required this.item});

  static Future<void> show(BuildContext context, Item item) {
    final provider = context.read<InventoryProvider>();
    return showSoftSheet<void>(
      context,
      title: context.l10n.stockHistory,
      subtitle: context.l10n.itemStockHistorySubtitle(
        item.name,
        provider.formatQty(item.quantity, item.unit),
      ),
      builder: (_) => ChangeNotifierProvider<InventoryProvider>.value(
        value: provider,
        child: StockHistorySheet(item: item),
      ),
    );
  }

  static String _reasonLabel(BuildContext context, String reason) {
    switch (reason) {
      case 'initial':
        return context.l10n.initialStock;
      case 'restock':
        return context.l10n.commonRestocked;
      case 'consume':
        return context.l10n.commonUsed;
      case 'damaged':
        return context.l10n.commonDamaged;
      case 'lost':
        return context.l10n.commonLost;
      case 'correction':
        return context.l10n.commonCorrection;
      case 'move':
        return context.l10n.commonMoved;
      default:
        return context.l10n.commonAdjusted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<InventoryProvider>();
    final c = context.colors;
    final height = MediaQuery.of(context).size.height * 0.55;
    return SizedBox(
      height: height,
      child: FutureBuilder<StockHistory?>(
        future: provider.getItemMovements(item.id),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snap.data;
          if (history == null) {
            return Center(child: Text(context.l10n.couldNotLoadStockHistory));
          }
          final days = history.estimatedDaysLeft;
          final moves = history.movements;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Text(
                days == null
                    ? context.l10n.noConsumptionDataYet
                    : context.l10n.avgDayAboutDaysLeft(
                        provider.formatQty(
                          history.avgDailyConsumption30d,
                          item.unit,
                        ),
                        days.round(),
                      ),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              if (moves.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text(context.l10n.noMovementsRecorded)),
                ),
              for (var i = 0; i < moves.length; i++)
                _TimelineRow(
                  movement: moves[i],
                  item: item,
                  label: _reasonLabel(context, moves[i].reason),
                  last: i == moves.length - 1,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final StockMovement movement;
  final Item item;
  final String label;
  final bool last;

  const _TimelineRow({
    required this.movement,
    required this.item,
    required this.label,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final provider = context.read<InventoryProvider>();
    final m = movement;
    final (bg, fg, icon) = switch (m.reason) {
      'restock' ||
      'initial' => (c.successSoft, c.successStrong, Icons.add_rounded),
      'consume' => (c.warningSoft, c.warningStrong, Icons.remove_rounded),
      'damaged' ||
      'lost' => (c.dangerSoft, c.dangerStrong, Icons.remove_rounded),
      'correction' => (c.infoSoft, c.infoStrong, Icons.edit_rounded),
      _ => (c.fill, c.textSecondary, Icons.swap_horiz_rounded),
    };
    final before = m.quantityAfter - m.delta;
    final when = DateFormat.MMMd().add_Hm().format(m.createdAt);
    final sub = m.delta == 0
        ? when
        : '$when · ${provider.formatQty(before, item.unit)} → '
              '${provider.formatQty(m.quantityAfter, item.unit)}';
    final deltaColor = m.reason == 'initial'
        ? c.textSecondary
        : m.delta > 0
        ? c.successStrong
        : c.textPrimary;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: AppIcon(icon, size: 16, color: fg),
                ),
                if (!last)
                  Expanded(child: Container(width: 2, color: c.border)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.note.isEmpty ? sub : '$sub · ${m.note}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (m.delta != 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${m.delta > 0 ? '+' : '−'}${provider.formatQty(m.delta.abs(), item.unit)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: deltaColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
