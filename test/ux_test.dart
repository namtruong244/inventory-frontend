import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/l10n/app_localizations.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/services/api_service.dart';
import 'package:inventory/services/offline_store.dart';
import 'package:inventory/utils/friendly_error.dart';
import 'package:inventory/widgets/sync_status_bar.dart';
import 'package:inventory/widgets/tappable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'offline_flush_test.dart' show FakeApi;

ApiException apiError(int status, String code, [String message = 'm']) =>
    ApiException(statusCode: status, code: code, message: message);

Widget app(Widget home, {InventoryProvider? provider, double scale = 1}) {
  final app = MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: home,
  );
  return provider == null
      ? app
      : ChangeNotifierProvider<InventoryProvider>.value(
          value: provider,
          child: app,
        );
}

/// Lets the provider's real async work (prefs, fake API) finish inside a widget test.
Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pump(const Duration(seconds: 1)); // provider start-up delay
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    OfflineStore.directoryProvider = () async => null;
  });

  group('friendlyError', () {
    test('never leaks raw exception text', () {
      expect(
        friendlyError(apiError(401, 'AUTH_FAILED')),
        'Incorrect email or password.',
      );
      expect(
        friendlyError(apiError(500, 'INTERNAL_ERROR', 'pq: deadlock')),
        isNot(contains('pq')),
      );
      expect(friendlyError(apiError(429, 'X')), contains('Too many'));
      expect(
        friendlyError(apiError(404, 'NOT_FOUND')),
        contains('no longer exists'),
      );
      expect(
        friendlyError(Exception('boom')),
        'Something went wrong. Please try again.',
      );
    });

    test('short 4xx backend messages are kept, long ones are not', () {
      expect(
        friendlyError(apiError(400, 'INVALID_INPUT', 'Name is required')),
        'Name is required',
      );
      expect(
        friendlyError(apiError(400, 'INVALID_INPUT', 'x' * 300)),
        isNot(contains('xxxx')),
      );
    });
  });

  group('device preferences', () {
    test('theme and language persist and follow system when cleared', () async {
      final provider = InventoryProvider(api: FakeApi());
      await provider.initializationFuture;
      expect(provider.themeMode, ThemeMode.light);
      expect(provider.locale, isNull);

      await provider.setThemeMode(ThemeMode.dark);
      await provider.setLocale('vi');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(InventoryProvider.themePrefKey), 'dark');
      expect(prefs.getString(InventoryProvider.localePrefKey), 'vi');

      final again = InventoryProvider(api: FakeApi());
      await again.initializationFuture;
      await again.loadDevicePreferences();
      expect(again.themeMode, ThemeMode.dark);
      expect(again.locale, const Locale('vi'));

      await again.setLocale(null);
      expect(prefs.getString(InventoryProvider.localePrefKey), isNull);
      provider.dispose();
      again.dispose();
    });
  });

  group('SyncStatusBar', () {
    testWidgets('is hidden online and shown offline on any screen', (
      tester,
    ) async {
      final api = FakeApi();
      final provider = InventoryProvider(api: api);
      await settle(tester);

      await tester.pumpWidget(
        app(
          const SyncStatusBar(child: Scaffold(body: Text('screen'))),
          provider: provider,
        ),
      );
      expect(find.text('Offline'), findsNothing);

      api.reachable = false;
      await tester.runAsync(provider.fetchAllData);
      await settle(tester);
      await tester.pump();
      expect(provider.isOffline, isTrue);
      expect(find.textContaining('Offline'), findsOneWidget);
      expect(find.text('screen'), findsOneWidget);
      provider.dispose();
    });
  });

  group('accessibility', () {
    testWidgets('Tappable is announced as a labelled button', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        app(
          Scaffold(
            body: Center(
              child: Tappable(
                semanticLabel: 'Open filters',
                onTap: () => taps++,
                child: const Icon(Icons.tune),
              ),
            ),
          ),
        ),
      );

      final node = tester.getSemantics(find.bySemanticsLabel('Open filters'));
      expect(node.flagsCollection.isButton, isTrue);
      await tester.tap(find.byType(Tappable));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('layout survives 2x text scale without overflow', (
      tester,
    ) async {
      final provider = InventoryProvider(api: FakeApi());
      await settle(tester);
      await tester.binding.setSurfaceSize(const Size(360, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        app(
          const SyncStatusBar(child: Scaffold(body: Text('screen'))),
          provider: provider,
          scale: 2,
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      provider.dispose();
    });
  });
}
