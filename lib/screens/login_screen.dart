import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/google_logo.dart';
import '../utils/friendly_error.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../widgets/app_icon.dart';

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
        // The user closing the Google prompt is not an error.
        if (e.code == GoogleSignInExceptionCode.canceled) return;
        debugPrint('google sign-in error: ${e.code.name} ${e.description}');
        AppFeedback.showError(context, context.l10n.couldnTSignInWith);
      }
    } catch (e) {
      debugPrint('google sign-in error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        AppFeedback.showError(context, friendlyError(e, fallback: context.l10n.couldnTSignInWith));
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
        AppFeedback.showSuccess(context, context.l10n.signedInAs(email));
        _navigateToHome();
      } else {
        AppFeedback.showError(
          context,
          provider.errorMessage ?? context.l10n.googleAuthenticationFailed,
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
        AppFeedback.showSuccess(
          context,
          _isRegisterMode
              ? context.l10n.welcomeUser(provider.userName)
              : context.l10n.welcomeBack(provider.userName),
        );
        _navigateToHome();
      } else {
        AppFeedback.showError(
          context,
          provider.errorMessage ?? context.l10n.authenticationFailed,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.colors.background,
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
                            color: context.colors.accent,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: AppIcon(
                              Icons.inventory_2_rounded,
                              size: 34,
                              color: context.colors.onAccent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Title & Subtitle
                      Text(
                        'Personal Inventory',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.signInToSyncYour,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 1. Google Sign-In Button
                      _buildOAuthButton(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        leading: const GoogleLogoWidget(size: 22),
                        label: context.l10n.continueWithGoogle,
                        backgroundColor: context.colors.surface,
                        textColor: context.colors.textPrimary,
                        borderColor: context.colors.border,
                      ),
                      const SizedBox(height: 24),

                      // Divider with "or continue with email"
                      Row(
                        children: [
                          Expanded(child: Divider(color: context.colors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0),
                            child: Text(
                              'or continue with email',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: context.colors.textMuted,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: context.colors.border)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Form: Name (Register Mode only)
                      if (_isRegisterMode) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: context.l10n.fullName,
                            hintText: 'John Doe',
                            prefixIcon: const AppIcon(Icons.person_outline_rounded, size: 20),
                            fillColor: context.colors.surface,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: context.colors.border),
                            ),
                          ),
                          validator: (val) {
                            if (_isRegisterMode && (val == null || val.trim().isEmpty)) {
                              return context.l10n.pleaseEnterYourName;
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
                          labelText: context.l10n.emailAddress,
                          hintText: 'name@example.com',
                          prefixIcon: const AppIcon(Icons.mail_outline_rounded, size: 20),
                          fillColor: context.colors.surface,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.colors.border),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return context.l10n.pleaseEnterYourEmail;
                          }
                          if (!val.contains('@') || !val.contains('.')) {
                            return context.l10n.pleaseEnterAValidEmail;
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
                          labelText: context.l10n.commonPassword,
                          hintText: '••••••••',
                          prefixIcon: const AppIcon(Icons.lock_outline_rounded, size: 20),
                          suffixIcon: IconButton(
 tooltip: context.l10n.showOrHidePassword,
                            icon: AppIcon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: context.colors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          fillColor: context.colors.surface,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.colors.border),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return context.l10n.passwordIsRequired;
                          }
                          // Login accepts older 6-7 character passwords; only new ones need 8.
                          if (_isRegisterMode && val.length < 8) {
                            return context.l10n.passwordMustBeAtLeast;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Primary Submit Button
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _handleEmailPasswordAuth,
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colors.primary,
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
                                  _isRegisterMode ? context.l10n.createAccount : context.l10n.signIn,
                                  style: GoogleFonts.plusJakartaSans(
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
                              ? context.l10n.alreadyHaveAnAccountSign
                              : context.l10n.donTHaveAnAccount,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTones.sky,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Terms & Policy (WCAG AA compliant contrast #6B7280)
                      Text(
                        context.l10n.byContinuingYouAgreeTo,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTones.slate,
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
