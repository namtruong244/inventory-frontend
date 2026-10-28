import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/widgets/app_icon.dart';

void main() {
  testWidgets('every hand-drawn glyph parses and renders', (tester) async {
    final svgs = appIconSvgs.toList();
    expect(svgs, isNotEmpty);
    await tester.pumpWidget(MaterialApp(
      home: Wrap(children: [for (final s in svgs) SvgPicture.string(s, width: 24, height: 24)]),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('unmapped icons fall back to the Material font', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppIcon(Icons.ac_unit)));
    expect(find.byIcon(Icons.ac_unit), findsOneWidget);
  });
}
