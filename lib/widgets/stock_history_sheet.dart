import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';

/// Bottom sheet listing an item's stock movements and consumption estimate.
class StockHistorySheet extends StatelessWidget {
  final Item item;

  const StockHistorySheet({super.key, required this.item});

  static Future<void> show(BuildContext context, Item item) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ChangeNotifierProvider<InventoryProvider>.value(
        value: context.read<InventoryProvider>(),
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
    final height = MediaQuery.of(context).size.height * 0.6;
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
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text(context.l10n.stockHistory, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                days == null
                    ? context.l10n.noConsumptionDataYet
                    : context.l10n.avgDayAboutDaysLeft(provider.formatQty(history.avgDailyConsumption30d, item.unit), days.round()),
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              if (history.movements.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text(context.l10n.noMovementsRecorded)),
                ),
              for (final m in history.movements)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_reasonLabel(context, m.reason)),
                  subtitle: Text(DateFormat.yMMMd().add_jm().format(m.createdAt) +
                      (m.note.isEmpty ? '' : ' · ${m.note}')),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (m.delta != 0)
                        Text(
                          '${m.delta > 0 ? '+' : ''}${provider.formatQty(m.delta, item.unit)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: m.delta > 0 ? AppTones.matcha : AppTones.coral,
                          ),
                        ),
                      Text('→ ${provider.formatQty(m.quantityAfter, item.unit)}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
