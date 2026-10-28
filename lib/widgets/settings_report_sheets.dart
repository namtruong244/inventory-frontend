import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';

void showExportReportSheet(BuildContext context, InventoryProvider provider) {
  final report = provider.generateInventoryReport();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.inventoryReport,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      context.l10n.generatedPlainTextInventoryStatus,
                      style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                    ),
                  ],
                ),
                IconButton(
 tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: AppIcon(Icons.close, color: context.colors.textSecondary),
                  onPressed: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.fill,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: SelectableText(
                    report,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.5,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: report));
                  Navigator.pop(sheetContext);
                  AppFeedback.showSuccess(context, context.l10n.reportCopiedToClipboard);
                },
                icon: const AppIcon(Icons.copy_rounded, size: 18),
                label: Text(context.l10n.copyReportToClipboard, style: TextStyle(fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showInventoryStatusSheet(BuildContext context, InventoryProvider provider) {
  final total = provider.items.length;
  final stored = provider.items.where((i) => i.status == ItemStatus.stored).length;
  final inUse = provider.items.where((i) => i.status == ItemStatus.inUse).length;
  final lent = provider.items.where((i) => i.status == ItemStatus.lent).length;
  final lowStock = provider.getLowStockItems().length;
  final expired = provider.getExpiredItems().length;
  final expiringSoon = provider.getExpiringItems(withinDays: provider.expiryWarningDays).length;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final bottomPadding = MediaQuery.of(sheetContext).padding.bottom;
      final maxHeight = MediaQuery.of(sheetContext).size.height * 0.8;

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
                  context.l10n.inventoryHealthBreakdown,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.realTimeConditionBreakdownOf(total),
                  style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                ),
                const SizedBox(height: 18),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildStatusRow(context.l10n.storedInContainers, stored, total, AppTones.matcha),
                        buildStatusRow(context.l10n.inUseActive, inUse, total, AppTones.sky),
                        buildStatusRow(context.l10n.lentToBorrowers, lent, total, AppTones.lilac),
                        buildStatusRow(context.l10n.lowStockWarning, lowStock, total, AppTones.amber),
                        buildStatusRow(context.l10n.expiringSoonD(provider.expiryWarningDays), expiringSoon, total, AppTones.amber),
                        buildStatusRow(context.l10n.expiredAssets, expired, total, AppTones.coral),
                      ],
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


Widget buildStatusRow(String label, int count, int total, Color color) {
  return Builder(builder: (context) {
  final percentage = total > 0 ? (count / total) : 0.0;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: context.colors.textPrimary)),
              ],
            ),
            Text(
              '$count items (${(percentage * 100).toStringAsFixed(0)}%)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: context.colors.fill,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    ),
  );
});
}
