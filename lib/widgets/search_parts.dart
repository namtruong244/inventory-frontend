import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import '../utils/text_normalize.dart';
import 'app_icon.dart';
import 'soft_ui.dart';
import 'tappable.dart';

/// Text with the part matching [normalizedQuery] (ignoring case and Vietnamese
/// diacritics) in the accent-strong colour, as in the design's result rows.
class SearchHighlightText extends StatelessWidget {
  final String text;
  final String normalizedQuery;

  const SearchHighlightText(
    this.text, {
    super.key,
    required this.normalizedQuery,
  });

  /// Rune range of [text] matching the query, or null.
  (int, int)? _match() {
    if (normalizedQuery.isEmpty) return null;
    final runes = text.runes.toList();
    final buffer = StringBuffer();
    final origin = <int>[]; // normalized code unit -> rune index in [text]
    for (var i = 0; i < runes.length; i++) {
      final n = normalizeVi(String.fromCharCode(runes[i]));
      buffer.write(n);
      for (var k = 0; k < n.length; k++) {
        origin.add(i);
      }
    }
    final at = buffer.toString().indexOf(normalizedQuery);
    if (at == -1 || at + normalizedQuery.length > origin.length) return null;
    return (origin[at], origin[at + normalizedQuery.length - 1] + 1);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: c.textPrimary,
    );
    final m = _match();
    if (m == null) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: base,
      );
    }
    final runes = text.runes.toList();
    String part(int a, int b) => String.fromCharCodes(runes.sublist(a, b));
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: part(0, m.$1)),
          TextSpan(
            text: part(m.$1, m.$2),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: c.accentStrong,
            ),
          ),
          TextSpan(text: part(m.$2, runes.length)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Top row of the search screen: round back button + lime-outlined field.
class SearchInputRow extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasText;
  final TextEditingController controller;

  const SearchInputRow({
    super.key,
    required this.hint,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.hasText,
  });

  @override
  State<SearchInputRow> createState() => _SearchInputRowState();
}

class _SearchInputRowState extends State<SearchInputRow> {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        e2eId(
          'search_back',
          SoftCircleButton(
            icon: Icons.arrow_back_rounded,
            tooltip: context.l10n.searchBackTooltip,
            onTap: () => Navigator.maybePop(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 56,
            padding: const EdgeInsets.fromLTRB(16, 0, 10, 0),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.accent, width: 2),
              boxShadow: c.cardShadow,
            ),
            child: Row(
              children: [
                AppIcon(Icons.search_rounded, size: 20, color: c.textPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: e2eId(
                    'search_input',
                    TextField(
                      controller: widget.controller,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: widget.onChanged,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: c.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: TextStyle(
                          color: c.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                if (widget.hasText)
                  e2eId(
                    'search_clear',
                    Tappable(
                      semanticLabel: MaterialLocalizations.of(context)
                          .clearButtonTooltip,
                      onTap: widget.onClear,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: c.fill,
                          shape: BoxShape.circle,
                        ),
                        child: AppIcon(
                          Icons.close_rounded,
                          size: 14,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Horizontal filter chips (`search_filter_<key>`).
class SearchFilterBar extends StatelessWidget {
  final List<(String, String)> filters; // (key, label)
  final String selected;
  final ValueChanged<String> onSelected;

  const SearchFilterBar({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          for (final f in filters) ...[
            e2eId(
              'search_filter_${f.$1}',
              SoftFilterChip(
                label: f.$2,
                selected: selected == f.$1,
                onTap: () => onSelected(f.$1),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/// "Matching without accents: “cáp sạc”, “cap sac”" hint line.
class SearchAccentHint extends StatelessWidget {
  final String variants;
  const SearchAccentHint({super.key, required this.variants});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        AppIcon(Icons.auto_awesome_outlined, size: 14, color: c.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            context.l10n.searchAccentHint(variants),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: c.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Group header ("ITEMS" ... "3 results") + one rounded card holding [rows]
/// separated by hairline dividers.
class SearchResultGroup extends StatelessWidget {
  final String title;
  final int count;
  final List<Widget> rows;

  const SearchResultGroup({
    super.key,
    required this.title,
    required this.count,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final muted = TextStyle(color: c.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: muted.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.searchResultCount(count),
              style: muted.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SoftCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 70, right: 16),
                      child: Container(height: 1, color: c.border),
                    ),
                  rows[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One result row: tile, highlighted name, sub line, optional badge, chevron.
class SearchResultRow extends StatelessWidget {
  final String id;
  final Widget tile;
  final String name;
  final String normalizedQuery;
  final String sub;
  final String? badge;
  final VoidCallback onTap;

  const SearchResultRow({
    super.key,
    required this.id,
    required this.tile,
    required this.name,
    required this.normalizedQuery,
    required this.sub,
    required this.onTap,
    this.badge,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              tile,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchHighlightText(name, normalizedQuery: normalizedQuery),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: c.fill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
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
