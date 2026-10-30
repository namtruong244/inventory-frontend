import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/models/inventory_models.dart';

Item _item({double quantity = 3, double lent = 5, double? min = 4}) => Item(
  id: 'i1',
  name: 'Charger',
  boxId: 'b1',
  quantity: quantity,
  lentQuantity: lent,
  minQuantity: min,
);

void main() {
  test('isLowStockAt counts lent units like isLowStock', () {
    final item = _item();
    // 2 on hand + 5 lent = 7 > 4: not low, matching Item.isLowStock.
    expect(item.isLowStockAt(2), isFalse);
    expect(item.isLowStockAt(0), isFalse);
    expect(_item(lent: 0).isLowStockAt(4), isTrue);
    expect(_item(min: null).isLowStockAt(0), isFalse);
  });

  test('isLowStock delegates to isLowStockAt(quantity)', () {
    expect(_item(quantity: 1, lent: 3).isLowStock, isTrue);
    expect(_item().isLowStock, isFalse);
  });

  test('stockRatio is held / (min * 2), null without a threshold', () {
    expect(_item().stockRatio, 1.0); // (3 + 5) / 8
    expect(_item(min: null).stockRatio, isNull);
    expect(_item(min: 0).stockRatio, isNull);
  });
}
