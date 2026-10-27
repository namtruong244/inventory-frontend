import 'package:flutter/material.dart';

enum ScanGlyphType { back, more, gallery, flashOff, flashOn, scan }

/// Hand-drawn line icons for the scanner screen: round caps, uneven strokes,
/// no Material icon font.
class ScanGlyph extends StatelessWidget {
  final ScanGlyphType type;
  final Color color;
  final double size;

  const ScanGlyph(this.type, {super.key, required this.color, this.size = 24});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _GlyphPainter(type, color),
      );
}

class _GlyphPainter extends CustomPainter {
  final ScanGlyphType type;
  final Color color;

  _GlyphPainter(this.type, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 24;
    Offset p(double x, double y) => Offset(x * u, y * u);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.2 * u;
    final fill = Paint()..color = color;

    switch (type) {
      case ScanGlyphType.back:
        // Long stem with a single short barb: reads as an arrow without a full head.
        canvas.drawLine(p(3, 12), p(21, 12), stroke);
        canvas.drawLine(p(3, 12), p(8.5, 6.5), stroke);
      case ScanGlyphType.more:
        canvas.drawCircle(p(6, 12), 2 * u, fill);
        canvas.drawCircle(p(18, 12), 2 * u, fill);
      case ScanGlyphType.gallery:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(p(3.5, 4.5), p(20.5, 19.5)),
            Radius.circular(5 * u),
          ),
          stroke,
        );
        final hills = Path()
          ..moveTo(5.5 * u, 17 * u)
          ..lineTo(10 * u, 11.5 * u)
          ..lineTo(13.5 * u, 15.5 * u)
          ..lineTo(15.5 * u, 13.5 * u)
          ..lineTo(18.5 * u, 17 * u);
        canvas.drawPath(hills, stroke);
        canvas.drawCircle(p(16, 8.5), 1.3 * u, fill);
      case ScanGlyphType.flashOff:
      case ScanGlyphType.flashOn:
        final bolt = Path()
          ..moveTo(13.5 * u, 2.5 * u)
          ..lineTo(5.5 * u, 13.5 * u)
          ..lineTo(11.5 * u, 13.5 * u)
          ..lineTo(10.5 * u, 21.5 * u)
          ..lineTo(18.5 * u, 10.5 * u)
          ..lineTo(12.5 * u, 10.5 * u)
          ..close();
        canvas.drawPath(
          bolt,
          type == ScanGlyphType.flashOn ? (Paint()..color = color) : stroke,
        );
        if (type == ScanGlyphType.flashOff) {
          canvas.drawLine(p(4, 4), p(20, 20), stroke);
        }
      case ScanGlyphType.scan:
        for (final s in const [
          [1.0, 1.0],
          [-1.0, 1.0],
          [1.0, -1.0],
          [-1.0, -1.0],
        ]) {
          final cx = s[0] > 0 ? 3.5 : 20.5;
          final cy = s[1] > 0 ? 3.5 : 20.5;
          canvas.drawPath(
            Path()
              ..moveTo(cx * u, (cy + 5 * s[1]) * u)
              ..lineTo(cx * u, cy * u)
              ..lineTo((cx + 5 * s[0]) * u, cy * u),
            stroke,
          );
        }
        canvas.drawLine(p(8, 12), p(16, 12), stroke);
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.type != type || old.color != color;
}

/// Heavy rounded corner brackets drawn around the camera window.
class ScanFrameBrackets extends StatelessWidget {
  final Color color;

  const ScanFrameBrackets({super.key, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _BracketPainter(color),
        child: const SizedBox.expand(),
      );
}

class _BracketPainter extends CustomPainter {
  final Color color;

  _BracketPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const r = 36.0;
    const arm = 64.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    final w = size.width, h = size.height;
    final path = Path()
      // top-left
      ..moveTo(0, arm)
      ..lineTo(0, r)
      ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
      ..lineTo(arm, 0)
      // top-right
      ..moveTo(w - arm, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: const Radius.circular(r))
      ..lineTo(w, arm)
      // bottom-right
      ..moveTo(w, h - arm)
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: const Radius.circular(r))
      ..lineTo(w - arm, h)
      // bottom-left
      ..moveTo(arm, h)
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: const Radius.circular(r))
      ..lineTo(0, h - arm);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => old.color != color;
}
