import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/services/offline_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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
      const PendingOp('quantity', {'id': 'i1', 'quantity': 4.0, 'reason': 'consume'}),
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
    final back = Item.fromJson(PendingOp('createItem', {'item': item.toJson()}).args['item'] as Map<String, dynamic>);
    expect(back.id, item.id);
    expect(back.expiryDate, DateTime(2026, 12, 1));
    expect(back.minQuantity, 1);
  });
}
