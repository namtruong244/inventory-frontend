import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'soft_sheet.dart';
import 'soft_ui.dart';

void showExportReportSheet(BuildContext context, InventoryProvider provider) {
  final report = provider.generateInventoryReport();

  showSoftSheet(
    context,
    title: context.l10n.inventoryReport,
    subtitle: context.l10n.generatedPlainTextInventoryStatus,
    builder: (sheetContext) {
      final c = sheetContext.colors;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.5,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.fill,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    report,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.5,
                      color: c.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SoftButton(
            label: context.l10n.copyReportToClipboard,
            icon: Icons.copy_rounded,
            expand: true,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: report));
              Navigator.pop(sheetContext);
              AppFeedback.showSuccess(
                context,
                context.l10n.reportCopiedToClipboard,
              );
            },
          ),
        ],
      );
    },
  );
}

void showInventoryStatusSheet(
  BuildContext context,
  InventoryProvider provider,
) {
  final total = provider.items.length;
  final stored = provider.items
      .where((i) => i.status == ItemStatus.stored)
      .length;
  final inUse = provider.items
      .where((i) => i.status == ItemStatus.inUse)
      .length;
  final lent = provider.items.where((i) => i.status == ItemStatus.lent).length;
  final lowStock = provider.getLowStockItems().length;
  final expired = provider.getExpiredItems().length;
  final expiringSoon = provider
      .getExpiringItems(withinDays: provider.expiryWarningDays)
      .length;

  showSoftSheet(
    context,
    title: context.l10n.inventoryHealthBreakdown,
    subtitle: context.l10n.realTimeConditionBreakdownOf(total),
    builder: (sheetContext) => SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildStatusRow(
            context.l10n.storedInContainers,
            stored,
            total,
            AppTones.matcha,
          ),
          buildStatusRow(context.l10n.inUseActive, inUse, total, AppTones.sky),
          buildStatusRow(
            context.l10n.lentToBorrowers,
            lent,
            total,
            AppTones.lilac,
          ),
          buildStatusRow(
            context.l10n.lowStockWarning,
            lowStock,
            total,
            AppTones.amber,
          ),
          buildStatusRow(
            context.l10n.expiringSoonD(provider.expiryWarningDays),
            expiringSoon,
            total,
            AppTones.amber,
          ),
          buildStatusRow(
            context.l10n.expiredAssets,
            expired,
            total,
            AppTones.coral,
          ),
        ],
      ),
    ),
  );
}

Widget buildStatusRow(String label, int count, int total, Color color) {
  return Builder(
    builder: (context) {
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
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$count items (${(percentage * 100).toStringAsFixed(0)}%)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary,
                  ),
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
    },
  );
}
