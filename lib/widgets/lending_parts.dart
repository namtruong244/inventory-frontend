import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_icon.dart';
import 'soft_ui.dart';
import 'tappable.dart';

/// Active / History switch: fill track with a white selected pill and counts.
class LendingSegmented extends StatelessWidget {
  final int index;
  final List<({String key, String label, int count})> tabs;
  final ValueChanged<int> onChanged;

  const LendingSegmented({
    super.key,
    required this.index,
    required this.tabs,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final (i, t) in tabs.indexed) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: e2eId(
                'lending_tab_${t.key}',
                Semantics(
                  selected: i == index,
                  child: Tappable(
                    semanticLabel: '${t.label} ${t.count}',
                    onTap: () => onChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 40,
                      decoration: BoxDecoration(
                        color: i == index ? c.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExcludeSemantics(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                t.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: i == index
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: i == index
                                      ? c.textPrimary
                                      : c.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: i == index ? c.accent : c.border,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${t.count}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: i == index
                                      ? c.onAccent
                                      : c.textSecondary,
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
          ],
        ],
      ),
    );
  }
}

/// Small uppercase group label ("OVERDUE" / "ON TIME").
class LendingGroupLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const LendingGroupLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 10),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
        color: color ?? context.colors.textSecondary,
      ),
    ),
  );
}

/// One loan card: thumb + name + borrower + state chip, then a hairline and
/// the expected-return column with an optional return action.
class LoanCard extends StatelessWidget {
  final String itemName;
  final String borrower;
  final String chipLabel;
  final Color chipBackground;
  final Color chipForeground;
  final String dueLabel;
  final String dueValue;
  final bool overdue;

  /// Null hides the action (returned loans).
  final VoidCallback? onReturn;
  final String returnLabel;
  final VoidCallback? onTap;

  const LoanCard({
    super.key,
    required this.itemName,
    required this.borrower,
    required this.chipLabel,
    required this.chipBackground,
    required this.chipForeground,
    required this.dueLabel,
    required this.dueValue,
    required this.overdue,
    required this.returnLabel,
    this.onReturn,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return e2eId(
      'loan_row_$itemName',
      Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: overdue ? c.dangerSoft : Colors.transparent,
          ),
          boxShadow: c.cardShadow,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Tappable(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Row(
                children: [
                  const SoftIconTile(Icons.inventory_2_outlined, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            AppIcon(
                              Icons.person_outline_rounded,
                              size: 13,
                              color: c.textSecondary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                borrower,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: c.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SoftChip(
                    label: chipLabel,
                    background: chipBackground,
                    foreground: chipForeground,
                    dot: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: c.border),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dueLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        dueValue,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: overdue ? c.dangerStrong : c.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onReturn != null) ...[
                  const SizedBox(width: 10),
                  e2eId(
                    'loan_return_$itemName',
                    _ReturnButton(
                      label: returnLabel,
                      accent: overdue,
                      onTap: onReturn!,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReturnButton extends StatelessWidget {
  final String label;
  final bool accent;
  final VoidCallback onTap;
  const _ReturnButton({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = accent ? c.onAccent : c.textPrimary;
    return Tappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: accent ? c.accent : c.fill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(Icons.assignment_turned_in_outlined, size: 15, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
