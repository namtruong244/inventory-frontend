import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/services/offline_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    OfflineStore.directoryProvider = () async => null;
  });
  snapshotFileTests();
  bigSnapshotTest();

  test('snapshot round-trips and is isolated per user', () async {
    final box = Box(name: 'Garage', type: StorageType.room, label: 'BOX-1');
    final item = Item(name: 'Drill', boxId: box.id, quantity: 3);
    await OfflineStore('u1').saveSnapshot(
      InventorySnapshot(
        boxes: [box],
        items: [item],
        loans: [
          LendingRecord(
            itemId: item.id,
            borrowerName: 'An',
            quantity: 2,
            isPartial: true,
          ),
        ],
        categories: ['Tools'],
      ),
    );

    final snap = await OfflineStore('u1').loadSnapshot();
    expect(snap!.boxes.single.label, 'BOX-1');
    expect(snap.items.single.quantity, 3);
    expect(snap.loans.single.isPartial, isTrue);
    expect(snap.loans.single.quantity, 2);
    expect(await OfflineStore('u2').loadSnapshot(), isNull);
  });

  test('pending ops persist in order and clear', () async {
    final store = OfflineStore('u1');
    await store.savePending([
      const PendingOp('quantity', {
        'id': 'i1',
        'quantity': 4.0,
        'reason': 'consume',
      }),
      const PendingOp('deleteItem', {'id': 'i2'}),
    ]);
    final loaded = await store.loadPending();
    expect(loaded.map((o) => o.type), ['quantity', 'deleteItem']);
    expect(loaded.first.args['quantity'], 4.0);
    await store.savePending([]);
    expect(await store.loadPending(), isEmpty);
  });

  test('item survives a queue round trip with dates', () {
    final item = Item(
      name: 'Milk',
      boxId: 'b1',
      quantity: 2,
      expiryDate: DateTime(2026, 12, 1),
      minQuantity: 1,
    );
    final back = Item.fromJson(
      PendingOp('createItem', {'item': item.toJson()}).args['item']
          as Map<String, dynamic>,
    );
    expect(back.id, item.id);
    expect(back.expiryDate, DateTime(2026, 12, 1));
    expect(back.minQuantity, 1);
  });
}

void snapshotFileTests() {
  group('snapshot file', () {
    late Directory dir;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      dir = await Directory.systemTemp.createTemp('offline_store_test');
      OfflineStore.directoryProvider = () async => dir;
    });

    tearDown(() async {
      OfflineStore.directoryProvider = () async => null;
      await dir.delete(recursive: true);
    });

    InventorySnapshot snap(int items) => InventorySnapshot(
      boxes: [Box(name: 'B', type: StorageType.box, label: 'L')],
      items: [for (var i = 0; i < items; i++) Item(name: 'i$i', boxId: 'b')],
      loans: const [],
      categories: const ['Tools'],
    );

    test('is stored as a file, not in SharedPreferences', () async {
      await OfflineStore('u1').saveSnapshot(snap(3));
      expect(dir.listSync().whereType<File>().length, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys().where((k) => k.contains('snapshot')), isEmpty);
      expect((await OfflineStore('u1').loadSnapshot())!.items.length, 3);
    });

    test('rapid saves are coalesced and the last one wins', () async {
      final store = OfflineStore('u1');
      final saves = [for (var i = 1; i <= 5; i++) store.saveSnapshot(snap(i))];
      await Future.wait(saves);
      expect((await store.loadSnapshot())!.items.length, 5);
      expect(dir.listSync().where((f) => f.path.endsWith('.tmp')), isEmpty);
    });

    test(
      'a snapshot left in SharedPreferences by an old build still loads',
      () async {
        final legacy = OfflineStore('u1');
        OfflineStore.directoryProvider = () async => null;
        await legacy.saveSnapshot(snap(2)); // lands in SharedPreferences
        OfflineStore.directoryProvider = () async => dir;
        expect((await legacy.loadSnapshot())!.items.length, 2);
        await legacy.saveSnapshot(snap(4)); // migrates to the file
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getKeys().where((k) => k.contains('snapshot')), isEmpty);
        expect((await legacy.loadSnapshot())!.items.length, 4);
      },
    );

    test('clear removes the file', () async {
      final store = OfflineStore('u1');
      await store.saveSnapshot(snap(1));
      await store.clear();
      expect(dir.listSync(), isEmpty);
      expect(await store.loadSnapshot(), isNull);
    });
  });
}

void bigSnapshotTest() {
  test(
    'a large snapshot is encoded off the UI isolate and round-trips',
    () async {
      SharedPreferences.setMockInitialValues({});
      OfflineStore.directoryProvider = () async => null;
      final store = OfflineStore('big');
      await store.saveSnapshot(
        InventorySnapshot(
          boxes: const [],
          items: [for (var i = 0; i < 2000; i++) Item(name: 'i$i', boxId: 'b')],
          loans: const [],
          categories: const [],
        ),
      );
      expect((await store.loadSnapshot())!.items.length, 2000);
    },
  );
}
