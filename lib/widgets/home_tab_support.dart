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

/// Hosts a tab screen under its own [PrimaryScrollController] so the bottom
/// nav can scroll it back to the top when its tab is tapped again, and asks
/// the screen to clear its search and filters (see [resetSignalOf]).
class ScrollToTopHost extends StatefulWidget {
  final Widget child;
  const ScrollToTopHost({super.key, required this.child});

  /// Fires when the hosted tab should drop its search query and filters.
  static Listenable? resetSignalOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ResetScope>()?.signal;

  @override
  State<ScrollToTopHost> createState() => ScrollToTopHostState();
}

class ScrollToTopHostState extends State<ScrollToTopHost> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _resets = ValueNotifier(0);

  /// Animates back to the top; false when the tab is already there.
  bool scrollToTop() => animateToTop(_scrollController);

  /// Puts the tab at the top with its search and filters cleared, without
  /// animating (it runs while the tab is hidden).
  void reset() {
    for (final p in _scrollController.positions) {
      p.jumpTo(p.minScrollExtent);
    }
    resetFilters();
  }

  void resetFilters() => _resets.value++;

  @override
  void dispose() {
    _scrollController.dispose();
    _resets.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ResetScope(
      signal: _resets,
      child: PrimaryScrollController(
        controller: _scrollController,
        child: widget.child,
      ),
    );
  }
}

/// Scrolls [controller] back to the top; false when it is already there.
bool animateToTop(ScrollController controller) {
  final scrolled = controller.positions.where(
    (p) => p.pixels > p.minScrollExtent,
  );
  if (scrolled.isEmpty) return false;
  for (final p in scrolled.toList()) {
    p.animateTo(
      p.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
  return true;
}

class _ResetScope extends InheritedWidget {
  final Listenable signal;
  const _ResetScope({required this.signal, required super.child});

  @override
  bool updateShouldNotify(_ResetScope oldWidget) => signal != oldWidget.signal;
}
