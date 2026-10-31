import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';

/// Camera area of the design: dark rounded viewport with lime corner brackets,
/// a scan line and a hint pill. Shows an on-design message instead of the feed
/// when the camera is denied or missing (e.g. iOS simulator).
class ScanViewport extends StatelessWidget {
  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;
  final bool processing;
  final String? hint;
  final double radius;

  const ScanViewport({
    super.key,
    required this.controller,
    required this.onDetect,
    this.processing = false,
    this.hint,
    this.radius = 32,
  });

  /// The camera area is dark in both themes, like a real feed.
  static const Color cameraBackground = Color(0xFF16181C);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: cameraBackground,
        child: LayoutBuilder(
          builder: (context, box) {
            final h = box.maxHeight.isFinite ? box.maxHeight : 260.0;
            final w = box.maxWidth;
            final inset = (w * 0.164).clamp(28.0, 56.0);
            final vInset = (h * 0.21).clamp(60.0, 85.0);
            return Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: onDetect,
                  errorBuilder: (context, error) => _CameraError(error: error),
                ),
                if (processing)
                  const ColoredBox(color: Colors.black45)
                else
                  const SizedBox.shrink(),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: inset,
                      vertical: vInset,
                    ),
                    child: IgnorePointer(
                      child: CustomPaint(painter: _CornersPainter(c.accent)),
                    ),
                  ),
                ),
                Positioned(
                  left: inset + 14,
                  right: inset + 14,
                  top: h * 0.62,
                  child: IgnorePointer(child: _ScanLine(color: c.accent)),
                ),
                if (processing)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 20,
                  child: Center(
                    child: _HintPill(text: hint ?? context.l10n.scanPointHint),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HintPill extends StatelessWidget {
  final String text;
  const _HintPill({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xB318181B),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppIcon(
          Icons.qr_code_scanner_rounded,
          size: 14,
          color: Colors.white,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ScanLine extends StatelessWidget {
  final Color color;
  const _ScanLine({required this.color});

  @override
  Widget build(BuildContext context) => Container(
    height: 3,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(2),
      boxShadow: [BoxShadow(color: color, blurRadius: 12)],
    ),
  );
}

class _CornersPainter extends CustomPainter {
  final Color color;
  _CornersPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const arm = 36.0, r = 14.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(0, arm)
      ..lineTo(0, r)
      ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
      ..lineTo(arm, 0)
      ..moveTo(w - arm, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: const Radius.circular(r))
      ..lineTo(w, arm)
      ..moveTo(w, h - arm)
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: const Radius.circular(r))
      ..lineTo(w - arm, h)
      ..moveTo(arm, h)
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: const Radius.circular(r))
      ..lineTo(0, h - arm);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornersPainter old) => old.color != color;
}

class _CameraError extends StatelessWidget {
  final MobileScannerException error;
  const _CameraError({required this.error});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Align(
        alignment: const Alignment(0, -0.4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0x1FFFFFFF),
                shape: BoxShape.circle,
              ),
              child: const AppIcon(
                Icons.camera_alt_outlined,
                size: 26,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              denied ? l10n.scanCameraDenied : l10n.scanCameraUnavailable,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              denied
                  ? l10n.scanCameraDeniedHint
                  : l10n.scanCameraUnavailableHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xB3FFFFFF),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
