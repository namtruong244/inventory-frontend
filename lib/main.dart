import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'l10n/l10n_ext.dart';
import 'providers/inventory_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/auto_sync.dart';
import 'widgets/session_guard.dart';
import 'widgets/sync_status_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Plus Jakarta Sans ships in assets/google_fonts; never fetch it over the network.
  GoogleFonts.config.allowRuntimeFetching = false;
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness:
          Brightness.dark, // light icons initially for dark top header
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => InventoryProvider())],
      child: const InventoryApp(),
    ),
  );
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<InventoryProvider, ThemeMode>(
      (p) => p.themeMode,
    );
    final locale = context.select<InventoryProvider, Locale?>((p) => p.locale);

    return MaterialApp(
      title: 'Personal Inventory',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return SessionGuard(
          child: AutoSync(
            child: SyncStatusBar(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                // Below Localizations: lets context-free code (provider, models,
                // error mapping) use the language currently shown.
                child: Builder(
                  builder: (ctx) {
                    AppL10n.sync(ctx);
                    return child ?? const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        );
      },
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
