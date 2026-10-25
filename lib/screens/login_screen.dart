import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/google_logo.dart';
import 'home_screen.dart';

/// Screen allowing authentication with Google (Gmail) or Email/Password
part 'login_screen_parts.dart';

class LoginScreen extends StatefulWidget {
  final bool autoOpenGoogle;
  const LoginScreen({
    super.key,
    this.autoOpenGoogle = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  static bool _googleInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoOpenGoogle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleGoogleSignIn();
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  // ==========================================
  // GOOGLE SIGN-IN HANDLER
  // ==========================================
  Future<void> _handleGoogleSignIn() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      if (!_googleInitialized) {
        await GoogleSignIn.instance.initialize();
        _googleInitialized = true;
      }

      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );

      final idToken = account.authentication.idToken;
      final email = account.email;
      final name = (account.displayName != null && account.displayName!.trim().isNotEmpty)
          ? account.displayName!
          : email.split('@').first;
      final avatarUrl = account.photoUrl;

      String? accessToken;
      try {
        final clientAuth = await account.authorizationClient.authorizationForScopes(
          const ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
        );
        accessToken = clientAuth?.accessToken;
      } catch (_) {}

      if (mounted) {
        await _executeGoogleLogin(
          email: email,
          name: name,
          avatarUrl: avatarUrl,
          idToken: idToken,
          accessToken: accessToken,
        );
      }
    } on GoogleSignInException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (e.code == GoogleSignInExceptionCode.canceled) {
          // User intentionally closed/cancelled the Google prompt
          return;
        }
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => _buildGoogleAccountSelectorSheet(
            ctx,
            notice: 'Google Sign-In: ${e.description ?? e.code.name}. You can also pick a demo account below.',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => _buildGoogleAccountSelectorSheet(
            ctx,
            notice: e.toString().contains('PlatformException')
                ? 'Google Sign-In: Configure GIDClientID in Info.plist for live Google account. You can also pick a demo account below.'
                : null,
          ),
        );
      }
    }
  }

  Future<void> _executeGoogleLogin({
    required String email,
    required String name,
    String? avatarUrl,
    String? idToken,
    String? accessToken,
  }) async {
    setState(() => _isLoading = true);
    final provider = context.read<InventoryProvider>();
    final success = await provider.loginWithGoogle(
      email: email,
      name: name,
      avatarUrl: avatarUrl,
      idToken: idToken,
      accessToken: accessToken,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        AppFeedback.showSuccess(context, 'Signed in as $email');
        _navigateToHome();
      } else {
        AppFeedback.showError(
          context,
          provider.errorMessage ?? 'Google authentication failed',
        );
      }
    }
  }

  // ==========================================
  // EMAIL / PASSWORD LOGIN HANDLER
  // ==========================================
  Future<void> _handleEmailPasswordAuth() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    setState(() => _isLoading = true);
    final provider = context.read<InventoryProvider>();

    bool success = false;
    if (_isRegisterMode) {
      success = await provider.register(
        name.isNotEmpty ? name : email.split('@').first,
        email,
        password,
      );
    } else {
      success = await provider.login(email, password);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        AppFeedback.showSuccess(context, 'Welcome back, ${provider.userName}!');
        _navigateToHome();
      } else {
        AppFeedback.showError(
          context,
          provider.errorMessage ?? 'Authentication failed',
        );
      }
    }
  }

  // ==========================================
  // FORGOT PASSWORD HANDLER
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App Icon
                      Center(
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFF18181B),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.inventory_2_rounded,
                              size: 34,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Title & Subtitle
                      Text(
                        'Personal Inventory',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: const Color(0xFF18181B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to sync your inventory & assets across devices',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF71717A),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 1. Google Sign-In Button
                      _buildOAuthButton(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        leading: const GoogleLogoWidget(size: 22),
                        label: 'Continue with Google',
                        backgroundColor: Colors.white,
                        textColor: const Color(0xFF18181B),
                        borderColor: const Color(0xFFE4E4E7),
                      ),
                      const SizedBox(height: 24),

                      // Divider with "or continue with email"
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFE4E4E7))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0),
                            child: Text(
                              'or continue with email',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFA1A1AA),
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFE4E4E7))),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Form: Name (Register Mode only)
                      if (_isRegisterMode) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'John Doe',
                            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                            ),
                          ),
                          validator: (val) {
                            if (_isRegisterMode && (val == null || val.trim().isEmpty)) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Form: Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'name@example.com',
                          prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!val.contains('@') || !val.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Form: Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: const Color(0xFF71717A),
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      if (!_isRegisterMode) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _handleForgotPassword,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot password?',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF52525B),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Primary Submit Button
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _handleEmailPasswordAuth,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF18181B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _isRegisterMode ? 'Create Account' : 'Sign In',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Switch between Sign In / Register
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isRegisterMode = !_isRegisterMode;
                          });
                        },
                        child: Text(
                          _isRegisterMode
                              ? 'Already have an account? Sign in'
                              : "Don't have an account? Sign up",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Terms & Policy (WCAG AA compliant contrast #6B7280)
                      Text(
                        'By continuing, you agree to our Terms of Service & Privacy Policy',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
