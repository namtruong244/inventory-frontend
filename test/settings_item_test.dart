import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/screens/item_create_screen.dart';
import 'package:inventory/screens/item_details_screen.dart';

void main() {
  testWidgets('ItemCreateScreen receives and displays defaultUnit and currency from settings', (tester) async {
    final provider = InventoryProvider();
    await provider.setCurrency('₫');
    await provider.setDefaultUnit('cái');

    await tester.pumpWidget(
      ChangeNotifierProvider<InventoryProvider>.value(
        value: provider,
        child: MaterialApp(
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: AppLocalizations.supportedLocales,

          home: Scaffold(
            body: ItemCreateScreen(boxId: 'box-1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check that unit text field is pre-filled with 'cái'
    final unitField = find.widgetWithText(TextFormField, 'cái');
    expect(unitField, findsWidgets);

    // The price lives under "More details"
    await tester.scrollUntilVisible(find.text('More details'), 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('More details'));
    await tester.pumpAndSettle();

    // Scroll down to check Price field uses currency symbol '₫'
    await tester.drag(find.byType(ListView).first, const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(find.text('Purchase Price (₫)'), findsOneWidget);
  });

  testWidgets('ItemDetailsScreen formats price with currency from settings', (tester) async {
    final provider = InventoryProvider();
    await provider.setCurrency('€');

    final testItem = Item(
      id: 'item-eur',
      name: 'Espresso Machine',
      boxId: 'box-1',
      purchasePrice: 450.0,
      unit: 'set',
    );
    await provider.addItem(testItem);

    // Details screen
    await tester.pumpWidget(
      ChangeNotifierProvider<InventoryProvider>.value(
        value: provider,
        child: MaterialApp(
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: AppLocalizations.supportedLocales,

          home: Scaffold(
            body: ItemDetailsScreen(itemId: 'item-eur'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Expect €450.00
    expect(find.text('€450.00'), findsOneWidget);
  });
}
