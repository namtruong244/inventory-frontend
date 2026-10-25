part of 'login_screen.dart';

/// Google account sheet and OAuth button builders.
extension _LoginScreenParts on _LoginScreenState {

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
}
