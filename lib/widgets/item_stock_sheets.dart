import 'package:flutter/material.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';
import 'soft_ui.dart';
import 'tappable.dart';

String _fmt(double v, {int digits = 1}) => v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(digits);

/// Shared sheet chrome: rounded top, grabber, tinted icon + title + stock line.
class _StockSheetFrame extends StatelessWidget {
  final IconData icon;
  final Color tone;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _StockSheetFrame({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 13, color: c.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _RoundStep extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundStep(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tappable(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: onTap == null ? c.fill : c.surface,
          shape: BoxShape.circle,
          boxShadow: onTap == null ? null : c.cardShadow,
        ),
        child: AppIcon(icon, size: 22, color: onTap == null ? c.textMuted : c.textPrimary),
      ),
    );
  }
}

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
          final c = context.colors;
          final currentQty = item.quantity;
          final remainingAfter = (currentQty - consumeAmount).clamp(0.0, double.infinity);
          final formattedCurrent = _fmt(currentQty, digits: 2);
          final formattedConsume = _fmt(consumeAmount, digits: 2);
          final formattedRemain = _fmt(remainingAfter);
          final isEmpty = remainingAfter == 0;
          final isLow = item.minQuantity != null && remainingAfter <= item.minQuantity!;
          final tone = isEmpty ? AppTones.coral : (isLow ? AppTones.amber : AppTones.matcha);

          Widget quick(String label, double value) => SoftFilterChip(
                label: label,
                selected: consumeAmount == value,
                onTap: () => setSheetState(() => consumeAmount = value),
              );

          return _StockSheetFrame(
            icon: Icons.remove_circle_outline,
            tone: AppTones.coral,
            title: context.l10n.commonConsume2(item.name),
            subtitle: context.l10n.currentStock(formattedCurrent, item.unit),
            children: [
              // Big stepper
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundStep(Icons.remove, consumeAmount > 1 ? () => setSheetState(() => consumeAmount -= 1) : null),
                  Column(
                    children: [
                      Text(
                        formattedConsume,
                        style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: -1.5, color: c.textPrimary, height: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${context.l10n.quantityToUse} · ${item.unit}',
                        style: TextStyle(fontSize: 12, color: c.textSecondary),
                      ),
                    ],
                  ),
                  _RoundStep(Icons.add, consumeAmount < currentQty ? () => setSheetState(() => consumeAmount += 1) : null),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (currentQty >= 1) quick(context.l10n.use1(item.unit), 1.0),
                  if (currentQty >= 2) quick(context.l10n.use2(item.unit), 2.0),
                  if (currentQty >= 5) quick(context.l10n.use5(item.unit), 5.0),
                  quick(context.l10n.useAll, currentQty),
                ],
              ),
              const SizedBox(height: 20),

              // What is left: bar + tinted verdict
              SoftBar(value: currentQty > 0 ? remainingAfter / currentQty : 0, color: tone, height: 8),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: SoftChip.tone(
                  isEmpty ? context.l10n.willBeOutOfStock : context.l10n.remainingAfterUse(formattedRemain, item.unit),
                  tone,
                  icon: isEmpty
                      ? Icons.error_outline_rounded
                      : (isLow ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: c.fill,
                      foregroundColor: c.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      showRestockSheet(context, item, provider);
                    },
                    icon: const AppIcon(Icons.add_shopping_cart_outlined, size: 18),
                    label: Text(context.l10n.commonRestock),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: c.accent, foregroundColor: c.onAccent),
                      onPressed: () async {
                        Navigator.pop(sheetCtx);
                        final ok = await provider.updateItemQuantity(item.id, remainingAfter, reason: 'consume');
                        if (ok && context.mounted) {
                          AppFeedback.showSuccess(
                            context,
                            context.l10n.usedRemaining(formattedConsume, item.unit, formattedRemain, item.unit),
                          );
                          if (item.minQuantity != null && remainingAfter <= item.minQuantity!) {
                            AppFeedback.showWarning(
                              context,
                              context.l10n.warningQuantityHasDroppedTo(item.minQuantity ?? 0, item.unit),
                            );
                          }
                        }
                      },
                      icon: const AppIcon(Icons.check_rounded, size: 18),
                      label: Text(context.l10n.confirmUse),
                    ),
                  ),
                ],
              ),
            ],
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
          final c = context.colors;
          final formattedCurrent = _fmt(item.quantity, digits: 2);

          return _StockSheetFrame(
            icon: Icons.add_shopping_cart_outlined,
            tone: AppTones.matcha,
            title: context.l10n.commonRestock2(item.name),
            subtitle: context.l10n.currentStock(formattedCurrent, item.unit),
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  labelText: context.l10n.quantityToAdd(item.unit),
                  suffixText: item.unit,
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val) ?? 0;
                  setSheetState(() => addAmount = parsed);
                },
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [1, 2, 5, 10].map((n) {
                  return SoftFilterChip(
                    label: '+$n ${item.unit}',
                    selected: addAmount == n.toDouble(),
                    onTap: () {
                      controller.text = n.toString();
                      setSheetState(() => addAmount = n.toDouble());
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: c.accent, foregroundColor: c.onAccent),
                onPressed: addAmount > 0
                    ? () async {
                        Navigator.pop(sheetCtx);
                        final newQty = item.quantity + addAmount;
                        final ok = await provider.updateItemQuantity(item.id, newQty, reason: 'restock');
                        if (ok && context.mounted) {
                          final formattedNew = _fmt(newQty, digits: 2);
                          AppFeedback.showSuccess(
                            context,
                            context.l10n.addedTotal(addAmount, item.unit, formattedNew, item.unit),
                          );
                        }
                      }
                    : null,
                icon: const AppIcon(Icons.check_rounded, size: 18),
                label: Text(context.l10n.confirmRestock),
              ),
            ],
          );
        },
      );
    },
  );
}
