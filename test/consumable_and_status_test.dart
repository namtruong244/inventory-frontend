import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/screens/item_details_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('Item isConsumable & Status Serialization', () {
    test('Default isConsumable is false and serializes correctly', () {
      final item = Item(
        id: 'item-1',
        name: 'Drill',
        boxId: 'box-1',
        status: ItemStatus.stored,
      );

      expect(item.isConsumable, false);
      expect(item.status, ItemStatus.stored);

      final json = item.toJson();
      expect(json['isConsumable'], false);
      expect(json['status'], 'stored');

      final fromJsonItem = Item.fromJson(json);
      expect(fromJsonItem.isConsumable, false);
      expect(fromJsonItem.status, ItemStatus.stored);
    });

    test('isConsumable can be set to true and copies correctly', () {
      final item = Item(
        id: 'item-2',
        name: 'AA Batteries',
        boxId: 'box-1',
        quantity: 12,
        unit: 'pcs',
        isConsumable: true,
        status: ItemStatus.stored,
      );

      expect(item.isConsumable, true);
      expect(item.quantity, 12);

      final updated = item.copyWith(quantity: 11);
      expect(updated.isConsumable, true);
      expect(updated.quantity, 11);

      final json = updated.toJson();
      expect(json['isConsumable'], true);
      final fromJson = Item.fromJson(json);
      expect(fromJson.isConsumable, true);
      expect(fromJson.quantity, 11);
    });
  });

  group('ItemDetailsScreen Action Buttons', () {
    testWidgets('Non-consumable stored item displays "Lấy ra dùng" button', (
      tester,
    ) async {
      final provider = InventoryProvider();
      final box = Box(id: 'box-1', name: 'Toolbox', label: 'TB-01');
      final item = Item(
        id: 'item-durable-1',
        name: 'Power Drill',
        boxId: 'box-1',
        status: ItemStatus.stored,
        isConsumable: false,
      );

      provider.addBox(box);
      provider.addItem(item);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          home: ChangeNotifierProvider<InventoryProvider>.value(
            value: provider,
            child: const ItemDetailsScreen(itemId: 'item-durable-1'),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Take Out to Use'), findsOneWidget);
      expect(find.text('Move'), findsOneWidget);
      expect(find.text('Edit Details'), findsNothing);
    });

    testWidgets(
      'Non-consumable inUse item displays "Return to Storage" button',
      (tester) async {
        final provider = InventoryProvider();
        final box = Box(id: 'box-1', name: 'Toolbox', label: 'TB-01');
        final item = Item(
          id: 'item-durable-2',
          name: 'Power Drill',
          boxId: 'box-1',
          status: ItemStatus.inUse,
          isConsumable: false,
        );

        provider.addBox(box);
        provider.addItem(item);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            home: ChangeNotifierProvider<InventoryProvider>.value(
              value: provider,
              child: const ItemDetailsScreen(itemId: 'item-durable-2'),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(find.text('Return to Storage'), findsOneWidget);
      },
    );

    testWidgets(
      'Consumable item displays "Consumable" badge and consume button',
      (tester) async {
        final provider = InventoryProvider();
        final box = Box(id: 'box-1', name: 'Medicine Cabinet', label: 'MC-01');
        final item = Item(
          id: 'item-consumable-1',
          name: 'Face Masks',
          boxId: 'box-1',
          quantity: 50,
          unit: 'pcs',
          isConsumable: true,
        );

        provider.addBox(box);
        provider.addItem(item);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            home: ChangeNotifierProvider<InventoryProvider>.value(
              value: provider,
              child: const ItemDetailsScreen(itemId: 'item-consumable-1'),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(find.text('Consumable'), findsOneWidget);
        expect(find.text('Consume (pcs)'), findsOneWidget);
      },
    );

    testWidgets(
      'Consumable item with 0 quantity displays out of stock button',
      (tester) async {
        final provider = InventoryProvider();
        final box = Box(id: 'box-1', name: 'Medicine Cabinet', label: 'MC-01');
        final item = Item(
          id: 'item-consumable-2',
          name: 'AA Batteries',
          boxId: 'box-1',
          quantity: 0,
          unit: 'pcs',
          isConsumable: true,
        );

        provider.addBox(box);
        provider.addItem(item);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            home: ChangeNotifierProvider<InventoryProvider>.value(
              value: provider,
              child: const ItemDetailsScreen(itemId: 'item-consumable-2'),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(find.text('Out of Stock (Restock)'), findsOneWidget);
      },
    );
  });
}
