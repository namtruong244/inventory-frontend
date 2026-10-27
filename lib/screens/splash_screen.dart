import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import '../l10n/l10n_ext.dart';

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
        debugPrint('Splash: provider initialization timeout, proceeding to next screen.');
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
    final targetWidget = provider.isAuthenticated ? const HomeScreen() : const LoginScreen();

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
    const primaryDark = Color(0xFF18181B);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark, // iOS: white icons
        statusBarIconBrightness: Brightness.light, // Android: white icons
      ),
      child: Scaffold(
        backgroundColor: primaryDark,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Minimalist App Icon Container
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.inventory_2_rounded,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // App Title
                    Text(
                      'Personal Inventory',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subtitle in English
                    Text(
                      context.l10n.splashTagline,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFA1A1AA),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Minimalist Progress & Status
                    Consumer<InventoryProvider>(
                      builder: (context, provider, _) {
                        return Column(
                          children: [
                            SizedBox(
                              width: 90,
                              height: 2.5,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: const LinearProgressIndicator(
                                  backgroundColor: Color(0xFF27272A),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF3B82F6),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 18,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  provider.initStatus,
                                  key: ValueKey(provider.initStatus),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF71717A),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    // Minimalist manual continue button if slow
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: _showManualContinue ? 1.0 : 0.0,
                      child: _showManualContinue
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: TextButton(
                                onPressed: _navigateToNext,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  context.l10n.continueToApp,
                                  style: const TextStyle(
                                    color: Color(0xFF60A5FA),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(height: 28),
                    ),

                    const Spacer(flex: 2),

                    // Minimal Footer
                    Text(
                      'v1.0.0',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF52525B),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
