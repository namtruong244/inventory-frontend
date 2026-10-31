import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_icon.dart';
import 'soft_ui.dart';

/// Result card docked at the bottom of the scanner (design "Result Sheet"):
/// a found box/item or an unknown code, with "Scan again" + a primary action.
class ScanResultSheet extends StatelessWidget {
  final IconData icon;
  final String chipLabel;
  final IconData chipIcon;
  final bool found;
  final String title;
  final bool monoTitle;
  final String subtitle;
  final String primaryLabel;
  final IconData primaryIcon;
  final String primaryId;
  final VoidCallback onPrimary;
  final VoidCallback onScanAgain;

  const ScanResultSheet({
    super.key,
    required this.icon,
    required this.chipLabel,
    required this.chipIcon,
    required this.found,
    required this.title,
    this.monoTitle = false,
    required this.subtitle,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.primaryId,
    required this.onPrimary,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: c.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTones.amberSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: AppIcon(icon, size: 24, color: AppTones.amber),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SoftChip(
                            label: chipLabel,
                            icon: chipIcon,
                            background: found
                                ? AppTones.matchaSoft
                                : AppTones.amberSoft,
                            foreground: found
                                ? AppTones.matcha
                                : AppTones.amber,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            fontFamily: monoTitle ? 'Menlo' : null,
                            fontFamilyFallback: monoTitle
                                ? const ['Roboto Mono', 'monospace']
                                : null,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: e2eId(
                      'scan_again',
                      SoftButton(
                        label: l10n.scanAgain,
                        icon: Icons.refresh_rounded,
                        style: SoftButtonStyle.secondary,
                        expand: true,
                        onPressed: onScanAgain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: e2eId(
                      primaryId,
                      SoftButton(
                        label: primaryLabel,
                        icon: primaryIcon,
                        expand: true,
                        onPressed: onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
