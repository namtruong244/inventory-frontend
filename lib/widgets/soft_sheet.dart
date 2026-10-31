import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icon.dart';
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
                        semanticLabel: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
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
