import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icon.dart';
import 'tappable.dart';

/// Uppercase section label ("WHAT TO EXPORT" / "FORMAT").
class ExportSectionLabel extends StatelessWidget {
  final String text;

  const ExportSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
        color: context.colors.textSecondary,
      ),
    );
  }
}

/// Selectable card: selected = surface + 2px primary stroke + filled radio,
/// unselected = fill + empty radio. Optional [leading] thumbnail.
class ExportOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  const ExportOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tappable(
      semanticLabel: title,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? c.surface : c.fill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? c.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ?leading,
                const Spacer(),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? c.primary : Colors.transparent,
                    border: selected
                        ? null
                        : Border.all(color: c.border, width: 2),
                  ),
                  child: selected
                      ? AppIcon(Icons.check_rounded, size: 14, color: c.surface)
                      : null,
                ),
              ],
            ),
            SizedBox(height: leading == null ? 8 : 10),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini page thumbnail for the A4 decal format (3 x 4 grid of dots).
class A4Thumb extends StatelessWidget {
  const A4Thumb({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 40,
      height: 54,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.border),
      ),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        children: List.generate(
          12,
          (_) => DecoratedBox(
            decoration: BoxDecoration(
              color: c.fill,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mini label thumbnail for the thermal format.
class ThermalThumb extends StatelessWidget {
  const ThermalThumb({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 54,
      height: 34,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            decoration: BoxDecoration(
              color: c.fill,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(vertical: 1.5),
                    decoration: BoxDecoration(
                      color: c.fill,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Indeterminate "Generating PDF..." status card.
class ExportProgressCard extends StatelessWidget {
  final String label;

  const ExportProgressCard({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.infoSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: c.infoStrong,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.infoStrong,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              minHeight: 6,
              color: c.infoStrong,
              backgroundColor: c.surface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
