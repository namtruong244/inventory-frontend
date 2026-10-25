import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';

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
        decoration: const BoxDecoration(
          color: Colors.white,
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventory Report',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Generated plain-text inventory status report',
                      style: TextStyle(fontSize: 12, color: Color(0xFF71717A)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: SelectableText(
                    report,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.5,
                      color: Color(0xFF27272A),
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
                  AppFeedback.showSuccess(context, 'Report copied to clipboard!');
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy Report to Clipboard', style: TextStyle(fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF18181B),
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
        decoration: const BoxDecoration(
          color: Colors.white,
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
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Inventory Health Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time condition breakdown of $total tracked items',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 18),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildStatusRow('Stored in Containers', stored, total, const Color(0xFF10B981)),
                        buildStatusRow('In Use / Active', inUse, total, const Color(0xFF3B82F6)),
                        buildStatusRow('Lent to Borrowers', lent, total, const Color(0xFF8B5CF6)),
                        buildStatusRow('Low Stock Warning', lowStock, total, const Color(0xFFF59E0B)),
                        buildStatusRow('Expiring Soon (≤ ${provider.expiryWarningDays}d)', expiringSoon, total, const Color(0xFFF97316)),
                        buildStatusRow('Expired Assets', expired, total, const Color(0xFFEF4444)),
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
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF18181B))),
              ],
            ),
            Text(
              '$count items (${(percentage * 100).toStringAsFixed(0)}%)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFFF4F4F6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    ),
  );
}
