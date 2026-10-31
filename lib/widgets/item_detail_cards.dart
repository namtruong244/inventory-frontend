import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../screens/box_details_screen.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import 'app_feedback.dart';
import 'app_icon.dart';
import 'app_image_view.dart';
import 'item_card_parts.dart';
import 'move_item_sheet.dart';
import 'soft_ui.dart';
import 'tappable.dart';

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  final list = parts.toList();
  final first = String.fromCharCode(list.first.runes.first);
  if (list.length == 1) return first.toUpperCase();
  return (first + String.fromCharCode(list.last.runes.first)).toUpperCase();
}

Widget _dateTile(
  BuildContext context, {
  required String label,
  required String value,
  required Color background,
  required Color foreground,
  Color? labelColor,
}) {
  final c = context.colors;
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: labelColor ?? c.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: foreground,
          ),
        ),
      ],
    ),
  );
}

Widget buildActiveLoanCard(
  BuildContext context,
  InventoryProvider provider,
  LendingRecord loan,
) {
  final c = context.colors;
  final l10n = context.l10n;
  final overdue = loan.isOverdue;
  final due = loan.expectedReturnDate;
  final lateDays = overdue && due != null ? -daysBetweenToday(due) : 0;
  return ItemSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemCardHeader(
          title: overdue ? l10n.overdueLoan : l10n.itemCurrentlyLent,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.warningSoft,
                shape: BoxShape.circle,
              ),
              child: Text(
                _initials(loan.borrowerName),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: c.warningStrong,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.lentTo(loan.borrowerName),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary,
                    ),
                  ),
                  if (loan.borrowerContact.isNotEmpty)
                    Text(
                      loan.borrowerContact,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: c.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _dateTile(
                context,
                label: l10n.itemLentOn,
                value: formatDate(context, loan.lentDate),
                background: c.fill,
                foreground: c.textPrimary,
              ),
            ),
            if (due != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: _dateTile(
                  context,
                  label: l10n.itemDueBack,
                  value: overdue
                      ? l10n.itemDueBackLate(formatDate(context, due), lateDays)
                      : formatDate(context, due),
                  background: overdue ? c.dangerSoft : c.fill,
                  foreground: overdue ? c.dangerStrong : c.textPrimary,
                  labelColor: overdue ? c.dangerStrong : null,
                ),
              ),
            ],
          ],
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
  final c = context.colors;
  return ItemSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemCardHeader(
          title: context.l10n.storageLocation,
          pillLabel: context.l10n.commonMove,
          pillIcon: Icons.drive_file_move_outlined,
          onPill: () => MoveItemSheet.show(context, item),
        ),
        const SizedBox(height: 14),
        if (breadcrumbs.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (int i = 0; i < breadcrumbs.length; i++) ...[
                  Tappable(
                    semanticLabel: breadcrumbs[i].name,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BoxDetailsScreen(boxId: breadcrumbs[i].id),
                        ),
                      );
                    },
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: i == breadcrumbs.length - 1 ? c.primary : c.fill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(
                            breadcrumbs[i].type.icon,
                            size: 14,
                            color: i == breadcrumbs.length - 1
                                ? Colors.white
                                : c.textPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            breadcrumbs[i].name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: i == breadcrumbs.length - 1
                                  ? Colors.white
                                  : c.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i < breadcrumbs.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AppIcon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: c.textMuted,
                      ),
                    ),
                ],
              ],
            ),
          )
        else
          Text(
            parentBox != null ? parentBox.name : context.l10n.unknownLocation,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: c.textPrimary,
            ),
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
  String statusTitle;

  if (isExpired) {
    bgColor = context.colors.dangerSoft;
    textColor = AppTones.coral;
    statusTitle = context.l10n.productHasExpired;
  } else if (daysLeft != null && daysLeft <= 15) {
    bgColor = context.colors.warningSoft;
    textColor = AppTones.amber;
    statusTitle = context.l10n.expiresSoonInDays(daysLeft);
  } else {
    bgColor = AppTones.limeSoft;
    textColor = AppTones.matcha;
    statusTitle = context.l10n.freshDaysRemaining(daysLeft ?? 0);
  }

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        AppIcon(Icons.event_busy_outlined, color: textColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.expiryDateOn(
                  formatDateLong(context, item.expiryDate!),
                ),
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
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
  final minQty = item.minQuantity! % 1 == 0
      ? item.minQuantity!.toInt()
      : item.minQuantity;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colors.warningSoft,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.warningSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: AppIcon(
            Icons.production_quantity_limits_rounded,
            color: AppTones.amber,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.lowStockWarning,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.colors.warningStrong,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.currentThreshold(
                  qty,
                  item.unit,
                  minQty ?? 0,
                  item.unit,
                ),
                style: TextStyle(
                  color: context.colors.warningStrong,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Warranty & lifecycle: ring with the share of warranty time left.
Widget buildWarrantyCard(BuildContext context, Item item) {
  final c = context.colors;
  final l10n = context.l10n;
  final until = item.warrantyExpiryDate!;
  final expired = item.isWarrantyExpired;
  final days = item.daysUntilWarrantyExpiry ?? 0;
  final bought = item.purchaseDate;
  double? pct;
  if (bought != null && until.isAfter(bought)) {
    final total = until.difference(bought).inDays;
    pct = expired ? 0 : (days / total).clamp(0.0, 1.0);
  }
  final tone = expired ? AppTones.coral : AppTones.matcha;
  return ItemSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemCardHeader(title: l10n.itemWarrantyLifecycle),
        const SizedBox(height: 14),
        Row(
          children: [
            if (pct != null)
              SoftRing(
                value: pct,
                color: tone,
                size: 56,
                stroke: 7,
                center: Text(
                  '${(pct * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                  ),
                ),
              )
            else
              SoftIconTile(
                expired ? Icons.shield_outlined : Icons.verified_user_outlined,
                color: tone,
                size: 56,
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    children: [
                      SoftChip.tone(
                        expired ? l10n.warrantyExpired : l10n.warrantyActive,
                        tone,
                        icon: expired
                            ? Icons.shield_outlined
                            : Icons.verified_user_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.validUntilDate(formatDate(context, until)),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  if (!expired && days > 0)
                    Text(
                      l10n.itemDaysRemaining(days),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: c.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _infoRow(
  BuildContext context,
  String label,
  String value, {
  bool copy = false,
  bool last = false,
}) {
  final c = context.colors;
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      border: last ? null : Border(bottom: BorderSide(color: c.border)),
    ),
    child: Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
            ),
          ),
        ),
        if (copy) ...[
          const SizedBox(width: 8),
          Tappable(
            semanticLabel: context.l10n.commonCopy,
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              AppFeedback.showSuccess(
                context,
                context.l10n.copiedToClipboard(label),
              );
            },
            child: AppIcon(Icons.copy_rounded, size: 16, color: c.textMuted),
          ),
        ],
      ],
    ),
  );
}

Widget buildPurchaseInfoCard(BuildContext context, Item item) {
  final l10n = context.l10n;
  final provider = Provider.of<InventoryProvider>(context);
  final rows = <Widget>[
    _infoRow(
      context,
      l10n.purchaseDate,
      item.purchaseDate != null
          ? formatDate(context, item.purchaseDate!)
          : l10n.notRecorded,
    ),
    _infoRow(
      context,
      l10n.purchasePrice2,
      item.purchasePrice != null
          ? provider.formatPrice(item.purchasePrice)
          : l10n.notRecorded,
    ),
    _infoRow(
      context,
      l10n.lowStockAlertThreshold,
      item.minQuantity != null
          ? '≤ ${item.minQuantity! % 1 == 0 ? item.minQuantity!.toInt() : item.minQuantity} ${item.unit}'
          : l10n.notTracked,
    ),
  ];
  final hasSerial = item.serialNumber != null && item.serialNumber!.isNotEmpty;
  final hasBarcode = item.barcode != null && item.barcode!.isNotEmpty;
  if (hasSerial) {
    rows.add(
      _infoRow(
        context,
        l10n.serialNumber,
        item.serialNumber!,
        copy: true,
        last: !hasBarcode,
      ),
    );
  }
  if (hasBarcode) {
    rows.add(
      _infoRow(
        context,
        l10n.barcodeUpcEan,
        item.barcode!,
        copy: true,
        last: true,
      ),
    );
  }
  if (!hasSerial && !hasBarcode) {
    rows.removeLast();
    rows.add(
      _infoRow(
        context,
        l10n.lowStockAlertThreshold,
        item.minQuantity != null
            ? '≤ ${item.minQuantity! % 1 == 0 ? item.minQuantity!.toInt() : item.minQuantity} ${item.unit}'
            : l10n.notTracked,
        last: true,
      ),
    );
  }
  return ItemSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemCardHeader(title: l10n.itemPurchaseInfo),
        const SizedBox(height: 4),
        ...rows,
      ],
    ),
  );
}

Widget buildReceiptsCard(BuildContext context, List<String> receiptPhotos) {
  return ItemSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemCardHeader(title: context.l10n.receiptsWarrantyProof),
        const SizedBox(height: 14),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: receiptPhotos.length,
            itemBuilder: (context, idx) {
              final photoUrl = receiptPhotos[idx];
              return Tappable(
                semanticLabel: context.l10n.productPhotos,
                onTap: () => showFullScreenImage(context, photoUrl),
                child: Container(
                  width: 96,
                  margin: const EdgeInsets.only(right: 12),
                  child: AppImageView(
                    imageUrlOrPath: photoUrl,
                    borderRadius: BorderRadius.circular(16),
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
                icon: const AppIcon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
