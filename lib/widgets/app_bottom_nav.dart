import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'nav_glyphs.dart';
import 'tappable.dart';

/// The design's BottomNav: a white floating bar with four tabs (the active one
/// is a dark pill with its label), a dark scan button beside it and, on the
/// Box and Item tabs, a lime quick-add button above the scan button.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onScan;

  /// Quick-add button: shown only when [addLabel] is non-null.
  final String? addLabel;
  final VoidCallback? onAdd;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.onScan,
    this.addLabel,
    this.onAdd,
  });

  static const double _barHeight = 64;
  static const double _scanSize = 64;
  static const double _sideInset = 16;

  /// The design leaves 24 below the bar for the home indicator; on phones with
  /// a taller inset (34) that matches the design exactly.
  static double bottomInset(BuildContext context) {
    final inset = MediaQuery.of(context).padding.bottom;
    return inset - 10 > 24 ? inset - 10 : 24;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final bottom = bottomInset(context);
    final tabs = [
      (NavGlyph.home, l10n.commonHome, 'nav_home'),
      (NavGlyph.box, l10n.commonBox, 'nav_box'),
      (NavGlyph.item, l10n.commonItem, 'nav_item'),
      (NavGlyph.setting, l10n.commonSetting, 'nav_setting'),
    ];
    final showAdd = addLabel != null;
    return Stack(
      children: [
        Positioned(
          right: _sideInset,
          bottom: bottom + _scanSize + 16,
          child: IgnorePointer(
            ignoring: !showAdd,
            child: AnimatedScale(
              scale: showAdd ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: _AddButton(label: addLabel ?? '', onTap: onAdd),
            ),
          ),
        ),
        Positioned(
          left: _sideInset,
          right: _sideInset,
          bottom: bottom,
          child: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    // Narrow phones / long labels: tighten the tab padding so
                    // the active label still fits.
                    final compact = box.maxWidth < 280;
                    return Container(
                      height: _barHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: c.cardShadow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var i = 0; i < tabs.length; i++)
                            Flexible(
                              flex: i == currentIndex ? 1 : 0,
                              child: _NavTab(
                                id: tabs[i].$3,
                                icon: tabs[i].$1,
                                label: tabs[i].$2,
                                selected: i == currentIndex,
                                compact: compact,
                                onTap: () => onSelect(i),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              e2eId(
                'nav_scan',
                Tooltip(
                  message: l10n.scanQrCode,
                  child: Tappable(
                    semanticLabel: l10n.scanQrCode,
                    onTap: onScan,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: _scanSize,
                      height: _scanSize,
                      decoration: BoxDecoration(
                        color: c.primary,
                        shape: BoxShape.circle,
                        boxShadow: c.cardShadow,
                      ),
                      child: Center(
                        child: NavGlyphIcon(
                          NavGlyph.scan,
                          color: c.accent,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavTab extends StatelessWidget {
  final String id;
  final NavGlyph icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _NavTab({
    required this.id,
    required this.icon,
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hPad = selected ? (compact ? 12.0 : 18.0) : (compact ? 8.0 : 12.0);
    return e2eId(
      id,
      Tooltip(
        message: label,
        child: Tappable(
          semanticLabel: label,
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: hPad),
            decoration: BoxDecoration(
              color: selected ? c.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NavGlyphIcon(
                  icon,
                  size: 22,
                  color: selected ? Colors.white : c.textSecondary,
                ),
                if (selected) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _AddButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return e2eId(
      'nav_add',
      Tooltip(
        message: label,
        child: Tappable(
          semanticLabel: label,
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: c.accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: c.accentStrong.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: NavGlyphIcon(NavGlyph.add, color: c.onAccent, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}
