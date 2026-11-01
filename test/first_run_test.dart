import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/l10n/app_localizations.dart';
import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/services/offline_store.dart';
import 'package:inventory/widgets/first_rooms_card.dart';
import 'package:inventory/widgets/soft_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'offline_flush_test.dart' show FakeApi;

void main() {
  late FakeApi api;
  late InventoryProvider provider;

  // The provider is built here, outside the widget test's fake-async zone, so its timers
  // (probe timeout, startup pause) run on the real clock.
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    OfflineStore.directoryProvider = () async => null;
    api = FakeApi()..noBoxes = true;
    provider = InventoryProvider(api: api);
    await provider.initializationFuture;
  });

  tearDown(() => provider.dispose());

  Future<void> pumpCard(WidgetTester tester) => tester.pumpWidget(
    ChangeNotifierProvider<InventoryProvider>.value(
      value: provider,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: FirstRoomsCard())),
      ),
    ),
  );

  SoftButton createButton(WidgetTester tester) =>
      tester.widget<SoftButton>(find.byType(SoftButton));

  testWidgets('picking rooms creates them as top-level locations', (
    tester,
  ) async {
    await pumpCard(tester);
    expect(find.text('Which rooms do you store things in?'), findsOneWidget);
    expect(
      createButton(tester).onPressed,
      isNull,
      reason: 'nothing picked yet',
    );

    await tester.tap(find.text('Kitchen'));
    await tester.tap(find.text('Garage'));
    await tester.pump();
    expect(find.text('Create 2 rooms'), findsOneWidget);

    await tester.tap(find.byType(SoftButton));
    await tester.pump(const Duration(seconds: 1));

    expect(provider.boxes.map((b) => b.name).toSet(), {'Kitchen', 'Garage'});
    expect(
      provider.boxes.every(
        (b) => b.type == StorageType.room && b.parentId == null,
      ),
      isTrue,
    );
    expect(
      provider.boxes.map((b) => b.label).toSet().length,
      2,
      reason: 'labels must be unique',
    );
    expect(api.boxesCreated, 2);
    expect(
      createButton(tester).onPressed,
      isNull,
      reason: 'selection is cleared for the next round',
    );
  });

  testWidgets('a room the server rejects is not left in the list', (
    tester,
  ) async {
    api.boxError = Exception('boom');
    await pumpCard(tester);
    await tester.tap(find.text('Kitchen'));
    await tester.pump();
    await tester.tap(find.byType(SoftButton));
    await tester.pump(const Duration(seconds: 1));
    expect(provider.boxes, isEmpty);
  });

  testWidgets('the success toast shows even when Home swaps the card out', (
    tester,
  ) async {
    // Same swap as HomeScreen: the first room makes boxes non-empty, so the card
    // is only kept while the batch runs.
    await tester.pumpWidget(
      ChangeNotifierProvider<InventoryProvider>.value(
        value: provider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Consumer<InventoryProvider>(
              builder: (context, p, _) =>
                  p.boxes.isEmpty || p.isCreatingRooms
                  ? const SingleChildScrollView(child: FirstRoomsCard())
                  : const Text('home'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Kitchen'));
    await tester.tap(find.text('Garage'));
    await tester.pump();
    await tester.tap(find.byType(SoftButton));
    await tester.pump(const Duration(seconds: 1));

    expect(provider.boxes.length, 2);
    expect(find.text('2 locations created'), findsOneWidget);
    expect(find.text('home'), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
  });
}
