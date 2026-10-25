import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/services/offline_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('snapshot round-trips and is isolated per user', () async {
    final box = Box(name: 'Garage', type: StorageType.room, label: 'BOX-1');
    final item = Item(name: 'Drill', boxId: box.id, quantity: 3);
    await OfflineStore('u1').saveSnapshot(InventorySnapshot(
      boxes: [box],
      items: [item],
      loans: [LendingRecord(itemId: item.id, borrowerName: 'An', quantity: 2, isPartial: true)],
      categories: ['Tools'],
    ));

    final snap = await OfflineStore('u1').loadSnapshot();
    expect(snap!.boxes.single.label, 'BOX-1');
    expect(snap.items.single.quantity, 3);
    expect(snap.loans.single.isPartial, isTrue);
    expect(snap.loans.single.quantity, 2);
    expect(await OfflineStore('u2').loadSnapshot(), isNull);
  });

  test('pending quantity changes persist and clear', () async {
    final store = OfflineStore('u1');
    await store.savePending([const PendingQuantityChange('i1', 4, 'consume')]);
    final loaded = await store.loadPending();
    expect(loaded.single.quantity, 4);
    expect(loaded.single.reason, 'consume');
    await store.savePending([]);
    expect(await store.loadPending(), isEmpty);
  });
}
