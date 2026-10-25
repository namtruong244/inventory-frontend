import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import 'app_image_view.dart';
import 'move_item_sheet.dart';
import '../screens/box_details_screen.dart';
import 'tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';


Widget buildActiveLoanCard(BuildContext context, InventoryProvider provider, LendingRecord loan) {
  final isOverdue = loan.isOverdue;

  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: isOverdue ? context.colors.dangerSoft : context.colors.infoSoft,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isOverdue ? const Color(0xFFFCA5A5) : const Color(0xFFBFDBFE),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isOverdue ? Icons.warning_amber_rounded : Icons.handshake_outlined,
                  color: isOverdue ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isOverdue ? context.l10n.overdueLoan : context.l10n.currentlyLentOut,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? context.colors.dangerStrong : const Color(0xFF1E40AF),
                  ),
                ),
              ],
            ),
            if (isOverdue)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'OVERDUE',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.commonBorrower2(loan.borrowerName),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        if (loan.borrowerContact.isNotEmpty)
          Text(
            context.l10n.commonContact(loan.borrowerContact),
            style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
          ),
        const SizedBox(height: 6),
        Text(
          'Lent on: ${DateFormat('MMM dd, yyyy').format(loan.lentDate)}',
          style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
        ),
        if (loan.expectedReturnDate != null)
          Text(
            'Expected Return: ${DateFormat('MMM dd, yyyy').format(loan.expectedReturnDate!)}',
            style: TextStyle(
              color: isOverdue ? const Color(0xFFDC2626) : context.colors.textSecondary,
              fontSize: 12,
              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
      ],
    ),
  );
}


Widget buildStorageLocationCard(
  BuildContext context,
  InventoryProvider provider,
  Item item,
  Box? parentBox,
  List<Box> breadcrumbs,
) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 20, color: context.colors.textPrimary),
                SizedBox(width: 8),
                Text(
                  context.l10n.storageLocation,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                ),
              ],
            ),
            Tappable(
              onTap: () => MoveItemSheet.show(context, item),
              child: Text(
                context.l10n.commonChange,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Interactive Smooth Horizontally Scrollable Breadcrumb Trail
        if (breadcrumbs.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (int i = 0; i < breadcrumbs.length; i++) ...[
                  Tappable(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BoxDetailsScreen(boxId: breadcrumbs[i].id),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: i == breadcrumbs.length - 1
                            ? context.colors.primary
                            : context.colors.fill,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            breadcrumbs[i].type.icon,
                            size: 14,
                            color: i == breadcrumbs.length - 1 ? Colors.white : context.colors.textPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            breadcrumbs[i].name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: i == breadcrumbs.length - 1 ? Colors.white : context.colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i < breadcrumbs.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(Icons.chevron_right_rounded, size: 16, color: context.colors.textMuted),
                    ),
                ],
              ],
            ),
          )
        else
          Text(
            parentBox != null ? parentBox.name : context.l10n.unknownLocation,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
      ],
    ),
  );
}


