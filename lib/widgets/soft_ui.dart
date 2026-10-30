import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icon.dart';

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
        borderRadius: BorderRadius.circular(10),
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

/// Selectable filter pill: lime when active, white otherwise.
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? c.accent : c.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected ? null : c.cardShadow,
          ),
          child: ExcludeSemantics(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? c.onAccent : c.textSecondary,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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

/// Icon in a soft rounded tile (list leading, settings rows).
class SoftIconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? background;
  final double size;

  const SoftIconTile(
    this.icon, {
    super.key,
    required this.color,
    this.background,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.36),
      ),
      child: AppIcon(icon, color: color, size: size * 0.5),
    );
  }
}

/// White pill search box that floats on the page background.
class SoftSearchField extends StatefulWidget {
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SoftSearchField({
    super.key,
    required this.hint,
    required this.value,
    required this.onChanged,
    required this.onClear,
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
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: c.cardShadow,
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        decoration: InputDecoration(
          hintText: widget.hint,
          filled: false,
          prefixIcon: AppIcon(
            Icons.search_rounded,
            size: 22,
            color: c.textMuted,
          ),
          suffixIcon: widget.value.isNotEmpty
              ? IconButton(
                  tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
                  icon: const AppIcon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _controller.clear();
                    widget.onClear();
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
