import 'package:flutter/material.dart';

import '../utils/e2e.dart';

import 'package:flutter_slidable/flutter_slidable.dart';

import 'app_image_view.dart';
import 'tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';
import 'soft_ui.dart';

class ItemCard extends StatelessWidget {
  final String name;
  final String description;
  final String? imageUrl;

  /// Storage path ("Bedroom › Desk drawer"); shown with a pin icon in the meta
  /// row instead of [description].
  final String? locationPath;

  /// Quantity headline on the right, e.g. "12 pcs".
  final String? quantityText;

  /// Colored status pill (lent, broken...).
  final Widget? status;

  /// Extra pastel tags under the name (low stock, expiring...).
  final List<Widget> tags;

  /// 0..1 stock level against the minimum; shown as a thin bar.
  final double? stockRatio;
  final Color? stockColor;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableClip;
  final String? id;

  const ItemCard({
    super.key,
    required this.name,
    required this.description,
    this.imageUrl,
    this.locationPath,
    this.quantityText,
    this.status,
    this.tags = const [],
    this.stockRatio,
    this.stockColor,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.onLongPress,
    this.enableClip = true,
    this.id,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasChips = status != null || tags.isNotEmpty;

    final hasMeta =
        quantityText != null || description.isNotEmpty || locationPath != null;
    final metaText = locationPath ?? description;

    Widget card = Container(
      padding: const EdgeInsets.all(12),
      color: c.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 64,
                  height: 64,
                  color: c.fill,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? AppImageView(
                          imageUrlOrPath: imageUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: AppIcon(
                            Icons.image_outlined,
                            color: c.textPrimary,
                            size: 26,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    if (hasMeta) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (quantityText != null)
                            Text(
                              quantityText!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: c.textSecondary,
                              ),
                            ),
                          if (quantityText != null && metaText.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Text(
                              '·',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: c.textMuted,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          if (locationPath != null) ...[
                            AppIcon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: c.textSecondary,
                            ),
                            const SizedBox(width: 4),
                          ],
                          if (metaText.isNotEmpty)
                            Expanded(
                              child: Text(
                                metaText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: c.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (hasChips) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [?status, ...tags],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppIcon(
                Icons.chevron_right_rounded,
                color: c.textMuted,
                size: 18,
              ),
            ],
          ),
          if (stockRatio != null) ...[
            const SizedBox(height: 10),
            SoftBar(
              value: stockRatio!,
              color: stockColor ?? c.successStrong,
              height: 5,
            ),
          ],
        ],
      ),
    );

    if (onTap != null || onLongPress != null) {
      card = Tappable(onTap: onTap, onLongPress: onLongPress, child: card);
    }
    if (id != null) card = e2eId(id!, card);

    if (onDelete == null && onEdit == null) {
      if (!enableClip) return card;
      return SoftCard(child: card);
    }

    return SoftCard(
      child: Slidable(
        key: ValueKey(name + description),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.5,
          children: [
            if (onEdit != null)
              SlidableAction(
                onPressed: (_) => onEdit!(),
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                icon: Icons.edit_outlined,
                label: context.l10n.commonEdit,
              ),
            if (onDelete != null)
              SlidableAction(
                onPressed: (_) => onDelete!(),
                backgroundColor: AppTones.coral,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: context.l10n.commonDelete,
              ),
          ],
        ),
        child: card,
      ),
    );
  }
}