Widget buildExpiryCard(BuildContext context, Item item) {
  final isExpired = item.isExpired;
  final daysLeft = item.daysUntilExpiry;

  Color bgColor;
  Color textColor;
  Color borderColor;
  String statusTitle;

  if (isExpired) {
    bgColor = context.colors.dangerSoft;
    textColor = const Color(0xFFDC2626);
    borderColor = const Color(0xFFFCA5A5);
    statusTitle = context.l10n.productHasExpired;
  } else if (daysLeft != null && daysLeft <= 15) {
    bgColor = context.colors.warningSoft;
    textColor = const Color(0xFFD97706);
    borderColor = const Color(0xFFFDE68A);
    statusTitle = context.l10n.expiresSoonInDays(daysLeft);
  } else {
    bgColor = const Color(0xFFF0FDF4);
    textColor = const Color(0xFF16A34A);
    borderColor = const Color(0xFFBBF7D0);
    statusTitle = context.l10n.freshDaysRemaining(daysLeft ?? 0);
  }

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: borderColor),
    ),
    child: Row(
      children: [
        Icon(Icons.event_busy_outlined, color: textColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusTitle,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                'Expiry date: ${DateFormat('MMMM dd, yyyy').format(item.expiryDate!)}',
                style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget buildLowStockCard(BuildContext context, Item item) {
  final qty = item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity;
  final minQty = item.minQuantity! % 1 == 0 ? item.minQuantity!.toInt() : item.minQuantity;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colors.warningSoft,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFFDE68A)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.warningSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.production_quantity_limits_rounded, color: Color(0xFFD97706), size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.lowStockWarning,
                style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.warningStrong, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.currentThreshold(qty, item.unit, minQty ?? 0, item.unit),
                style: TextStyle(color: context.colors.warningStrong, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget buildAssetDetailsCard(BuildContext context, Item item) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long_outlined, size: 20, color: context.colors.textPrimary),
            SizedBox(width: 8),
            Text(
              context.l10n.assetPurchaseInformation,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Price & Purchase Date
        Row(
          children: [
            Expanded(
              child: buildDetailTile(
                label: context.l10n.purchasePrice2,
                value: item.purchasePrice != null ? Provider.of<InventoryProvider>(context).formatPrice(item.purchasePrice) : context.l10n.notRecorded,
                icon: Icons.attach_money_rounded,
              ),
            ),
            Expanded(
              child: buildDetailTile(
                label: context.l10n.purchaseDate,
                value: item.purchaseDate != null ? DateFormat('MMM dd, yyyy').format(item.purchaseDate!) : 'Not recorded',
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ],
        ),
        const Divider(height: 24, thickness: 0.8),

        // Low Stock Alert Threshold
        Row(
          children: [
            Expanded(
              child: buildDetailTile(
                label: context.l10n.lowStockAlertThreshold,
                value: item.minQuantity != null
                    ? '≤ ${item.minQuantity! % 1 == 0 ? item.minQuantity!.toInt() : item.minQuantity} ${item.unit}'
                    : context.l10n.notTracked,
                icon: Icons.production_quantity_limits_rounded,
              ),
            ),
          ],
        ),
        const Divider(height: 24, thickness: 0.8),

        // Barcode & Serial Number
        if (item.barcode != null && item.barcode!.isNotEmpty) ...[
          buildCopyableRow(context, context.l10n.barcodeUpcEan, item.barcode!, Icons.qr_code_2_rounded),
          const SizedBox(height: 12),
        ],
        if (item.serialNumber != null && item.serialNumber!.isNotEmpty) ...[
          buildCopyableRow(context, context.l10n.serialNumber, item.serialNumber!, Icons.tag_rounded),
          const SizedBox(height: 12),
        ],

        // Warranty Info
        if (item.warrantyExpiryDate != null) ...[
          const Divider(height: 24, thickness: 0.8),
          Row(
            children: [
              Icon(
                item.isWarrantyExpired ? Icons.shield_outlined : Icons.verified_user_outlined,
                size: 20,
                color: item.isWarrantyExpired ? Colors.red : const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.isWarrantyExpired ? context.l10n.warrantyExpired : context.l10n.warrantyActive,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: item.isWarrantyExpired ? Colors.red : const Color(0xFF059669),
                      ),
                    ),
                    Text(
                      'Valid until: ${DateFormat('MMM dd, yyyy').format(item.warrantyExpiryDate!)}${item.daysUntilWarrantyExpiry != null && item.daysUntilWarrantyExpiry! > 0 ? ' (${item.daysUntilWarrantyExpiry} days left)' : ''}',
                      style: TextStyle(fontSize: 11, color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}


Widget buildDetailTile({required String label, required String value, required IconData icon}) {
  return Builder(builder: (context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 14, color: context.colors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: context.colors.textMuted)),
        ],
      ),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    ],
  );
});
}


Widget buildCopyableRow(BuildContext context, String label, String value, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 18, color: context.colors.textSecondary),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: context.colors.textMuted)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
          ],
        ),
      ),
      IconButton(
 tooltip: context.l10n.commonCopy,
        icon: const Icon(Icons.copy_rounded, size: 16),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: value));
          AppFeedback.showSuccess(context, context.l10n.copiedToClipboard(label));
        },
      ),
    ],
  );
}


Widget buildReceiptsCard(BuildContext context, List<String> receiptPhotos) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.document_scanner_outlined, size: 20, color: context.colors.textPrimary),
            SizedBox(width: 8),
            Text(
              context.l10n.receiptsWarrantyProof,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: receiptPhotos.length,
            itemBuilder: (context, idx) {
              final photoUrl = receiptPhotos[idx];
              return Tappable(
                onTap: () => showFullScreenImage(context, photoUrl),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: AppImageView(
                    imageUrlOrPath: photoUrl,
                    borderRadius: BorderRadius.circular(14),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}


void showFullScreenImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AppImageView(
                imageUrlOrPath: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.6),
              child: IconButton(
 tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
