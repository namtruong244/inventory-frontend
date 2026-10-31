import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_icon.dart';
import 'soft_ui.dart';
import 'tappable.dart';

/// Header row shared by the item detail cards: title (+ optional icon) and an
/// optional pill action on the right ("Move", "Add").
class ItemCardHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? pillLabel;
  final IconData? pillIcon;
  final VoidCallback? onPill;
  final String? pillId;

  const ItemCardHeader({
    super.key,
    required this.title,
    this.icon,
    this.pillLabel,
    this.pillIcon,
    this.onPill,
    this.pillId,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        if (icon != null) ...[
          AppIcon(icon!, size: 18, color: c.textPrimary),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
            ),
          ),
        ),
        if (pillLabel != null && onPill != null)
          pillId == null
              ? ItemPill(label: pillLabel!, icon: pillIcon, onTap: onPill!)
              : e2eId(
                  pillId!,
                  ItemPill(label: pillLabel!, icon: pillIcon, onTap: onPill!),
                ),
      ],
    );
  }
}

class ItemPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const ItemPill({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tappable(
      semanticLabel: label,
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: c.fill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              AppIcon(icon!, size: 14, color: c.textPrimary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White rounded card used for every section on the item detail page.
class ItemSection extends StatelessWidget {
  final Widget child;
  final Color? color;

  const ItemSection({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) =>
      SoftCard(padding: const EdgeInsets.all(18), color: color, child: child);
}

/// Category label, name and the status / overdue / quantity chips.
class ItemTitleBlock extends StatelessWidget {
  final Item item;
  final String quantityText;

  /// Days the active loan is late, null when nothing is overdue.
  final int? overdueDays;

  const ItemTitleBlock({
    super.key,
    required this.item,
    required this.quantityText,
    this.overdueDays,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppIcon(
              CategoryHelper.getCategoryIcon(item.categoryId),
              size: 14,
              color: c.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                item.categoryId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          item.name,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
            height: 1.15,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SoftChip.tone(
              item.status.displayName,
              item.status.color,
              icon: item.status.icon,
            ),
            if (item.isConsumable)
              SoftChip(
                label: l10n.commonConsumable,
                background: c.infoSoft,
                foreground: c.infoStrong,
                icon: Icons.shopping_basket_outlined,
              ),
            if (overdueDays != null)
              SoftChip(
                label: l10n.itemOverdueChip(overdueDays!),
                background: c.dangerSoft,
                foreground: c.dangerStrong,
                icon: Icons.warning_amber_rounded,
              ),
            if (item.isLowStock)
              SoftChip(
                label: l10n.settingsLowStock,
                background: c.warningSoft,
                foreground: c.warningStrong,
                icon: Icons.warning_amber_rounded,
              ),
            Text(
              '· $quantityText',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.textSecondary,
              ),
            ),
          ],
        ),
        if (item.description.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            item.description,
            style: TextStyle(fontSize: 14, height: 1.4, color: c.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// Small white tile with an icon over a label (Move / Edit / History).
class ItemActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ItemActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tappable(
      semanticLabel: label,
      onTap: onTap,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: c.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 20, color: c.textPrimary),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemStockHistoryRow extends StatelessWidget {
  final VoidCallback onTap;

  const ItemStockHistoryRow({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tappable(
      semanticLabel: context.l10n.stockHistory,
      onTap: onTap,
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const SoftIconTile(Icons.history, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.stockHistory,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                ),
              ),
            ),
            AppIcon(Icons.chevron_right_rounded, size: 20, color: c.textMuted),
          ],
        ),
      ),
    );
  }
}
