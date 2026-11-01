import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Bottom-nav glyphs copied from the design (`C7tXqo`): each is a small filled
/// "Solid" accent shape plus a 2px round "Line" outline, both in one color.
/// The nav draws them at a fixed 2px line (not [AppIcon]'s size-scaled
/// stroke) and needs its own shapes, so they live here.
enum NavGlyph {
  home(
    solid: 'M11.2 13.2h1.6a1.8 1.8 0 0 1 1.8 1.8v1.6a1.8 1.8 0 0 1-1.8 1.8h-1.6a1.8 1.8 0 0 1-1.8-1.8v-1.6a1.8 1.8 0 0 1 1.8-1.8z',
    line: 'M4 10.3c0-0.8 0.4-1.5 1-2l5.2-4c1.1-0.8 2.5-0.8 3.6 0l5.2 4c0.6 0.5 1 1.2 1 2v7.2a3.5 3.5 0 0 1-3.5 3.5h-9a3.5 3.5 0 0 1-3.5-3.5z',
  ),
  box(
    solid: 'M4.3 3.5h15.4a1.8 1.8 0 0 1 1.8 1.8v1.4a1.8 1.8 0 0 1-1.8 1.8h-15.4a1.8 1.8 0 0 1-1.8-1.8v-1.4a1.8 1.8 0 0 1 1.8-1.8z',
    line: 'M4.5 11v6.5a3 3 0 0 0 3 3h9a3 3 0 0 0 3-3v-6.5m-9.5 3.2h4',
  ),
  item(
    solid: 'M6.1 8a1.9 1.9 0 1 0 3.8 0 1.9 1.9 0 1 0-3.8 0z',
    line: 'M3.5 5.6v5c0 0.7 0.3 1.3 0.8 1.8l7.8 7.8c0.9 0.9 2.3 0.9 3.2 0l4.9-4.9c0.9-0.9 0.9-2.3 0-3.2l-7.8-7.8c-0.5-0.5-1.1-0.8-1.8-0.8h-5c-1.2 0-2.1 0.9-2.1 2.1z',
  ),
  setting(
    solid: 'M9.4 12a2.6 2.6 0 1 0 5.2 0 2.6 2.6 0 1 0-5.2 0z',
    line: 'M10.02 5.08l0.59-2.38 2.78 0 0.59 2.38 1.51 0.62 2.1-1.26 1.97 1.97-1.26 2.1 0.62 1.51 2.38 0.59 0 2.78-2.38 0.59-0.62 1.51 1.26 2.1-1.97 1.97-2.1-1.26-1.51 0.62-0.59 2.38-2.78 0-0.59-2.38-1.51-0.62-2.1 1.26-1.97-1.97 1.26-2.1-0.62-1.51-2.38-0.59 0-2.78 2.38-0.59 0.62-1.51-1.26-2.1 1.97-1.97 2.1 1.26z',
  ),
  scan(
    solid: 'M7 9.6v-1a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v1z m0 4.8h10v1a2 2 0 0 1-2 2h-6a2 2 0 0 1-2-2z',
    line: 'M3 8v-1.5a3.5 3.5 0 0 1 3.5-3.5h1.5m8 0h1.5a3.5 3.5 0 0 1 3.5 3.5v1.5m0 8v1.5a3.5 3.5 0 0 1-3.5 3.5h-1.5m-8 0h-1.5a3.5 3.5 0 0 1-3.5-3.5v-1.5m-1-4h20',
  ),
  add(solid: null, line: 'M12 5v14m-7-7h14');

  final String? solid;
  final String line;
  const NavGlyph({required this.solid, required this.line});

  String get _svg =>
      "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'>"
      "${solid == null ? '' : "<path fill-rule='evenodd' d='$solid' fill='currentColor' stroke='currentColor' stroke-width='0.45' stroke-linejoin='round'/>"}"
      "<path d='$line' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'/>"
      '</svg>';
}

class NavGlyphIcon extends StatelessWidget {
  final NavGlyph glyph;
  final Color color;
  final double size;

  const NavGlyphIcon(
    this.glyph, {
    super.key,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SvgPicture.string(
      glyph._svg,
      width: size,
      height: size,
      theme: SvgTheme(currentColor: color),
    ),
  );
}
