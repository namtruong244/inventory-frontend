import 'package:flutter/material.dart';

/// Custom painter for the delicate wave pattern in the dark header
class HeaderWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 7; i++) {
      final path = Path();
      final offset = i * 14.0;
      path.moveTo(size.width * 0.25, 0);
      path.cubicTo(
        size.width * 0.45,
        size.height * 0.2 + offset,
        size.width * 0.7,
        size.height * 0.8 + (offset * 0.4),
        size.width,
        size.height * 0.35 + (offset * 0.7),
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Helper wrapper that preserves the tab's state and scroll position across page transitions
class KeepAliveTab extends StatefulWidget {
  final Widget child;
  const KeepAliveTab({super.key, required this.child});

  @override
  State<KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Hosts a tab screen under its own [PrimaryScrollController] so the bottom
/// nav can scroll it back to the top when its tab is tapped again.
class ScrollToTopHost extends StatefulWidget {
  final Widget child;
  const ScrollToTopHost({super.key, required this.child});

  @override
  State<ScrollToTopHost> createState() => ScrollToTopHostState();
}

class ScrollToTopHostState extends State<ScrollToTopHost> {
  final ScrollController _scrollController = ScrollController();

  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: _scrollController,
      child: widget.child,
    );
  }
}
