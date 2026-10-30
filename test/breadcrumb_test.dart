import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/l10n/app_localizations.dart';
import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/screens/box_details_screen.dart';
import 'package:inventory/services/offline_store.dart';
import 'package:inventory/widgets/breadcrumb_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'offline_flush_test.dart' show FakeApi;

void main() {
  late InventoryProvider provider;
  final root = Box(
    id: 'root',
    name: 'House',
    type: StorageType.room,
    label: 'R',
  );
  final cabinet = Box(
    id: 'cab',
    name: 'Cabinet',
    type: StorageType.cabinet,
    label: 'C',
    parentId: 'root',
  );
  final shelf = Box(
    id: 'shelf',
    name: 'Top shelf',
    type: StorageType.shelf,
    label: 'S',
    parentId: 'cab',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    OfflineStore.directoryProvider = () async => null;
    provider = InventoryProvider(api: FakeApi()..noBoxes = true);
    await provider.initializationFuture;
    for (final b in [root, cabinet, shelf]) {
      await provider.addBox(b);
    }
  });

  tearDown(() => provider.dispose());

  Widget app(Widget home) => ChangeNotifierProvider<InventoryProvider>.value(
    value: provider,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );

  testWidgets('a root location shows its own breadcrumb chip', (tester) async {
    await tester.pumpWidget(
      app(Scaffold(body: BreadcrumbBar(locationId: 'root'))),
    );
    expect(find.text('House'), findsOneWidget);
  });

  testWidgets('tapping an ancestor goes back to its open screen', (
    tester,
  ) async {
    await tester.pumpWidget(app(const BoxDetailsScreen(boxId: 'root')));
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(
      MaterialPageRoute(builder: (_) => const BoxDetailsScreen(boxId: 'cab')),
    );
    await tester.pumpAndSettle();
    nav.push(
      MaterialPageRoute(builder: (_) => const BoxDetailsScreen(boxId: 'shelf')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byType(BoxDetailsScreen, skipOffstage: false),
      findsNWidgets(3),
    );
    expect(OpenBoxRoutes.of('root'), isNotNull);

    // In the breadcrumb of the shelf screen, tap "House".
    await tester.tap(
      find
          .descendant(
            of: find.byType(BreadcrumbBar),
            matching: find.text('House'),
          )
          .last,
    );
    await tester.pumpAndSettle();

    expect(
      find.byType(BoxDetailsScreen, skipOffstage: false),
      findsOneWidget,
      reason: 'popped back, nothing stacked',
    );
    expect(find.text('House'), findsWidgets);
    expect(OpenBoxRoutes.of('shelf'), isNull);
    expect(OpenBoxRoutes.of('cab'), isNull);
  });

  testWidgets('an ancestor that is not open replaces the current screen', (
    tester,
  ) async {
    await tester.pumpWidget(app(const BoxDetailsScreen(boxId: 'shelf')));
    await tester.pumpAndSettle();
    // Only the shelf screen exists (opened e.g. from search): "Cabinet" is not on the stack.
    await tester.tap(
      find
          .descendant(
            of: find.byType(BreadcrumbBar),
            matching: find.text('Cabinet'),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.byType(BoxDetailsScreen, skipOffstage: false), findsOneWidget);
    expect(OpenBoxRoutes.of('cab'), isNotNull);
    expect(OpenBoxRoutes.of('shelf'), isNull);
  });
}
