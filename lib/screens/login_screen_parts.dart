part of 'login_screen.dart';

/// Google account sheet and OAuth button builders.
extension _LoginScreenParts on _LoginScreenState {

  Widget _buildGoogleAccountSelectorSheet(BuildContext sheetContext, {String? notice}) {
    return Material(
      color: context.colors.surface,
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
                color: context.colors.border,
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
                context.l10n.signInWithGoogle,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.chooseAnAccountToContinue,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: context.colors.textSecondary,
            ),
          ),
          if (notice != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.fill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: context.colors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notice,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: context.colors.textSecondary,
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
                color: context.colors.fill,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.border),
              ),
              child: Icon(Icons.person_add_alt_1_rounded, size: 20, color: context.colors.textPrimary),
            ),
            title: Text(
              context.l10n.useAnotherGmailAccount,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            subtitle: Text(
              context.l10n.enterCustomGmailComAddress,
              style: GoogleFonts.inter(fontSize: 12, color: context.colors.textSecondary),
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
          color: context.colors.textPrimary,
        ),
      ),
      subtitle: Text(
        email,
        style: GoogleFonts.inter(fontSize: 12, color: context.colors.textSecondary),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.colors.textMuted),
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
              context.l10n.enterGmailAccount,
              style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: customNameCtrl,
              decoration: InputDecoration(
                labelText: context.l10n.yourName,
                hintText: context.l10n.eGJohnDoe,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: customEmailCtrl,
              decoration: InputDecoration(
                labelText: context.l10n.gmailAddress,
                hintText: 'username@gmail.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.commonCancel),
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
              backgroundColor: context.colors.primary,
            ),
            child: Text(context.l10n.commonContinue),
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
          context.l10n.resetPassword,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          email.isNotEmpty
              ? context.l10n.aPasswordResetLinkWill(email)
              : context.l10n.pleaseEnterYourEmailAddress,
          style: GoogleFonts.inter(fontSize: 14, color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.commonCancel,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: context.colors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              AppFeedback.showSuccess(
                context,
                email.isNotEmpty
                    ? context.l10n.passwordResetEmailSentTo(email)
                    : context.l10n.passwordResetInstructionsSent,
              );
            },
            child: Text(
              context.l10n.sendLink,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
