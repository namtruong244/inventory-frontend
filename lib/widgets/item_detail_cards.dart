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


Widget buildActiveLoanCard(BuildContext context, InventoryProvider provider, LendingRecord loan) {
  final isOverdue = loan.isOverdue;

  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: isOverdue ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF),
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
                  isOverdue ? 'Overdue Loan' : 'Currently Lent Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? const Color(0xFF991B1B) : const Color(0xFF1E40AF),
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
          'Borrower: ${loan.borrowerName}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        if (loan.borrowerContact.isNotEmpty)
          Text(
            'Contact: ${loan.borrowerContact}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        const SizedBox(height: 6),
        Text(
          'Lent on: ${DateFormat('MMM dd, yyyy').format(loan.lentDate)}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        if (loan.expectedReturnDate != null)
          Text(
            'Expected Return: ${DateFormat('MMM dd, yyyy').format(loan.expectedReturnDate!)}',
            style: TextStyle(
              color: isOverdue ? const Color(0xFFDC2626) : Colors.grey.shade700,
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
      color: Colors.white,
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
            const Row(
              children: [
                Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF18181B)),
                SizedBox(width: 8),
                Text(
                  'Storage Location',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => MoveItemSheet.show(context, item),
              child: const Text(
                'Change',
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
                  GestureDetector(
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
                            ? const Color(0xFF18181B)
                            : const Color(0xFFF4F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            breadcrumbs[i].type.icon,
                            size: 14,
                            color: i == breadcrumbs.length - 1 ? Colors.white : const Color(0xFF18181B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            breadcrumbs[i].name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: i == breadcrumbs.length - 1 ? Colors.white : const Color(0xFF18181B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i < breadcrumbs.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey.shade400),
                    ),
                ],
              ],
            ),
          )
        else
          Text(
            parentBox != null ? parentBox.name : 'Unknown Location',
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
    bgColor = const Color(0xFFFEF2F2);
    textColor = const Color(0xFFDC2626);
    borderColor = const Color(0xFFFCA5A5);
    statusTitle = 'Product has Expired!';
  } else if (daysLeft != null && daysLeft <= 15) {
    bgColor = const Color(0xFFFFFBEB);
    textColor = const Color(0xFFD97706);
    borderColor = const Color(0xFFFDE68A);
    statusTitle = 'Expires soon in $daysLeft days';
  } else {
    bgColor = const Color(0xFFF0FDF4);
    textColor = const Color(0xFF16A34A);
    borderColor = const Color(0xFFBBF7D0);
    statusTitle = 'Fresh • $daysLeft days remaining';
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
      color: const Color(0xFFFFFBEB),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFFDE68A)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.production_quantity_limits_rounded, color: Color(0xFFD97706), size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Low Stock Warning',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB45309), fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                'Current: $qty ${item.unit} • Threshold: ≤ $minQty ${item.unit}',
                style: const TextStyle(color: Color(0xFF92400E), fontSize: 12),
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
      color: Colors.white,
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
        const Row(
          children: [
            Icon(Icons.receipt_long_outlined, size: 20, color: Color(0xFF18181B)),
            SizedBox(width: 8),
            Text(
              'Asset & Purchase Information',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Price & Purchase Date
        Row(
          children: [
            Expanded(
              child: buildDetailTile(
                label: 'Purchase Price',
                value: item.purchasePrice != null ? Provider.of<InventoryProvider>(context).formatPrice(item.purchasePrice) : 'Not recorded',
                icon: Icons.attach_money_rounded,
              ),
            ),
            Expanded(
              child: buildDetailTile(
                label: 'Purchase Date',
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
                label: 'Low Stock Alert Threshold',
                value: item.minQuantity != null
                    ? '≤ ${item.minQuantity! % 1 == 0 ? item.minQuantity!.toInt() : item.minQuantity} ${item.unit}'
                    : 'Not tracked',
                icon: Icons.production_quantity_limits_rounded,
              ),
            ),
          ],
        ),
        const Divider(height: 24, thickness: 0.8),

        // Barcode & Serial Number
        if (item.barcode != null && item.barcode!.isNotEmpty) ...[
          buildCopyableRow(context, 'Barcode (UPC/EAN)', item.barcode!, Icons.qr_code_2_rounded),
          const SizedBox(height: 12),
        ],
        if (item.serialNumber != null && item.serialNumber!.isNotEmpty) ...[
          buildCopyableRow(context, 'Serial Number', item.serialNumber!, Icons.tag_rounded),
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
                      item.isWarrantyExpired ? 'Warranty Expired' : 'Warranty Active',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: item.isWarrantyExpired ? Colors.red : const Color(0xFF059669),
                      ),
                    ),
                    Text(
                      'Valid until: ${DateFormat('MMM dd, yyyy').format(item.warrantyExpiryDate!)}${item.daysUntilWarrantyExpiry != null && item.daysUntilWarrantyExpiry! > 0 ? ' (${item.daysUntilWarrantyExpiry} days left)' : ''}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    ],
  );
}


Widget buildCopyableRow(BuildContext context, String label, String value, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Colors.grey.shade600),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
          ],
        ),
      ),
      IconButton(
        icon: const Icon(Icons.copy_rounded, size: 16),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: value));
          AppFeedback.showSuccess(context, 'Copied $label to clipboard');
        },
      ),
    ],
  );
}


Widget buildReceiptsCard(BuildContext context, List<String> receiptPhotos) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
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
        const Row(
          children: [
            Icon(Icons.document_scanner_outlined, size: 20, color: Color(0xFF18181B)),
            SizedBox(width: 8),
            Text(
              'Receipts & Warranty Proof',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
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
              return GestureDetector(
                onTap: () => showFullScreenImage(context, photoUrl),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
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
