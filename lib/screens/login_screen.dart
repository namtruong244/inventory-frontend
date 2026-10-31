import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/app_form_field.dart';
import '../widgets/soft_ui.dart';
import '../widgets/tappable.dart';
import '../utils/e2e.dart';
import '../utils/friendly_error.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../widgets/app_icon.dart';

/// Screen allowing authentication with Google (Gmail) or Email/Password

class LoginScreen extends StatefulWidget {
  final bool autoOpenGoogle;
  const LoginScreen({super.key, this.autoOpenGoogle = false});

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
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
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
      final name =
          (account.displayName != null &&
              account.displayName!.trim().isNotEmpty)
          ? account.displayName!
          : email.split('@').first;
      final avatarUrl = account.photoUrl;

      String? accessToken;
      try {
        final clientAuth = await account.authorizationClient
            .authorizationForScopes(const [
              'email',
              'https://www.googleapis.com/auth/userinfo.profile',
            ]);
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
        AppFeedback.showError(
          context,
          friendlyError(e, fallback: context.l10n.couldnTSignInWith),
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

  void _setMode(bool register) {
    if (_isRegisterMode == register) return;
    setState(() => _isRegisterMode = register);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final linkStyle = TextStyle(
      fontSize: 13,
      color: c.textSecondary,
      fontWeight: FontWeight.w500,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: AppMark(size: 56),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        _isRegisterMode
                            ? l.loginCreateTitle
                            : l.loginWelcomeBack,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isRegisterMode ? l.loginCreateSub : l.signInToSyncYour,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: c.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 22),
                      AuthModeSwitch(
                        registerMode: _isRegisterMode,
                        onChanged: _setMode,
                      ),
                      const SizedBox(height: 22),
                      if (_isRegisterMode) ...[
                        AppFormField(
                          id: 'login_name',
                          label: l.fullName,
                          hintText: 'John Doe',
                          textInputAction: TextInputAction.next,
                          prefixIcon: const _FieldIcon(
                            Icons.person_outline_rounded,
                          ),
                          controller: _nameController,
                          validator: (val) {
                            if (_isRegisterMode &&
                                (val == null || val.trim().isEmpty)) {
                              return l.pleaseEnterYourName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                      ],
                      AppFormField(
                        id: 'login_email',
                        label: l.emailAddress,
                        hintText: 'name@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const _FieldIcon(
                          Icons.mail_outline_rounded,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return l.pleaseEnterYourEmail;
                          }
                          if (!val.contains('@') || !val.contains('.')) {
                            return l.pleaseEnterAValidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _PasswordField(
                        controller: _passwordController,
                        obscure: _obscurePassword,
                        onToggle: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        isRegister: _isRegisterMode,
                      ),
                      const SizedBox(height: 22),
                      e2eId(
                        'login_submit',
                        SoftButton(
                          label: _isRegisterMode ? l.createAccount : l.signIn,
                          onPressed: _isLoading
                              ? null
                              : _handleEmailPasswordAuth,
                          loading: _isLoading,
                          expand: true,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(child: Divider(color: c.border, height: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              l.loginOr,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: c.textMuted,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: c.border, height: 1)),
                        ],
                      ),
                      const SizedBox(height: 22),
                      GoogleAuthButton(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                      ),
                      const SizedBox(height: 22),
                      Text(
                        l.byContinuingYouAgreeTo,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: c.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      e2eId(
                        'login_toggle_mode',
                        Tappable(
                          onTap: () => _setMode(!_isRegisterMode),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text.rich(
                              textAlign: TextAlign.center,
                              TextSpan(
                                style: linkStyle,
                                children: [
                                  TextSpan(
                                    text: _isRegisterMode
                                        ? l.loginHaveAccountQ
                                        : l.loginNoAccountQ,
                                  ),
                                  const TextSpan(text: ' '),
                                  TextSpan(
                                    text: _isRegisterMode
                                        ? l.loginSignInLink
                                        : l.loginCreateOneLink,
                                    style: TextStyle(
                                      color: c.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

class _FieldIcon extends StatelessWidget {
  final IconData icon;
  const _FieldIcon(this.icon);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 16, right: 10),
    child: AppIcon(icon, size: 18, color: context.colors.textMuted),
  );
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final bool isRegister;
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.isRegister,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppFormField(
      id: 'login_password',
      label: l.commonPassword,
      hintText: '••••••••',
      controller: controller,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      prefixIcon: const _FieldIcon(Icons.lock_outline_rounded),
      suffixIcon: IconButton(
        tooltip: l.showOrHidePassword,
        icon: AppIcon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 18,
          color: context.colors.textMuted,
        ),
        onPressed: onToggle,
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return l.passwordIsRequired;
        // Login accepts older 6-7 character passwords; only new ones need 8.
        if (isRegister && val.length < 8) return l.passwordMustBeAtLeast;
        return null;
      },
    );
  }
}
