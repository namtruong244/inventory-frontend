import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/widgets/export_barcodes_sheet.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'ExportBarcodesSheet renders box barcodes only without ID and without items',
    (tester) async {
      final provider = InventoryProvider();
      final box1 = Box(id: 'box-test-1', name: 'Workshop Box', label: 'WS-01');
      final box2 = Box(
        id: 'box-test-2',
        name: 'Garage Cabinet',
        label: 'GC-01',
      );
      final item = Item(
        id: 'item-test-1',
        name: 'Electric Screwdriver',
        boxId: 'box-test-1',
        barcode: 'ES-123456',
      );

      provider.addBox(box1);
      provider.addBox(box2);
      provider.addItem(item);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          home: ChangeNotifierProvider<InventoryProvider>.value(
            value: provider,
            child: const ExportBarcodesSheet(boxId: 'box-test-1'),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify Title and Subtitle for single box
      expect(find.text('Export Box Barcodes'), findsOneWidget);
      expect(find.text('Workshop Box'), findsWidgets);

      // Verify NO item is rendered in export list
      expect(find.text('Electric Screwdriver'), findsNothing);
      expect(find.text('ES-123456'), findsNothing);

      // Verify NO box ID is displayed as text label
      expect(find.text('box-test-1'), findsNothing);
      expect(find.text('WS-01'), findsNothing);

      // Verify toggle controls are available
      expect(find.text('This Container'), findsOneWidget);
      expect(find.text('All Containers (2)'), findsOneWidget);

      // Verify Action Buttons
      expect(find.text('Export PDF (Save/Share)'), findsOneWidget);
      expect(find.text('Print Preview'), findsOneWidget);

      // Tap "All Containers" toggle
      await tester.tap(find.text('All Containers (2)'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Now both box names should be in the view
      expect(find.text('Workshop Box'), findsWidgets);
      expect(find.text('Garage Cabinet'), findsOneWidget);
    },
  );

  testWidgets('ExportBarcodesSheet.showAll renders all boxes directly', (
    tester,
  ) async {
    final provider = InventoryProvider();
    final box1 = Box(id: 'box-test-1', name: 'Workshop Box', label: 'WS-01');
    final box2 = Box(
      id: 'box-test-2',
      name: 'Living Room Shelf',
      label: 'LRS-02',
    );

    provider.addBox(box1);
    provider.addBox(box2);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,

        home: ChangeNotifierProvider<InventoryProvider>.value(
          value: provider,
          child: const ExportBarcodesSheet(boxId: null),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Verify screen title for all boxes
    // The "All Storage Locations" header only labels the exported PDF now,
    // it is no longer drawn on screen.
    expect(find.text('Export All Box Barcodes'), findsOneWidget);
    expect(find.text('All Storage Locations'), findsNothing);
    expect(find.text('2 box labels'), findsOneWidget);

    // Verify both boxes are listed
    expect(find.text('Workshop Box'), findsOneWidget);
    expect(find.text('Living Room Shelf'), findsOneWidget);

    // Verify no IDs
    expect(find.text('box-test-1'), findsNothing);
    expect(find.text('box-test-2'), findsNothing);
    expect(find.text('WS-01'), findsNothing);
    expect(find.text('LRS-02'), findsNothing);

    // Segmented toggle should NOT be present when boxId is null
    expect(find.text('This Container'), findsNothing);
  });
}
