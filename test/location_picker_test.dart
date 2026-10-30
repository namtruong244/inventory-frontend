import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/l10n/app_localizations.dart';
import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/services/offline_store.dart';
import 'package:inventory/widgets/location_picker_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'offline_flush_test.dart' show FakeApi;

void main() {
  late InventoryProvider provider;
  Box? picked;

  setUp(() async {
    picked = null;
    SharedPreferences.setMockInitialValues({});
    OfflineStore.directoryProvider = () async => null;
    provider = InventoryProvider(api: FakeApi()..noBoxes = true);
    await provider.initializationFuture;
    await provider.addBox(
      Box(id: 'house', name: 'Nhà', type: StorageType.room, label: 'H'),
    );
    await provider.addBox(
      Box(
        id: 'living',
        name: 'Phòng khách',
        type: StorageType.room,
        label: 'L',
        parentId: 'house',
      ),
    );
  });

  tearDown(() => provider.dispose());

  Future<void> openPicker(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ChangeNotifierProvider<InventoryProvider>.value(
        value: provider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async =>
                    picked = await LocationPickerSheet.show(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('search finds a nested location without accents and selects it', (
    tester,
  ) async {
    await openPicker(tester);
    expect(
      find.text('Phòng khách'),
      findsNothing,
      reason: 'only the root level is listed',
    );

    await tester.enterText(find.byType(TextField), 'phong khach');
    await tester.pump();
    expect(find.text('Phòng khách'), findsOneWidget);
    expect(
      find.text('Nhà › Phòng khách'),
      findsOneWidget,
      reason: 'the path says where it is',
    );

    await tester.tap(find.text('Phòng khách'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select Location'));
    await tester.pumpAndSettle();
    expect(picked?.id, 'living');
  });

  testWidgets('a location can be created right where you are browsing', (
    tester,
  ) async {
    await openPicker(tester);
    await tester.ensureVisible(find.text('Create new location here'));
    await tester.tap(find.text('Create new location here'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Kệ sách',
    );
    await tester.tap(find.text('Create'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final created = provider.boxes.firstWhere((b) => b.name == 'Kệ sách');
    expect(
      created.parentId,
      isNull,
      reason: 'created at the level being browsed (the root)',
    );
    expect(
      created.label,
      matches(RegExp(r'^loc_[0-9a-f]{8}$')),
      reason: 'a real, unique label',
    );
    expect(provider.boxes.where((b) => b.label == created.label).length, 1);

    await tester.tap(find.text('Select Location'));
    await tester.pumpAndSettle();
    expect(
      picked?.id,
      created.id,
      reason: 'the new location is already selected',
    );
  });
}
