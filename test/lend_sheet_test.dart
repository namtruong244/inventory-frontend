import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/l10n/app_localizations.dart';
import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/services/offline_store.dart';
import 'package:inventory/widgets/lend_item_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'offline_flush_test.dart' show FakeApi;

void main() {
  late InventoryProvider provider;
  final desk = Item(id: 'i1', name: 'Bàn làm việc', boxId: 'b1');
  final lamp = Item(id: 'i2', name: 'Đèn ngủ', boxId: 'b1');
  final lentChair = Item(
    id: 'i3',
    name: 'Ghế',
    boxId: 'b1',
    status: ItemStatus.lent,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    OfflineStore.directoryProvider = () async => null;
    provider = InventoryProvider(api: FakeApi()..noBoxes = true);
    await provider.initializationFuture;
    for (final i in [desk, lamp, lentChair]) {
      await provider.addItem(i);
    }
  });

  tearDown(() => provider.dispose());

  Future<void> pumpSheet(WidgetTester tester, {Item? initialItem}) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ChangeNotifierProvider<InventoryProvider>.value(
        value: provider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: LendItemSheet(initialItem: initialItem)),
        ),
      ),
    );
  }

  testWidgets('opened from an item, that item is already chosen and fixed', (
    tester,
  ) async {
    await pumpSheet(tester, initialItem: lamp);
    expect(find.text('Đèn ngủ'), findsOneWidget);
    await tester.tap(find.text('Đèn ngủ'));
    await tester.pumpAndSettle();
    expect(
      find.text('Search items, barcodes, serials...'),
      findsNothing,
      reason: 'no picker for a fixed item',
    );
  });

  testWidgets(
    'the item picker searches without regard to accents and skips lent items',
    (tester) async {
      await pumpSheet(tester);
      await tester.tap(find.text('Choose an available item...'));
      await tester.pumpAndSettle();

      expect(find.text('Bàn làm việc'), findsOneWidget);
      expect(find.text('Đèn ngủ'), findsOneWidget);
      expect(find.text('Ghế'), findsNothing, reason: 'already lent');

      await tester.enterText(find.byType(TextField).last, 'ban lam');
      await tester.pump();
      expect(find.text('Bàn làm việc'), findsOneWidget);
      expect(find.text('Đèn ngủ'), findsNothing);

      await tester.tap(find.text('Bàn làm việc'));
      await tester.pumpAndSettle();
      expect(
        find.text('Bàn làm việc'),
        findsOneWidget,
        reason: 'the choice is shown in the form',
      );
      expect(find.text('Choose an available item...'), findsNothing);
    },
  );
}
