import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/services/api_service.dart';

void main() {
  group('Models JSON serialization', () {
    test('Box fromJson and toJson', () {
      final json = {
        'id': 'b-1',
        'name': 'Living Room Shelf',
        'type': 'shelf',
        'description': 'Main shelf',
        'label': 'shelf_01',
        'parentId': null,
        'createdAt': '2026-09-30T05:00:00.000Z',
      };
      final box = Box.fromJson(json);
      expect(box.id, 'b-1');
      expect(box.name, 'Living Room Shelf');
      expect(box.type, StorageType.shelf);
      expect(box.label, 'shelf_01');
      expect(box.parentId, isNull);

      final outJson = box.toJson();
      expect(outJson['name'], 'Living Room Shelf');
      expect(outJson['type'], 'shelf');
    });

    test('Item fromJson and low stock threshold', () {
      final json = {
        'id': 'item-1',
        'name': 'USB-C Cable',
        'boxId': 'b-1',
        'categoryId': 'Electronics',
        'quantity': 2.0,
        'unit': 'pcs',
        'minQuantity': 3.0,
        'status': 'stored',
        'createdAt': '2026-09-30T05:00:00.000Z',
      };
      final item = Item.fromJson(json);
      expect(item.name, 'USB-C Cable');
      expect(item.quantity, 2.0);
      expect(item.minQuantity, 3.0);
      expect(item.isLowStock, isTrue); // 2 <= 3
    });

    test('LendingRecord fromJson and overdue logic', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 3));
      final json = {
        'id': 'loan-1',
        'itemId': 'item-1',
        'borrowerName': 'John Doe',
        'lentDate': '2026-09-20T10:00:00.000Z',
        'expectedReturnDate': pastDate.toIso8601String(),
        'actualReturnDate': null,
      };
      final loan = LendingRecord.fromJson(json);
      expect(loan.borrowerName, 'John Doe');
      expect(loan.isActive, isTrue);
      expect(loan.isOverdue, isTrue);
    });
  });

  group('StockHistory and lost status', () {
    test('StockHistory.fromJson', () {
      final h = StockHistory.fromJson({
        'movements': [
          {
            'id': 'm-1',
            'delta': -6,
            'quantityAfter': 4,
            'reason': 'consume',
            'note': '',
            'createdAt': '2026-10-25T05:00:00Z',
          }
        ],
        'avgDailyConsumption30d': 0.2,
        'estimatedDaysLeft': null,
      });
      expect(h.movements.single.delta, -6);
      expect(h.estimatedDaysLeft, isNull);
    });

    test('lost is a known ItemStatus', () {
      expect(ItemStatus.values.map((s) => s.name), contains('lost'));
    });
  });

  // Needs a running backend: flutter test --dart-define=LIVE_API=true
  const liveApi = bool.fromEnvironment('LIVE_API');
  group('Backend Live API Integration', skip: liveApi ? false : 'set --dart-define=LIVE_API=true with the backend running', () {
    final api = ApiService();

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      HttpOverrides.global = null;
    });

    test('Login Sara Wilson on live backend', () async {
      try {
        final res = await api.login('sara.wilson@example.com', 'SecurePassword123!');
        expect(res['token'], isNotNull);
        expect(api.isAuthenticated, isTrue);
      } catch (_) {
        // If not registered yet, register
        final res = await api.register('Sara Wilson', 'sara.wilson@example.com', 'SecurePassword123!');
        expect(res['token'], isNotNull);
        expect(api.isAuthenticated, isTrue);
      }
    });

    test('Fetch categories from backend', () async {
      final categories = await api.getCategories();
      expect(categories, isNotEmpty);
      expect(categories.any((c) => c['name'] == 'Electronics'), isTrue);
    });

    test('Fetch and update settings from backend', () async {
      final settings = await api.getSettings();
      expect(settings, isNotNull);

      final updated = await api.updateSettings({'defaultUnit': 'pcs'});
      expect(updated['defaultUnit'], 'pcs');
    });

    test('Box & Item CRUD on live backend', () async {
      // 1. Create a test box
      final testBox = Box(
        name: 'Unit Test Storage',
        type: StorageType.box,
        label: 'test_box_label_${DateTime.now().millisecondsSinceEpoch}',
        description: 'Temporary unit test box',
      );
      final createdBox = await api.createBox(testBox);
      expect(createdBox.name, 'Unit Test Storage');

      // 2. Create a test item in the box
      final testItem = Item(
        name: 'Unit Test Widget',
        boxId: createdBox.id,
        categoryId: 'Electronics',
        quantity: 5.0,
        unit: 'pcs',
        minQuantity: 2.0,
      );
      final createdItem = await api.createItem(testItem);
      expect(createdItem.name, 'Unit Test Widget');
      expect(createdItem.quantity, 5.0);

      // 3. Update quantity
      await api.updateItemQuantity(createdItem.id, 1.0);
      final updatedItem = await api.getItemById(createdItem.id);
      expect(updatedItem.quantity, 1.0);
      expect(updatedItem.isLowStock, isTrue); // 1 <= 2

      // 4. Test scan lookup
      final scanResult = await api.lookupScan(createdBox.label);
      expect(scanResult, isNotNull);
      expect(scanResult!['type'], 'box');

      // 5. Cleanup
      await api.deleteItem(createdItem.id);
      await api.deleteBox(createdBox.id);
    });
  });
}
