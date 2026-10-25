import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';

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

  static String _reasonLabel(String reason) {
    switch (reason) {
      case 'initial':
        return 'Initial stock';
      case 'restock':
        return 'Restocked';
      case 'consume':
        return 'Used';
      case 'damaged':
        return 'Damaged';
      case 'lost':
        return 'Lost';
      case 'correction':
        return 'Correction';
      case 'move':
        return 'Moved';
      default:
        return 'Adjusted';
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
            return const Center(child: Text('Could not load stock history'));
          }
          final days = history.estimatedDaysLeft;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text('Stock history', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                days == null
                    ? 'No consumption data yet'
                    : 'Avg ${provider.formatQty(history.avgDailyConsumption30d, item.unit)}/day · about ${days.round()} days left',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              if (history.movements.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No movements recorded')),
                ),
              for (final m in history.movements)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_reasonLabel(m.reason)),
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
                            color: m.delta > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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
