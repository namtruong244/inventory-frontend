import 'package:flutter/material.dart';

/// Pixel-perfect vector representation of the official 4-color Google G icon
class GoogleLogoWidget extends StatelessWidget {
  final double size;

  const GoogleLogoWidget({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 48.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Official Google Brand Colors
    const redColor = Color(0xFFEA4335);
    const blueColor = Color(0xFF4285F4);
    const yellowColor = Color(0xFFFBBC05);
    const greenColor = Color(0xFF34A853);

    // 1. Red Top Arch
    final redPath = Path()
      ..moveTo(24.0, 9.5)
      ..cubicTo(27.54, 9.5, 30.71, 10.72, 33.21, 13.1)
      ..lineTo(40.06, 6.25)
      ..cubicTo(35.9, 2.38, 30.47, 0.0, 24.0, 0.0)
      ..cubicTo(14.62, 0.0, 6.51, 5.38, 2.56, 13.22)
      ..lineTo(10.54, 19.41)
      ..cubicTo(12.43, 13.72, 17.74, 9.5, 24.0, 9.5)
      ..close();

    // 2. Blue Crossbar & Right Curve
    final bluePath = Path()
      ..moveTo(46.98, 24.55)
      ..cubicTo(46.98, 22.98, 46.83, 21.46, 46.60, 20.0)
      ..lineTo(24.0, 20.0)
      ..lineTo(24.0, 29.02)
      ..lineTo(36.94, 29.02)
      ..cubicTo(36.36, 31.98, 34.68, 34.50, 32.16, 36.20)
      ..lineTo(39.89, 42.20)
      ..cubicTo(44.40, 38.02, 46.98, 31.84, 46.98, 24.55)
      ..close();

    // 3. Yellow Left Arch
    final yellowPath = Path()
      ..moveTo(10.53, 28.59)
      ..cubicTo(10.05, 27.14, 9.77, 25.60, 9.77, 24.0)
      ..cubicTo(9.77, 22.40, 10.04, 20.86, 10.53, 19.41)
      ..lineTo(2.55, 13.22)
      ..cubicTo(0.92, 16.46, 0.0, 20.12, 0.0, 24.0)
      ..cubicTo(0.0, 27.88, 0.92, 31.54, 2.56, 34.78)
      ..lineTo(10.53, 28.59)
      ..close();

    // 4. Green Bottom Arch
    final greenPath = Path()
      ..moveTo(24.0, 48.0)
      ..cubicTo(30.48, 48.0, 35.93, 45.87, 39.89, 42.19)
      ..lineTo(32.16, 36.19)
      ..cubicTo(30.01, 37.64, 27.24, 38.49, 24.0, 38.49)
      ..cubicTo(17.74, 38.49, 12.43, 34.27, 10.53, 28.58)
      ..lineTo(2.55, 34.77)
      ..cubicTo(6.51, 42.62, 14.62, 48.0, 24.0, 48.0)
      ..close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(redPath, paint..color = redColor);
    canvas.drawPath(bluePath, paint..color = blueColor);
    canvas.drawPath(yellowPath, paint..color = yellowColor);
    canvas.drawPath(greenPath, paint..color = greenColor);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
