import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icon.dart';
import 'tappable.dart';

/// Search box used inside bottom sheets: 46px, `fill` background (the sheet is
/// already white), leading search glyph and an optional trailing action that
/// gives way to a clear button while there is text.
class SheetSearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final Widget? trailing;
  final String? initialValue;

  const SheetSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.trailing,
    this.initialValue,
  });

  @override
  State<SheetSearchField> createState() => _SheetSearchFieldState();
}

class _SheetSearchFieldState extends State<SheetSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          AppIcon(Icons.search_rounded, size: 20, color: c.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (v) {
                setState(() {});
                widget.onChanged(v);
              },
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: c.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: c.textMuted,
                ),
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            Tappable(
              semanticLabel: MaterialLocalizations.of(context)
                  .clearButtonTooltip,
              onTap: () {
                _controller.clear();
                setState(() {});
                widget.onChanged('');
              },
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
