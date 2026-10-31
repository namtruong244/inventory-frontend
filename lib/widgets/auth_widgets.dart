import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_icon.dart';
import 'google_logo.dart';
import 'soft_ui.dart';
import 'tappable.dart';

/// Lime rounded square with the box glyph (splash 96, sign in 56).
class AppMark extends StatelessWidget {
  final double size;
  const AppMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final big = size > 80;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.accent,
        borderRadius: BorderRadius.circular(size * 0.34),
        boxShadow: big
            ? [
                BoxShadow(
                  color: AppTones.matcha.withValues(alpha: 0.25),
                  offset: const Offset(0, 16),
                  blurRadius: 32,
                ),
              ]
            : null,
      ),
      child: Center(
        child: AppIcon(
          Icons.view_in_ar_rounded,
          size: size * 0.48,
          color: c.onAccent,
        ),
      ),
    );
  }
}

/// Decorative cluster behind the splash mark: the mark with four tilted status chips.
class SplashMarkCluster extends StatelessWidget {
  const SplashMarkCluster({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget chip(
      double? left,
      double? right,
      double top,
      double deg,
      String label,
      Color bg,
      Color fg,
    ) => Positioned(
      left: left,
      right: right,
      top: top,
      child: Transform.rotate(
        angle: deg * 3.1415926 / 180,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: context.colors.cardShadow,
          ),
          child: SoftChip(
            label: label,
            background: bg,
            foreground: fg,
            icon: Icons.view_in_ar_outlined,
          ),
        ),
      ),
    );
    return SizedBox(
      width: 240,
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(left: 72, top: 52, child: AppMark(size: 96)),
          chip(
            0,
            null,
            14,
            8,
            l.statusStored,
            AppTones.matchaSoft,
            AppTones.matcha,
          ),
          chip(
            null,
            32,
            10,
            -6,
            l.statusLent,
            AppTones.amberSoft,
            AppTones.amber,
          ),
          chip(
            2,
            null,
            160,
            -4,
            l.expiresInShort(3),
            AppTones.amberSoft,
            AppTones.amber,
          ),
          chip(null, 6, 159, 6, l.statusInUse, AppTones.skySoft, AppTones.sky),
        ],
      ),
    );
  }
}

/// Two-segment pill switching between sign in and create account.
class AuthModeSwitch extends StatelessWidget {
  final bool registerMode;
  final ValueChanged<bool> onChanged;
  const AuthModeSwitch({
    super.key,
    required this.registerMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget seg(String id, String label, bool selected, bool register) =>
        Expanded(
          child: e2eId(
            id,
            Tappable(
              onTap: () => onChanged(register),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 40,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: selected ? c.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected ? c.cardShadow : null,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? c.textPrimary : c.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          seg(
            'login_mode_signin',
            context.l10n.loginTabSignIn,
            !registerMode,
            false,
          ),
          const SizedBox(width: 4),
          seg(
            'login_mode_register',
            context.l10n.loginTabCreate,
            registerMode,
            true,
          ),
        ],
      ),
    );
  }
}

/// White "Continue with Google" button.
class GoogleAuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const GoogleAuthButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return e2eId(
      'login_google',
      Opacity(
        opacity: onPressed == null ? 0.5 : 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: c.cardShadow,
          ),
          child: Material(
            color: c.surface,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const GoogleLogoWidget(size: 20),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          context.l10n.continueWithGoogle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
