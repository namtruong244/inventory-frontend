import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'settings_profile_sheets.dart';
import 'soft_ui.dart';
import 'tappable.dart';

/// Design Profile card: accent avatar, name + email, and an "Edit" pill.
/// The whole card opens the profile editor.
class SettingsProfileCard extends StatelessWidget {
  final InventoryProvider provider;

  const SettingsProfileCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final name = provider.userName;
    final email = provider.userEmail;
    final initials = name.trim().isEmpty
        ? 'U'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((w) => w.characters.first.toUpperCase())
              .join();
    return e2eId(
      'settings_profile',
      Tappable(
        semanticLabel: context.l10n.editProfile,
        onTap: () => showEditProfileDialog(context, provider),
        child: SoftCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: c.accent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: c.onAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: c.fill,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.l10n.commonEdit,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
