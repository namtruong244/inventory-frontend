import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_icon.dart';
import 'soft_ui.dart';
import 'tappable.dart';

/// Colour pair of an alert group: tinted background + strong foreground.
class AlertTone {
  final Color soft;
  final Color strong;
  const AlertTone(this.soft, this.strong);

  static AlertTone danger(AppColors c) =>
      AlertTone(c.dangerSoft, c.dangerStrong);
  static AlertTone warning(AppColors c) =>
      AlertTone(c.warningSoft, c.warningStrong);
  static AlertTone info(AppColors c) => AlertTone(c.infoSoft, c.infoStrong);
}

/// One of the four summary tiles ("2 Expired"); tapping filters the list.
class AlertSummaryTile extends StatelessWidget {
  final String filterKey;
  final int count;
  final String label;
  final AlertTone tone;
  final bool selected;
  final VoidCallback onTap;

  const AlertSummaryTile({
    super.key,
    required this.filterKey,
    required this.count,
    required this.label,
    required this.tone,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return e2eId(
      'alerts_filter_$filterKey',
      Semantics(
        selected: selected,
        child: Tappable(
          semanticLabel: '$count $label',
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: tone.soft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? tone.strong : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: ExcludeSemantics(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: tone.strong,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: tone.strong,
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

/// White card for one alert group: icon tile + title + count pill, then rows
/// separated by hairlines.
class AlertSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final AlertTone tone;
  final List<Widget> rows;

  const AlertSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    required this.tone,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SoftIconTile(
                  icon,
                  size: 30,
                  color: tone.strong,
                  background: tone.soft,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: tone.soft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: tone.strong,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Container(height: 1, color: c.border),
            rows[i],
          ],
        ],
      ),
    );
  }
}

/// One alert row: neutral thumb, name, coloured sub line, optional progress
/// bar, chevron. [id] is the E2E id (`alert_row_<item name>`).
class AlertRow extends StatelessWidget {
  final String id;
  final IconData icon;
  final String name;
  final String sub;
  final Color subColor;
  final double? progress;
  final VoidCallback onTap;

  const AlertRow({
    super.key,
    required this.id,
    required this.icon,
    required this.name,
    required this.sub,
    required this.subColor,
    required this.onTap,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return e2eId(
      id,
      Tappable(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SoftIconTile(icon, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: subColor,
                      ),
                    ),
                    if (progress != null) ...[
                      const SizedBox(height: 4),
                      SoftBar(value: progress!, color: subColor, height: 6),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppIcon(
                Icons.chevron_right_rounded,
                size: 16,
                color: c.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
