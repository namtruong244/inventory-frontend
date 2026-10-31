import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icon.dart';
import 'soft_ui.dart';

/// Design "Group Label": 11/800, letter-spacing 1, secondary text.
Widget buildSectionHeader(String title) {
  return Builder(
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: context.colors.textSecondary,
            letterSpacing: 1,
          ),
        ),
      );
    },
  );
}

Widget buildCardContainer(List<Widget> children) {
  return Builder(
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: context.colors.cardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      );
    },
  );
}

Widget buildIconBox(IconData icon, Color color, Color bg) {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(14),
    ),
    child: AppIcon(icon, color: color, size: 20),
  );
}

/// Design settings group: small caps label above a white card whose rows are
/// separated by inset dividers.
class SettingsGroup extends StatelessWidget {
  final String? label;
  final List<Widget> children;

  const SettingsGroup({super.key, this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(64, 0, 16, 0),
            child: Container(height: 1, color: c.border),
          ),
        );
      }
      rows.add(children[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          buildSectionHeader(label!),
          const SizedBox(height: 8),
        ],
        SoftCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: Column(children: rows),
          ),
        ),
      ],
    );
  }
}

/// A [SettingsRow] with a [SoftToggle]; the whole row flips the value.
class SettingsToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggleRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: icon,
      label: label,
      onTap: () => onChanged(!value),
      trailing: SoftToggle(value: value, onChanged: onChanged),
    );
  }
}

/// Design SettingsRow: 36px icon tile, 15/600 label, optional value, chevron or
/// a custom [trailing] (e.g. [SoftToggle]).
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackground;
  final Color? labelColor;
  final bool showChevron;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBackground,
    this.labelColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SoftIconTile(
            icon,
            size: 36,
            color: iconColor,
            background: iconBackground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: labelColor ?? c.textPrimary,
              ),
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                value!,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: c.textSecondary,
                ),
              ),
            ),
          ],
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          if (trailing == null && showChevron && onTap != null) ...[
            const SizedBox(width: 12),
            AppIcon(
              Icons.chevron_right_rounded,
              size: 18,
              color: c.textSecondary,
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}
