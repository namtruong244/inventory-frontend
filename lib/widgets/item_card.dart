import 'package:flutter/material.dart';
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

  const ItemCard({
    super.key,
    required this.name,
    required this.description,
    this.imageUrl,
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
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasChips = status != null || tags.isNotEmpty;

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
                  width: 68,
                  height: 68,
                  color: c.fill,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? AppImageView(imageUrlOrPath: imageUrl!, width: 68, height: 68, fit: BoxFit.cover)
                      : Center(child: AppIcon(Icons.image_outlined, color: c.textMuted, size: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.textPrimary),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, height: 1.3, color: c.textSecondary),
                      ),
                    ],
                    if (hasChips) ...[
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, runSpacing: 6, children: [?status, ...tags]),
                    ],
                  ],
                ),
              ),
              if (quantityText != null) ...[
                const SizedBox(width: 8),
                Text(
                  quantityText!,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.textPrimary),
                ),
              ],
              AppIcon(Icons.chevron_right_rounded, color: c.textMuted, size: 22),
            ],
          ),
          if (stockRatio != null) ...[
            const SizedBox(height: 10),
            SoftBar(value: stockRatio!, color: stockColor ?? c.successStrong, height: 5),
          ],
        ],
      ),
    );

    if (onTap != null || onLongPress != null) {
      card = Tappable(onTap: onTap, onLongPress: onLongPress, child: card);
    }

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
