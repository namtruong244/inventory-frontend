import 'package:flutter/material.dart';

import '../providers/inventory_provider.dart';
import 'app_feedback.dart';

Widget buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 4.0),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
        letterSpacing: 0.6,
      ),
    ),
  );
}


Widget buildCardContainer(List<Widget> children) {
  return Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    clipBehavior: Clip.antiAlias,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    ),
  );
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
  return ListTile(
    leading: buildIconBox(icon, iconColor, iconBg),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            valueText,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF18181B)),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
      ],
    ),
    onTap: onTap,
  );
}


Widget buildInfoRow(
  String label,
  String value, {
  VoidCallback? onTap,
  Widget? trailingBadge,
}) {
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
          Text(value, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
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
}


void confirmSeedData(BuildContext context, InventoryProvider provider) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Seed Demo Inventory?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      content: const Text(
        'This will upload sample multi-level rooms, cabinets, boxes, tech gear, medicine, low-stock items, and lending records directly into your backend database at http://localhost:8080.\n\nExisting items will be preserved.',
        style: TextStyle(fontSize: 13, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final success = await provider.seedBackendWithSampleData();
            if (context.mounted) {
              if (success) {
                AppFeedback.showSuccess(context, 'Successfully seeded sample inventory to backend server!');
              } else {
                AppFeedback.showError(context, 'Failed to seed sample data: ${provider.errorMessage}');
              }
            }
          },
          child: const Text('Seed Data'),
        ),
      ],
    ),
  );
}
