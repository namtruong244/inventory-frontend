import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icon.dart';

Widget buildSectionHeader(String title) {
  return Builder(builder: (context) {
  return Padding(
    padding: const EdgeInsets.only(left: 4.0),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: context.colors.textSecondary,
        letterSpacing: 0.2,
      ),
    ),
  );
});
}


Widget buildCardContainer(List<Widget> children) {
  return Builder(builder: (context) {
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
  });
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


Widget buildPreferenceTile({
  required IconData icon,
  required Color iconColor,
  required Color iconBg,
  required String title,
  required String subtitle,
  required String valueText,
  required VoidCallback onTap,
}) {
  return Builder(builder: (context) {
  return ListTile(
    leading: buildIconBox(icon, iconColor, iconBg),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: context.colors.fill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            valueText,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.colors.textPrimary),
          ),
        ),
        const SizedBox(width: 4),
        AppIcon(Icons.chevron_right_rounded, color: context.colors.textSecondary, size: 20),
      ],
    ),
    onTap: onTap,
  );
});
}


Widget buildInfoRow(
  String label,
  String value, {
  VoidCallback? onTap,
  Widget? trailingBadge,
}) {
  return Builder(builder: (context) {
  final rowContent = Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingBadge != null) ...[
            trailingBadge,
            const SizedBox(width: 6),
          ],
          Text(value, style: TextStyle(color: context.colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    ],
  );

  if (onTap != null) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: rowContent,
      ),
    );
  }
  return rowContent;
});
}
