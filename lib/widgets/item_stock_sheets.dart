import 'package:flutter/material.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';


void showConsumeSheet(BuildContext context, Item item, InventoryProvider provider) {
  double consumeAmount = 1.0;
  if (item.quantity < 1.0 && item.quantity > 0) {
    consumeAmount = item.quantity;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final currentQty = item.quantity;
          final remainingAfter = (currentQty - consumeAmount).clamp(0.0, double.infinity);
          final formattedCurrent = currentQty % 1 == 0 ? currentQty.toInt().toString() : currentQty.toString();
          final formattedConsume = consumeAmount % 1 == 0 ? consumeAmount.toInt().toString() : consumeAmount.toString();
          final formattedRemain = remainingAfter % 1 == 0 ? remainingAfter.toInt().toString() : remainingAfter.toStringAsFixed(1);

          return Container(
            padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consume: ${item.name}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Current stock: $formattedCurrent ${item.unit}',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stepper row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity to use:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Row(
                        children: [
                          IconButton.filledTonal(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF18181B),
                            ),
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: consumeAmount > 1
                                ? () => setSheetState(() => consumeAmount -= 1)
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '$formattedConsume ${item.unit}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                            ),
                          ),
                          IconButton.filledTonal(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF18181B),
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: consumeAmount < currentQty
                                ? () => setSheetState(() => consumeAmount += 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Quick chips
                Wrap(
                  spacing: 8,
                  children: [
                    if (currentQty >= 1)
                      ActionChip(
                        label: Text('Use 1 ${item.unit}'),
                        onPressed: () => setSheetState(() => consumeAmount = 1.0),
                        backgroundColor: consumeAmount == 1.0 ? const Color(0xFF18181B) : Colors.white,
                        labelStyle: TextStyle(
                          color: consumeAmount == 1.0 ? Colors.white : const Color(0xFF18181B),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    if (currentQty >= 2)
                      ActionChip(
                        label: Text('Use 2 ${item.unit}'),
                        onPressed: () => setSheetState(() => consumeAmount = 2.0),
                        backgroundColor: consumeAmount == 2.0 ? const Color(0xFF18181B) : Colors.white,
                        labelStyle: TextStyle(
                          color: consumeAmount == 2.0 ? Colors.white : const Color(0xFF18181B),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    if (currentQty >= 5)
                      ActionChip(
                        label: Text('Use 5 ${item.unit}'),
                        onPressed: () => setSheetState(() => consumeAmount = 5.0),
                        backgroundColor: consumeAmount == 5.0 ? const Color(0xFF18181B) : Colors.white,
                        labelStyle: TextStyle(
                          color: consumeAmount == 5.0 ? Colors.white : const Color(0xFF18181B),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ActionChip(
                      label: const Text('Use All'),
                      onPressed: () => setSheetState(() => consumeAmount = currentQty),
                      backgroundColor: consumeAmount == currentQty ? const Color(0xFFEF4444) : Colors.white,
                      labelStyle: TextStyle(
                        color: consumeAmount == currentQty ? Colors.white : const Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Remaining status preview
                Row(
                  children: [
                    Icon(
                      remainingAfter == 0
                          ? Icons.error_outline_rounded
                          : (item.minQuantity != null && remainingAfter <= item.minQuantity!
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline_rounded),
                      size: 16,
                      color: remainingAfter == 0
                          ? Colors.red
                          : (item.minQuantity != null && remainingAfter <= item.minQuantity!
                              ? const Color(0xFFD97706)
                              : const Color(0xFF10B981)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      remainingAfter == 0
                          ? 'Will be out of stock after use'
                          : 'Remaining after use: $formattedRemain ${item.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: remainingAfter == 0
                            ? Colors.red
                            : (item.minQuantity != null && remainingAfter <= item.minQuantity!
                                ? const Color(0xFFD97706)
                                : Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Actions
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        side: const BorderSide(color: Color(0xFF18181B), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        showRestockSheet(context, item, provider);
                      },
                      icon: const Icon(Icons.add_shopping_cart_outlined, size: 18, color: Color(0xFF18181B)),
                      label: const Text('Restock', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF18181B))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF18181B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () async {
                          Navigator.pop(sheetCtx);
                          final ok = await provider.updateItemQuantity(item.id, remainingAfter, reason: 'consume');
                          if (ok && context.mounted) {
                            AppFeedback.showSuccess(
                              context,
                              'Used $formattedConsume ${item.unit}. Remaining: $formattedRemain ${item.unit}',
                            );
                            if (item.minQuantity != null && remainingAfter <= item.minQuantity!) {
                              AppFeedback.showWarning(
                                context,
                                'Warning: Quantity has dropped to minimum level (≤ ${item.minQuantity} ${item.unit})',
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text(
                          'Confirm Use',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


void showRestockSheet(BuildContext context, Item item, InventoryProvider provider) {
  double addAmount = 1.0;
  final controller = TextEditingController(text: '1');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final currentQty = item.quantity;
          final formattedCurrent = currentQty % 1 == 0 ? currentQty.toInt().toString() : currentQty.toString();

          return Container(
            padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.add_shopping_cart_outlined, color: Color(0xFF10B981), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Restock: ${item.name}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Current stock: $formattedCurrent ${item.unit}',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Quantity to add (${item.unit})',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    suffixText: item.unit,
                  ),
                  onChanged: (val) {
                    final parsed = double.tryParse(val) ?? 0;
                    setSheetState(() => addAmount = parsed);
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [1, 2, 5, 10].map((n) {
                    return ActionChip(
                      label: Text('+$n ${item.unit}'),
                      onPressed: () {
                        controller.text = n.toString();
                        setSheetState(() => addAmount = n.toDouble());
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: addAmount > 0
                        ? () async {
                            Navigator.pop(sheetCtx);
                            final newQty = item.quantity + addAmount;
                            final ok = await provider.updateItemQuantity(item.id, newQty, reason: 'restock');
                            if (ok && context.mounted) {
                              final formattedNew = newQty % 1 == 0 ? newQty.toInt().toString() : newQty.toString();
                              AppFeedback.showSuccess(
                                context,
                                'Added $addAmount ${item.unit}. Total: $formattedNew ${item.unit}',
                              );
                            }
                          }
                        : null,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Confirm Restock', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
