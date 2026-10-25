import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/screens/home_screen.dart';
import 'package:inventory/screens/login_screen.dart';
import 'package:inventory/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen displays branding and navigates to LoginScreen when unauthenticated',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => InventoryProvider(),
        child: const MaterialApp(
          home: SplashScreen(),
        ),
      ),
    );

    // Initial frame rendered on SplashScreen
    await tester.pump();

    // Verify app title and subtitle in English
    expect(find.text('Personal Inventory'), findsOneWidget);
    expect(find.text('Smart inventory & asset tracker'), findsOneWidget);

    // Verify progress indicator is present
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);

    // Advance time past minimum display duration and bootstrap
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();

    // Verify smooth transition to LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('SplashScreen navigates directly to HomeScreen when already authenticated',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'inventory_auth_token': 'mock_saved_token',
      'inventory_auth_user': '{"id":"u1","name":"Sara Wilson","email":"sara@example.com","role":"Owner"}',
    });

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => InventoryProvider(),
        child: const MaterialApp(
          home: SplashScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();

    // Verify transition to HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
