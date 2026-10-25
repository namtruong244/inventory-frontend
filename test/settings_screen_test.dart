import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:inventory/l10n/app_localizations.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/screens/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen hides developer options by default and unlocks on 7 taps on Version', (WidgetTester tester) async {
    final provider = InventoryProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<InventoryProvider>.value(
        value: provider,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify developer options and seed button are hidden by default
    expect(find.text('DEVELOPER OPTIONS & BACKEND API'), findsNothing);
    expect(find.text('Seed Demo Data to Server'), findsNothing);

    // Scroll down to find Application Version row
    final versionFinder = find.text('Application Version');
    await tester.scrollUntilVisible(versionFinder, 200);
    await tester.ensureVisible(versionFinder);
    await tester.pump();
    expect(versionFinder, findsOneWidget);

    // Tap 6 times - still locked
    for (int i = 0; i < 6; i++) {
      await tester.tap(versionFinder);
      await tester.pump();
    }
    expect(find.text('DEVELOPER OPTIONS & BACKEND API'), findsNothing);

    // 7th tap unlocks
    await tester.tap(versionFinder);
    await tester.pumpAndSettle();

    // Now developer section is revealed
    expect(find.text('DEVELOPER OPTIONS & BACKEND API'), findsOneWidget);
    expect(find.text('DEVELOPER'), findsOneWidget);

    // Scroll to see Seed Demo Data to Server
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Seed Demo Data to Server'), findsOneWidget);

    // Scroll back up to find Hide button
    final hideButton = find.text('Hide');
    await tester.scrollUntilVisible(hideButton, -200);
    expect(hideButton, findsOneWidget);
    await tester.tap(hideButton);
    await tester.pumpAndSettle();

    // Verify re-locked
    expect(find.text('DEVELOPER OPTIONS & BACKEND API'), findsNothing);
  });
}
