import '../theme/app_theme.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import '../l10n/l10n_ext.dart';
import '../utils/e2e.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/soft_ui.dart';

/// Minimalist Splash Screen with clean typography and seamless initialization
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  Timer? _safetyTimer;
  Timer? _manualContinueTimer;
  bool _hasNavigated = false;
  bool _showManualContinue = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();

    // Show manual continue option if network call takes longer than 3.5s
    _manualContinueTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted && !_hasNavigated) {
        setState(() {
          _showManualContinue = true;
        });
      }
    });

    // Safety timeout: transition after 5s max
    _safetyTimer = Timer(const Duration(milliseconds: 5000), () {
      _navigateToNext();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapApp();
    });
  }

  Future<void> _bootstrapApp() async {
    final provider = context.read<InventoryProvider>();

    // 1. Minimum display duration of 1200ms for smooth branding presentation
    final minDisplayFuture = Future.delayed(const Duration(milliseconds: 1200));

    // 2. Await actual API initialization with a timeout
    final initFuture = provider.initializationFuture.timeout(
      const Duration(milliseconds: 4000),
      onTimeout: () {
        debugPrint(
          'Splash: provider initialization timeout, proceeding to next screen.',
        );
      },
    );

    await Future.wait([minDisplayFuture, initFuture]);

    if (mounted) {
      _navigateToNext();
    }
  }

  void _navigateToNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    _safetyTimer?.cancel();
    _manualContinueTimer?.cancel();

    final provider = context.read<InventoryProvider>();
    final targetWidget = provider.isAuthenticated
        ? const HomeScreen()
        : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => targetWidget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _manualContinueTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SplashMarkCluster(),
                          const SizedBox(height: 20),
                          Text(
                            'Smart Inventory',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            context.l10n.splashTagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 15,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 52,
                        child: _showManualContinue
                            ? e2eId(
                                'splash_continue',
                                SoftButton(
                                  label: context.l10n.continueToApp,
                                  onPressed: _navigateToNext,
                                  expand: true,
                                ),
                              )
                            : Consumer<InventoryProvider>(
                                builder: (context, provider, _) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      height: 3,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          backgroundColor: c.fill,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                c.accentStrong,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      provider.initStatus,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: c.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          color: c.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
