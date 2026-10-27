import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/l10n/app_localizations.dart';
import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/screens/item_create_screen.dart';
import 'package:inventory/services/api_service.dart' show ApiException;
import 'package:inventory/services/offline_store.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'offline_flush_test.dart' show FakeApi;

void main() {
  late FakeApi api;
  late InventoryProvider provider;
  final existing = Item(
    id: 'i1',
    name: 'Drill',
    description: 'Cordless, 18V',
    boxId: 'b1',
    categoryId: 'Tools & Hardware',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    OfflineStore.directoryProvider = () async => null;
    api = FakeApi()..noBoxes = true;
    provider = InventoryProvider(api: api);
    await provider.initializationFuture;
    await provider.addBox(Box(id: 'b1', name: 'Garage', type: StorageType.room, label: 'G'));
    await provider.addItem(existing);
  });

  tearDown(() => provider.dispose());

  /// The form is opened from a button, so there is a screen to go back to.
  Future<void> openForm(WidgetTester tester, {Item? item}) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ChangeNotifierProvider<InventoryProvider>.value(
        value: provider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ItemCreateScreen(boxId: 'b1', existingItem: item)),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('editing keeps the description', (tester) async {
    await openForm(tester, item: existing);
    expect(find.text('Cordless, 18V'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Drill'), 'Drill 2');
    await tester.tap(find.text('Save Changes'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final saved = provider.getItemById('i1')!;
    expect(saved.name, 'Drill 2');
    expect(saved.description, 'Cordless, 18V', reason: 'the description must survive an edit');
  });

  testWidgets('a rejected save keeps the form open and the typed values', (tester) async {
    await openForm(tester, item: existing);
    api.mutationError = ApiException(statusCode: 400, code: 'X', message: 'no');
    await tester.enterText(find.widgetWithText(TextFormField, 'Drill'), 'Changed');
    await tester.tap(find.text('Save Changes'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(ItemCreateScreen), findsOneWidget, reason: 'still on the form');
    expect(find.text('Changed'), findsOneWidget);
    expect(provider.getItemById('i1')!.name, 'Drill', reason: 'the provider undid the edit');
  });

  testWidgets('quantity must be a number of at least zero', (tester) async {
    await openForm(tester, item: existing);
    await tester.enterText(find.widgetWithText(TextFormField, '1'), '-3');
    await tester.tap(find.text('Save Changes'));
    await tester.pump();
    expect(find.text('Enter a valid quantity (0 or more)'), findsOneWidget);
    expect(find.byType(ItemCreateScreen), findsOneWidget);
  });

  testWidgets('leaving with unsaved changes asks first; an untouched form just closes', (tester) async {
    await openForm(tester, item: existing);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(ItemCreateScreen), findsNothing, reason: 'nothing changed, no prompt');

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Drill'), 'Edited');
    await tester.pump();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    expect(find.byType(ItemCreateScreen), findsOneWidget);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.byType(ItemCreateScreen), findsNothing);
  });

  testWidgets('a new item starts with a category the user actually has', (tester) async {
    await openForm(tester);
    final chosen = provider.items.last.categoryId;
    expect(find.text(chosen), findsWidgets, reason: 'the last used category is suggested');
  });
}
