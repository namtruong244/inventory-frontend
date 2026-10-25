import 'package:flutter/material.dart';

import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

Widget buildSectionHeader(String title) {
  return Builder(builder: (context) {
  return Padding(
    padding: const EdgeInsets.only(left: 4.0),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: context.colors.textMuted,
        letterSpacing: 0.6,
      ),
    ),
  );
});
}


Widget buildCardContainer(List<Widget> children) {
  return Builder(builder: (context) {
  return Material(
    color: context.colors.surface,
    borderRadius: BorderRadius.circular(20),
    clipBehavior: Clip.antiAlias,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(children: children),
    ),
  );
});
}


Widget buildIconBox(IconData icon, Color color, Color bg) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: color, size: 20),
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
        Icon(Icons.chevron_right_rounded, color: context.colors.textSecondary, size: 20),
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


void confirmSeedData(BuildContext context, InventoryProvider provider) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(context.l10n.seedDemoInventory, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      content: Text(
        context.l10n.thisWillUploadSampleMulti,
        style: TextStyle(fontSize: 13, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final success = await provider.seedBackendWithSampleData();
            if (context.mounted) {
              if (success) {
                AppFeedback.showSuccess(context, context.l10n.successfullySeededSampleInventoryTo);
              } else {
                AppFeedback.showError(context, context.l10n.failedToSeedSampleData(provider.errorMessage ?? ''));
              }
            }
          },
          child: Text(context.l10n.seedData),
        ),
      ],
    ),
  );
}
