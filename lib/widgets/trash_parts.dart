import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_icon.dart';
import 'soft_ui.dart';
import 'tappable.dart';

/// Blue info strip explaining the 30-day retention.
class TrashInfoBanner extends StatelessWidget {
  const TrashInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.infoSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AppIcon(Icons.info_outline_rounded, size: 18, color: c.infoStrong),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.trashBanner,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: c.infoStrong,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tinted action button. [danger] uses the coral tone, otherwise neutral fill.
class TrashActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool danger;
  final double height;
  final VoidCallback onTap;

  const TrashActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.danger = false,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final big = height > 40;
    final bg = danger ? c.dangerSoft : c.fill;
    final fg = danger ? c.dangerStrong : c.textPrimary;
    return Tappable(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: big ? 20 : 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(big ? 18 : 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: big ? 18 : 15, color: fg),
            SizedBox(width: big ? 8 : 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: big ? 15 : 13,
                  fontWeight: big ? FontWeight.w700 : FontWeight.w800,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card for one trashed thing: icon tile + name/sub line, Restore and
/// Delete forever buttons. [name] drives the E2E ids.
class TrashRowCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackground;

  /// Days before permanent removal; null hides the chip.
  final int? daysLeft;
  final VoidCallback onRestore;
  final VoidCallback onPurge;

  const TrashRowCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.onRestore,
    required this.onPurge,
    this.iconColor,
    this.iconBackground,
    this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final urgent = daysLeft != null && daysLeft! <= 7;
    return e2eId(
      'trash_row_$name',
      SoftCard(
        radius: 22,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SoftIconTile(
                  icon,
                  color: iconColor,
                  background: iconBackground,
                  size: 44,
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
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
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
                if (daysLeft != null) ...[
                  const SizedBox(width: 12),
                  SoftChip(
                    label: context.l10n.trashDaysLeft(daysLeft!),
                    background: urgent ? c.dangerSoft : c.fill,
                    foreground: urgent ? c.dangerStrong : c.textSecondary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: e2eId(
                    'trash_restore_$name',
                    TrashActionButton(
                      label: context.l10n.commonRestore,
                      icon: Icons.restore_rounded,
                      onTap: onRestore,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: e2eId(
                    'trash_delete_$name',
                    TrashActionButton(
                      label: context.l10n.trashDeleteForever,
                      icon: Icons.delete_outline_rounded,
                      danger: true,
                      onTap: onPurge,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
