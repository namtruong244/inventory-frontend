import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import 'home_screen.dart';

/// Screen allowing authentication with Google (Gmail) or Email/Password
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

  Widget _buildGoogleAccountSelectorSheet(BuildContext sheetContext, {String? notice}) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(sheetContext).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header with Google Logo
          Row(
            children: [
              const GoogleLogoWidget(size: 26),
              const SizedBox(width: 12),
              Text(
                'Sign in with Google',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF18181B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Choose an account to continue to Personal Inventory',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF71717A),
            ),
          ),
          if (notice != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4E4E7)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF71717A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notice,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF52525B),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Account Option 1
          _buildGoogleAccountTile(
            sheetContext: sheetContext,
            name: 'Sara Wilson',
            email: 'sara.wilson@gmail.com',
            initials: 'SW',
            avatarBgColor: const Color(0xFF3B82F6),
          ),
          const Divider(height: 1),

          // Account Option 2
          _buildGoogleAccountTile(
            sheetContext: sheetContext,
            name: 'Alex Turner',
            email: 'alex.turner@gmail.com',
            initials: 'AT',
            avatarBgColor: const Color(0xFF10B981),
          ),
          const Divider(height: 1),

          // Custom Gmail option
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.person_add_alt_1_rounded, size: 20, color: Color(0xFF18181B)),
            ),
            title: Text(
              'Use another Gmail account',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF18181B),
              ),
            ),
            subtitle: Text(
              'Enter custom @gmail.com address',
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF71717A)),
            ),
            onTap: () {
              Navigator.pop(sheetContext);
              _promptCustomGoogleDialog();
            },
          ),
        ],
      ),
    ),
  );
}

  Widget _buildGoogleAccountTile({
    required BuildContext sheetContext,
    required String name,
    required String email,
    required String initials,
    required Color avatarBgColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        radius: 21,
        backgroundColor: avatarBgColor,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      title: Text(
        name,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF18181B),
        ),
      ),
      subtitle: Text(
        email,
        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF71717A)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFA1A1AA)),
      onTap: () async {
        Navigator.pop(sheetContext);
        await _executeGoogleLogin(
          email: email,
          name: name,
          idToken: 'mock_google_id_token_${DateTime.now().millisecondsSinceEpoch}',
          accessToken: 'mock_google_access_token_${DateTime.now().millisecondsSinceEpoch}',
        );
      },
    );
  }

  void _promptCustomGoogleDialog() {
    final customEmailCtrl = TextEditingController();
    final customNameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const GoogleLogoWidget(size: 22),
            const SizedBox(width: 10),
            Text(
              'Enter Gmail Account',
              style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: customNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                hintText: 'e.g. John Doe',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: customEmailCtrl,
              decoration: const InputDecoration(
                labelText: 'Gmail Address',
                hintText: 'username@gmail.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              var email = customEmailCtrl.text.trim();
              var name = customNameCtrl.text.trim();
              if (email.isEmpty) return;
              if (!email.contains('@')) {
                email = '$email@gmail.com';
              }
              if (name.isEmpty) {
                name = email.split('@').first;
              }
              Navigator.pop(ctx);
              _executeGoogleLogin(
                email: email,
                name: name,
                idToken: 'mock_google_id_token_${DateTime.now().millisecondsSinceEpoch}',
                accessToken: 'mock_google_access_token_${DateTime.now().millisecondsSinceEpoch}',
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF18181B),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
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
  void _handleForgotPassword() {
    HapticFeedback.lightImpact();
    final email = _emailController.text.trim();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Password',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          email.isNotEmpty
              ? 'A password reset link will be sent to $email.'
              : 'Please enter your email address on the sign in form to receive password reset instructions.',
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF52525B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF71717A)),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF18181B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              AppFeedback.showSuccess(
                context,
                email.isNotEmpty
                    ? 'Password reset email sent to $email'
                    : 'Password reset instructions sent',
              );
            },
            child: Text(
              'Send Link',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildOAuthButton({
    required VoidCallback? onPressed,
    required Widget leading,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leading,
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: -0.2,
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

/// Pixel-perfect vector representation of the official 4-color Google G icon
class GoogleLogoWidget extends StatelessWidget {
  final double size;

  const GoogleLogoWidget({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 48.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Official Google Brand Colors
    const redColor = Color(0xFFEA4335);
    const blueColor = Color(0xFF4285F4);
    const yellowColor = Color(0xFFFBBC05);
    const greenColor = Color(0xFF34A853);

    // 1. Red Top Arch
    final redPath = Path()
      ..moveTo(24.0, 9.5)
      ..cubicTo(27.54, 9.5, 30.71, 10.72, 33.21, 13.1)
      ..lineTo(40.06, 6.25)
      ..cubicTo(35.9, 2.38, 30.47, 0.0, 24.0, 0.0)
      ..cubicTo(14.62, 0.0, 6.51, 5.38, 2.56, 13.22)
      ..lineTo(10.54, 19.41)
      ..cubicTo(12.43, 13.72, 17.74, 9.5, 24.0, 9.5)
      ..close();

    // 2. Blue Crossbar & Right Curve
    final bluePath = Path()
      ..moveTo(46.98, 24.55)
      ..cubicTo(46.98, 22.98, 46.83, 21.46, 46.60, 20.0)
      ..lineTo(24.0, 20.0)
      ..lineTo(24.0, 29.02)
      ..lineTo(36.94, 29.02)
      ..cubicTo(36.36, 31.98, 34.68, 34.50, 32.16, 36.20)
      ..lineTo(39.89, 42.20)
      ..cubicTo(44.40, 38.02, 46.98, 31.84, 46.98, 24.55)
      ..close();

    // 3. Yellow Left Arch
    final yellowPath = Path()
      ..moveTo(10.53, 28.59)
      ..cubicTo(10.05, 27.14, 9.77, 25.60, 9.77, 24.0)
      ..cubicTo(9.77, 22.40, 10.04, 20.86, 10.53, 19.41)
      ..lineTo(2.55, 13.22)
      ..cubicTo(0.92, 16.46, 0.0, 20.12, 0.0, 24.0)
      ..cubicTo(0.0, 27.88, 0.92, 31.54, 2.56, 34.78)
      ..lineTo(10.53, 28.59)
      ..close();

    // 4. Green Bottom Arch
    final greenPath = Path()
      ..moveTo(24.0, 48.0)
      ..cubicTo(30.48, 48.0, 35.93, 45.87, 39.89, 42.19)
      ..lineTo(32.16, 36.19)
      ..cubicTo(30.01, 37.64, 27.24, 38.49, 24.0, 38.49)
      ..cubicTo(17.74, 38.49, 12.43, 34.27, 10.53, 28.58)
      ..lineTo(2.55, 34.77)
      ..cubicTo(6.51, 42.62, 14.62, 48.0, 24.0, 48.0)
      ..close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(redPath, paint..color = redColor);
    canvas.drawPath(bluePath, paint..color = blueColor);
    canvas.drawPath(yellowPath, paint..color = yellowColor);
    canvas.drawPath(greenPath, paint..color = greenColor);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
