import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/screens/home_screen.dart';
import 'package:inventory/screens/login_screen.dart';
import 'package:inventory/services/offline_store.dart';

void main() {
  setUp(() {
    // No platform channels in widget tests: keep the snapshot in SharedPreferences.
    OfflineStore.directoryProvider = () async => null;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  Widget buildTestLoginApp() {
    return ChangeNotifierProvider(
      create: (_) => InventoryProvider(),
      child: MaterialApp(
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: AppLocalizations.supportedLocales,

        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen UI & Social Login', () {
    testWidgets('renders all authentication options (Google, Email)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestLoginApp());
      await tester.pumpAndSettle();

      // App Branding
      expect(find.text('Personal Inventory'), findsOneWidget);
      expect(
        find.text('Sign in to sync your inventory & assets across devices'),
        findsOneWidget,
      );

      // Google Sign-In button
      expect(find.text('Continue with Google'), findsOneWidget);

      // Apple Sign-In has been removed
      expect(find.text('Sign in with Apple'), findsNothing);

      // Email & Password Fields
      expect(find.text('or continue with email'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Guest mode was removed: the backend has no anonymous users
      expect(find.text('Continue as Guest'), findsNothing);
    });

    testWidgets('toggle between Sign In and Sign Up modes',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestLoginApp());
      await tester.pumpAndSettle();

      // Initially in Sign In mode
      expect(find.text("Don't have an account? Sign up"), findsOneWidget);
      expect(find.text('Full Name'), findsNothing);

      // Tap toggle to register mode
      await tester.tap(find.text("Don't have an account? Sign up"));
      await tester.pumpAndSettle();

      // In Register mode
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Already have an account? Sign in'), findsOneWidget);
    });

    testWidgets('tapping Google button opens Google account selector sheet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestLoginApp());
      await tester.pumpAndSettle();

      // Tap Google button
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      // Verify Google sheet content
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Choose an account to continue to Personal Inventory'), findsOneWidget);
      expect(find.text('sara.wilson@gmail.com'), findsOneWidget);
      expect(find.text('alex.turner@gmail.com'), findsOneWidget);
      expect(find.text('Use another Gmail account'), findsOneWidget);
    });

    testWidgets('selecting Google account logs in and navigates to HomeScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestLoginApp());
      await tester.pumpAndSettle();

      // Open Google sheet
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      // Select Alex Turner account
      await tester.tap(find.text('alex.turner@gmail.com'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify navigated to HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
