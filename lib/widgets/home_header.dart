import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_icon.dart';
import 'tappable.dart';

/// Up to two initials of [name] ("Minh Duong" -> "MD"), "U" when empty.
String userInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return 'U';
  final letters = parts.take(2).map((p) => p.characters.first.toUpperCase());
  return letters.join();
}

/// Lime avatar with the user's initials (48, design `Avatar`).
class HomeAvatar extends StatelessWidget {
  final String name;

  const HomeAvatar({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
      child: Text(
        userInitials(name),
        style: TextStyle(
          color: c.onAccent,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Greeting row: avatar, "Hey Minh 👋" + tagline, and the alerts bell with a badge.
/// With [setup] (brand-new account) it greets with "Welcome" and has no bell.
class HomeHeader extends StatelessWidget {
  final VoidCallback onAlerts;
  final bool setup;

  const HomeHeader({super.key, required this.onAlerts, this.setup = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final p = context.watch<InventoryProvider>();
    final name = p.userName.trim();
    final first = name.isEmpty ? l10n.heyFallbackName : name.split(' ').first;
    final alertCount = p.totalAlertCount;
    return Row(
      children: [
        HomeAvatar(name: name),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                setup ? l10n.homeWelcomeName(first) : l10n.heyName(first),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                setup ? l10n.homeSetupTagline : l10n.trackManageYourInventory,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (!setup) ...[
          const SizedBox(width: 12),
          e2eId(
            'home_alerts_bell',
            Tooltip(
              message: l10n.commonAlerts,
              child: Tappable(
                semanticLabel: l10n.commonAlerts,
                onTap: onAlerts,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: c.surface,
                        shape: BoxShape.circle,
                        boxShadow: c.cardShadow,
                      ),
                      child: AppIcon(
                        Icons.notifications_none_rounded,
                        color: c.textPrimary,
                        size: 22,
                      ),
                    ),
                    if (alertCount > 0)
                      Positioned(
                        top: 6,
                        right: 3,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: AppTones.coral,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: c.surface, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              alertCount > 99 ? '99+' : '$alertCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Tappable search bar that opens the search screen.
class HomeSearchBar extends StatelessWidget {
  final VoidCallback onSearch;

  const HomeSearchBar({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return e2eId(
      'home_search',
      Tappable(
        semanticLabel: l10n.commonSearch,
        onTap: onSearch,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: c.cardShadow,
          ),
          child: Row(
            children: [
              AppIcon(Icons.search_rounded, size: 20, color: c.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.homeSearchHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
