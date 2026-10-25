import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'app_image_view.dart';
import 'tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

class ItemCard extends StatelessWidget {
  final String name;
  final String description;
  final String? imageUrl;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final bool enableClip;

  const ItemCard({
    super.key,
    required this.name,
    required this.description,
    this.imageUrl,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.enableClip = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget card = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 76,
              height: 76,
              color: context.colors.fill,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? AppImageView(
                      imageUrlOrPath: imageUrl!,
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: context.colors.textMuted,
                        size: 30,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      card = Tappable(
        onTap: onTap,
        child: card,
      );
    }

    if (onDelete == null && onEdit == null) {
      if (!enableClip) return card;
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: card,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
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
                backgroundColor: Colors.red.shade400,
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
