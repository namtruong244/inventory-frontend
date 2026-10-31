import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../providers/inventory_provider.dart';
import '../screens/login_screen.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_feedback.dart';
import 'app_icon.dart';
import 'soft_ui.dart';

/// Design ConfirmDialog shell: 48px icon tile, title, body, optional [extra]
/// (e.g. a text field) and a Cancel / confirm button row.
class _AccountDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Widget? extra;
  final Widget cancel;
  final Widget confirm;

  const _AccountDialog({
    required this.icon,
    required this.title,
    required this.body,
    this.extra,
    required this.cancel,
    required this.confirm,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Dialog(
      backgroundColor: c.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.dangerSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: AppIcon(icon, size: 22, color: c.dangerStrong),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.45,
                color: c.textSecondary,
              ),
            ),
            ?extra,
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: cancel),
                const SizedBox(width: 10),
                Expanded(child: confirm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _toLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

/// Log out, with a second prompt when changes have not been uploaded yet.
Future<void> showLogoutDialog(
  BuildContext context,
  InventoryProvider provider,
) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _AccountDialog(
      icon: Icons.logout_rounded,
      title: context.l10n.logOut,
      body: context.l10n.areYouSureYouWant,
      cancel: e2eId(
        'settings_logout_cancel',
        SoftButton(
          label: context.l10n.commonCancel,
          icon: Icons.close_rounded,
          style: SoftButtonStyle.secondary,
          expand: true,
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
      confirm: e2eId(
        'settings_logout_confirm',
        SoftButton(
          label: context.l10n.logOut2,
          style: SoftButtonStyle.danger,
          expand: true,
          onPressed: () async {
            Navigator.pop(ctx);
            var loggedOut = await provider.logout();
            if (!loggedOut && context.mounted) {
              final discard = await AppFeedback.showConfirmDialog(
                context,
                title: context.l10n.unsyncedChanges,
                message:
                    '${provider.pendingChanges} change(s) have not been uploaded yet and will be lost if you log out. Log out anyway?',
                confirmLabel: context.l10n.discardLogOut,
                isDestructive: true,
              );
              if (!discard) return;
              loggedOut = await provider.logout(force: true);
            }
            if (loggedOut && context.mounted) _toLogin(context);
          },
        ),
      ),
    ),
  );
}

/// Delete account: explanation plus a "type DELETE" field in one dialog.
Future<void> showDeleteAccountDialog(
  BuildContext context,
  InventoryProvider provider,
) {
  return showDialog<void>(
    context: context,
    builder: (ctx) =>
        _DeleteAccountDialog(parentContext: context, provider: provider),
  );
}

class _DeleteAccountDialog extends StatefulWidget {
  final BuildContext parentContext;
  final InventoryProvider provider;

  const _DeleteAccountDialog({
    required this.parentContext,
    required this.provider,
  });

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _confirmed => _controller.text.trim() == 'DELETE';

  Future<void> _delete() async {
    final parent = widget.parentContext;
    Navigator.pop(context);
    final error = await widget.provider.deleteAccount();
    if (!parent.mounted) return;
    if (error != null) {
      AppFeedback.showError(parent, error);
      return;
    }
    _toLogin(parent);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _AccountDialog(
      icon: Icons.person_remove_outlined,
      title: context.l10n.deleteAccount2,
      body: context.l10n.thisPermanentlyDeletesYourAccount,
      extra: Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.typeDeleteToConfirm,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: c.fill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _focus.hasFocus ? c.textMuted : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: e2eId(
                'delete_account_input',
                TextField(
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setState(() {}),
                  cursorColor: c.textPrimary,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: c.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      cancel: e2eId(
        'delete_account_cancel',
        SoftButton(
          label: context.l10n.commonCancel,
          icon: Icons.close_rounded,
          style: SoftButtonStyle.secondary,
          expand: true,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      confirm: e2eId(
        'delete_account_confirm',
        SoftButton(
          label: context.l10n.commonDelete,
          style: SoftButtonStyle.danger,
          expand: true,
          onPressed: _confirmed ? _delete : null,
        ),
      ),
    );
  }
}
