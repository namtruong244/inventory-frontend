import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_icon.dart';
import 'soft_ui.dart';
import 'tappable.dart';

/// Design BottomSheet body: 40x5 handle, title row with a round close button,
/// then [child]. Top corners 28, padding 10/24/32/24, gap 16.
class SoftSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final bool showClose;

  const SoftSheet({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.showClose = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
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
        minimum: const EdgeInsets.only(bottom: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: c.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (title != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title!,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: c.textPrimary,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showClose) ...[
                      const SizedBox(width: 12),
                      Tappable(
                        semanticLabel: MaterialLocalizations.of(context)
                            .closeButtonTooltip,
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c.fill,
                            shape: BoxShape.circle,
                          ),
                          child: AppIcon(
                            Icons.close_rounded,
                            size: 18,
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens a [SoftSheet] as a modal bottom sheet (transparent route, keyboard aware).
Future<T?> showSoftSheet<T>(
  BuildContext context, {
  String? title,
  String? subtitle,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: SoftSheet(
        title: title,
        subtitle: subtitle,
        child: Builder(builder: builder),
      ),
    ),
  );
}

/// One row of an actions sheet: 40px icon tile, label (+ optional sublabel) and
/// a chevron. [danger] paints the label red and drops the chevron.
class SoftSheetActionRow extends StatelessWidget {
  final String id;
  final IconData icon;
  final Color? tone;
  final Color? toneBackground;
  final String label;
  final String? sublabel;
  final bool danger;
  final VoidCallback onTap;

  const SoftSheetActionRow({
    super.key,
    required this.id,
    required this.icon,
    required this.label,
    required this.onTap,
    this.tone,
    this.toneBackground,
    this.sublabel,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return e2eId(
      id,
      Tappable(
        semanticLabel: label,
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              SoftIconTile(
                icon,
                color: tone,
                background: toneBackground,
                size: 40,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: danger ? FontWeight.w700 : FontWeight.w600,
                        color: danger ? c.dangerStrong : c.textPrimary,
                      ),
                    ),
                    if (sublabel != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          sublabel!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!danger)
                AppIcon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: c.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
