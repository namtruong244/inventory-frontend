import 'package:flutter/material.dart';

import '../utils/e2e.dart';

import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/inventory_models.dart';
import 'tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';
import 'box_tree.dart';
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
    final c = context.colors;

    final tappable = Tappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
        color: c.surface,
        child: Row(
          children: [
            SoftIconTile(
              icon ?? type?.icon ?? Icons.inventory_2_outlined,
              color: type == null ? AppTones.sky : boxTypeTone(type!).fg,
              background: type == null
                  ? AppTones.skySoft
                  : boxTypeTone(type!).bg,
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
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            AppIcon(
              Icons.chevron_right_rounded,
              color: c.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );

    final card = id == null ? tappable : e2eId(id!, tappable);

    if (onDelete == null && onEdit == null) {
      if (!enableClip) return card;
      return SoftCard(radius: 20, child: card);
    }

    return SoftCard(
      radius: 20,
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
