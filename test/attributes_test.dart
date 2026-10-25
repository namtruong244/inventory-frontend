import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/screens/item_create_screen.dart';
import 'package:inventory/screens/item_details_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('Item Custom Attributes Model & Serialization', () {
    test('Item retains and modifies customAttributes via copyWith and toJson', () {
      final item = Item(
        id: 'test-1',
        name: 'MacBook Pro',
        boxId: 'box-1',
        categoryId: 'Electronics',
        customAttributes: {'Color': 'Space Black', 'RAM': '36GB'},
      );

      expect(item.customAttributes['Color'], 'Space Black');
      expect(item.customAttributes['RAM'], '36GB');

      final updated = item.copyWith(
        customAttributes: {'Color': 'Silver', 'RAM': '36GB', 'Storage': '1TB'},
      );

      expect(updated.customAttributes['Color'], 'Silver');
      expect(updated.customAttributes['Storage'], '1TB');

      final json = updated.toJson();
      expect(json['customAttributes'], isA<Map>());
      expect(json['customAttributes']['Storage'], '1TB');

      final fromJsonItem = Item.fromJson(json);
      expect(fromJsonItem.customAttributes['Color'], 'Silver');
      expect(fromJsonItem.customAttributes['Storage'], '1TB');
    });
  });

  group('ItemCreateScreen Specifications UI', () {
    testWidgets('renders Specifications section and allows adding an attribute', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(),
          child: MaterialApp(
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: AppLocalizations.supportedLocales,

            home: Scaffold(
              body: ItemCreateScreen(boxId: 'box-1'),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      final specFinder = find.text('Specifications & Attributes');
      await tester.scrollUntilVisible(
        specFinder,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      expect(specFinder, findsOneWidget);
      expect(find.text('No specifications added yet'), findsOneWidget);

      // Verify suggested chips like Color, Size, Brand are available
      expect(find.text('Color'), findsOneWidget);

      // Scroll and Tap on "Add Specification" button to open modal sheet
      await tester.drag(find.byType(ListView), const Offset(0, -250));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Specification'));
      await tester.pumpAndSettle();

      // Verify bottom sheet title is displayed
      expect(find.text('Add Specification'), findsWidgets);

      // Fill in attribute name and value inside the bottom sheet
      final sheetFields = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextFormField),
      );

      await tester.enterText(sheetFields.at(0), 'Color');
      await tester.enterText(sheetFields.at(1), 'Space Black');

      // Tap Save / Add Specification button
      await tester.tap(find.widgetWithText(FilledButton, 'Add Specification'));
      await tester.pumpAndSettle();

      // Check that the new attribute is now displayed in the list
      expect(find.text('COLOR'), findsOneWidget);
      expect(find.text('Space Black'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });

  group('ItemDetailsScreen Specifications UI', () {
    testWidgets('renders Specifications card with existing attributes and Manage button',
        (WidgetTester tester) async {
      final provider = InventoryProvider();

      // Create item with attributes
      final item = Item(
        id: 'spec-item-1',
        name: 'Demo Camera',
        boxId: 'box-1',
        categoryId: 'Electronics',
        customAttributes: {'Resolution': '4K', 'Sensor': 'Full Frame'},
      );
      provider.addItem(item);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: AppLocalizations.supportedLocales,

            home: ItemDetailsScreen(itemId: item.id),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      final specFinder = find.text('Specifications & Attributes');
      await tester.scrollUntilVisible(specFinder, 500);

      // Verify card exists
      expect(specFinder, findsOneWidget);
      expect(find.text('Manage'), findsOneWidget);
      expect(find.text('RESOLUTION'), findsOneWidget);
      expect(find.text('4K'), findsOneWidget);
      expect(find.text('SENSOR'), findsOneWidget);
      expect(find.text('Full Frame'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });
}
