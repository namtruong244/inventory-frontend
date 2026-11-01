import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/widgets/home_tab_support.dart';

/// A tab body that scrolls with the host's primary controller and counts how
/// often it was asked to clear its filters.
class _Tab extends StatefulWidget {
  const _Tab();

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  int resets = 0;
  Listenable? _signal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _signal?.removeListener(_onReset);
    _signal = ScrollToTopHost.resetSignalOf(context)?..addListener(_onReset);
  }

  @override
  void dispose() {
    _signal?.removeListener(_onReset);
    super.dispose();
  }

  void _onReset() => resets++;

  @override
  Widget build(BuildContext context) => ListView(
    primary: true,
    children: [
      for (var i = 0; i < 60; i++) SizedBox(height: 80, child: Text('row $i')),
    ],
  );
}

void main() {
  final hostKey = GlobalKey<ScrollToTopHostState>();

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ScrollToTopHost(key: hostKey, child: const _Tab()),
      ),
    ),
  );

  ScrollPosition position(WidgetTester tester) =>
      tester.state<ScrollableState>(find.byType(Scrollable)).position;

  testWidgets('scrollToTop reports whether there was anywhere to go', (
    tester,
  ) async {
    await pump(tester);
    expect(hostKey.currentState!.scrollToTop(), isFalse);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(position(tester).pixels, greaterThan(0));

    expect(hostKey.currentState!.scrollToTop(), isTrue);
    await tester.pumpAndSettle();
    expect(position(tester).pixels, 0);
    expect(tester.state<_TabState>(find.byType(_Tab)).resets, 0);
  });

  testWidgets('resetFilters signals the tab without scrolling', (tester) async {
    await pump(tester);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    final offset = position(tester).pixels;

    hostKey.currentState!.resetFilters();
    await tester.pump();
    expect(tester.state<_TabState>(find.byType(_Tab)).resets, 1);
    expect(position(tester).pixels, offset);
  });

  testWidgets('reset jumps to the top and clears filters', (tester) async {
    await pump(tester);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    hostKey.currentState!.reset();
    await tester.pump();
    expect(position(tester).pixels, 0);
    expect(tester.state<_TabState>(find.byType(_Tab)).resets, 1);
  });
}
