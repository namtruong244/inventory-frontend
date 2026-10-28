import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icon.dart';

/// A placeholder for an empty list with a button for the obvious next step.
class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: context.colors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, size: 52, color: c.textMuted),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: c.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: c.textSecondary, height: 1.4),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}
