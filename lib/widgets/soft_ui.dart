import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icon.dart';
import 'tappable.dart';

/// White 24px card with the soft drop shadow; the shadow sits outside the clip
/// so rounded children (Slidable, InkWell) never cut it off.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;

  const SoftCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: c.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: padding == null
            ? child
            : Padding(padding: padding!, child: child),
      ),
    );
  }
}

/// Small pastel pill: a status or a tag ("Low stock", "Expires in 3d").
class SoftChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final bool dot;

  const SoftChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.dot = false,
  });

  /// Tinted chip derived from a single status color.
  factory SoftChip.tone(
    String label,
    Color tone, {
    IconData? icon,
    bool dot = false,
  }) => SoftChip(
    label: label,
    background: tone.withValues(alpha: 0.14),
    foreground: tone,
    icon: icon,
    dot: dot,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ] else if (icon != null) ...[
            AppIcon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Selectable filter pill: dark primary when active, white card otherwise.
class SoftFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SoftFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? c.primary : c.surface,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected ? null : c.cardShadow,
          ),
          child: ExcludeSemantics(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : c.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin rounded progress bar.
class SoftBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const SoftBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: context.colors.fill,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

/// Circular completion ring with an optional centre label.
class SoftRing extends StatelessWidget {
  final double value;
  final Color color;
  final double size;
  final double stroke;
  final Widget? center;

  const SoftRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 56,
    this.stroke = 7,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value.clamp(0.0, 1.0),
          color,
          context.colors.fill,
          stroke,
        ),
        child: center == null ? null : Center(child: center),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color track;
  final double stroke;

  _RingPainter(this.value, this.color, this.track, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    if (value > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.color != color ||
      old.track != track ||
      old.stroke != stroke;
}

/// Icon in a soft rounded tile (list leading, settings rows). Without [color]
/// and [background] it is the neutral `fill` tile with a primary-text glyph.
class SoftIconTile extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final Color? background;
  final double size;

  const SoftIconTile(
    this.icon, {
    super.key,
    this.color,
    this.background,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = color ?? c.textPrimary;
    final bg =
        background ?? (color == null ? c.fill : fg.withValues(alpha: 0.14));
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular((size * 0.32).roundToDouble()),
      ),
      child: AppIcon(icon, color: fg, size: size * 0.5),
    );
  }
}

/// White pill search box that floats on the page background.
class SoftSearchField extends StatefulWidget {
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  /// Optional icon/button shown at the end while the field is empty.
  final Widget? trailing;

  const SoftSearchField({
    super.key,
    required this.hint,
    required this.value,
    required this.onChanged,
    required this.onClear,
    this.trailing,
  });

  @override
  State<SoftSearchField> createState() => _SoftSearchFieldState();
}

class _SoftSearchFieldState extends State<SoftSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(SoftSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Parent reset the query (e.g. clear): keep the visible text in step.
    // Compare trimmed since parents store the trimmed query.
    if (widget.value != _controller.text.trim()) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const none = InputBorder.none;
    return Container(
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
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: c.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: c.textMuted,
                ),
                isCollapsed: true,
                filled: false,
                border: none,
                enabledBorder: none,
                focusedBorder: none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (widget.value.isNotEmpty)
            Tappable(
              semanticLabel: MaterialLocalizations.of(context)
                  .clearButtonTooltip,
              onTap: () {
                _controller.clear();
                widget.onClear();
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: AppIcon(
                  Icons.close_rounded,
                  size: 20,
                  color: c.textSecondary,
                ),
              ),
            )
          else if (widget.trailing != null) ...[
            const SizedBox(width: 10),
            widget.trailing!,
          ],
        ],
      ),
    );
  }
}

enum SoftButtonStyle { accent, secondary, danger, primary }

/// The design's Button: 52px tall, radius 18, 15/700 label, optional 18px icon.
class SoftButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final SoftButtonStyle style;

  /// Fill the available width (otherwise hugs the content).
  final bool expand;

  /// Shows a spinner instead of the label (the caller also nulls [onPressed]).
  final bool loading;

  const SoftButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = SoftButtonStyle.accent,
    this.expand = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (style) {
      SoftButtonStyle.accent => (c.accent, c.onAccent),
      SoftButtonStyle.secondary => (c.fill, c.textPrimary),
      SoftButtonStyle.danger => (c.dangerStrong, c.surface),
      SoftButtonStyle.primary => (c.primary, Colors.white),
    };
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: loading
                    ? [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(fg),
                          ),
                        ),
                      ]
                    : [
                        if (icon != null) ...[
                          AppIcon(icon, size: 18, color: fg),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: fg,
                            ),
                          ),
                        ),
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 48x28 switch: lime track when on, `trackOff` when off, white 22px knob.
class SoftToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SoftToggle({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      toggled: value,
      enabled: onChanged != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 48,
          height: 28,
          padding: const EdgeInsets.all(3),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: value ? c.accent : c.trackOff,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Section title (18/700) with an optional "View all >" link on the right.
class SoftSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SoftSectionHeader(
    this.title, {
    super.key,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
        ),
        if (actionLabel != null)
          Tappable(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  AppIcon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: c.textSecondary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 44px white circular icon button used in [SoftTopAppBar].
class SoftCircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const SoftCircleButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Tappable(
        semanticLabel: tooltip,
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: c.surface,
            shape: BoxShape.circle,
            boxShadow: c.cardShadow,
          ),
          child: AppIcon(icon, size: 20, color: c.textPrimary),
        ),
      ),
    );
  }
}

/// Design TopAppBar: round back button, 17/800 title, round action buttons.
/// Use as `Scaffold.appBar`.
class SoftTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  /// Null hides the back button when the route cannot pop.
  final VoidCallback? onBack;
  final List<Widget> actions;
  final bool showBack;

  const SoftTopAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions = const [],
    this.showBack = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
          child: Row(
            children: [
              if (showBack) ...[
                SoftCircleButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                  ),
                ),
              ),
              for (final a in actions) ...[const SizedBox(width: 12), a],
            ],
          ),
        ),
      ),
    );
  }
}
