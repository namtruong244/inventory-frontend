import 'package:flutter/material.dart';

import '../utils/e2e.dart';

import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/inventory_models.dart';
import 'tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';
import 'soft_ui.dart';

class BoxCard extends StatelessWidget {
  final String name;
  final String description;
  final String? label;
  final StorageType? type;
  final IconData? icon;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool enableClip;
  final String? id;

  const BoxCard({
    super.key,
    required this.name,
    required this.description,
    this.label,
    this.type,
    this.icon,
    required this.onTap,
    this.onDelete,
    this.onEdit,
    this.enableClip = true,
    this.id,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tappable = Tappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: context.colors.surface),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.colors.accent.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(18),
              ),
              child: AppIcon(
                icon ?? type?.icon ?? Icons.inventory_2_outlined,
                color: context.colors.textPrimary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            AppIcon(
              Icons.chevron_right_rounded,
              color: context.colors.textMuted,
              size: 24,
            ),
          ],
        ),
      ),
    );

    final card = id == null ? tappable : e2eId(id!, tappable);

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
                backgroundColor: context.colors.primary,
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
