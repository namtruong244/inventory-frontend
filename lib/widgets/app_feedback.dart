import '../utils/e2e.dart';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';
import 'soft_ui.dart';
import 'tappable.dart';

class AppFeedback {
  /// Display action confirmation dialog (Delete, Cancel, Change...)
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
    IconData icon = Icons.warning_amber_rounded,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.syncDismiss,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutBack,
        ).value;
        final c = context.colors;
        return Transform.scale(
          scale: 0.8 + (0.2 * curvedValue),
          child: Opacity(
            opacity: anim1.value.clamp(0.0, 1.0),
            child: Dialog(
              backgroundColor: c.surface,
              elevation: 10,
              shadowColor: const Color(0x33000000),
              insetPadding: const EdgeInsets.symmetric(horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDestructive ? c.dangerSoft : c.fill,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: AppIcon(
                        icon,
                        size: 22,
                        color: isDestructive ? c.dangerStrong : c.textPrimary,
                      ),
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
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: c.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: e2eId(
                            'confirm_cancel',
                            SoftButton(
                              label: cancelLabel ?? context.l10n.commonCancel,
                              style: SoftButtonStyle.secondary,
                              expand: true,
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: e2eId(
                            'confirm_ok',
                            SoftButton(
                              label: confirmLabel ?? context.l10n.commonConfirm,
                              style: isDestructive
                                  ? SoftButtonStyle.danger
                                  : SoftButtonStyle.accent,
                              expand: true,
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  /// Design Toast: dark pill, round colored badge, optional action chip.
  static void _showToast(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color badge,
    required Color iconColor,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final c = context.colors;
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: EdgeInsets.zero,
        duration: Duration(seconds: onAction == null ? 3 : 6),
        content: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2E000000),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: badge, shape: BoxShape.circle),
                child: AppIcon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 12),
                Tappable(
                  onTap: () {
                    messenger.hideCurrentSnackBar();
                    onAction();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x1FFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      actionLabel,
                      style: TextStyle(
                        color: c.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Success notification toast
  static void showSuccess(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _showToast(
      context,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      icon: Icons.check_rounded,
      badge: context.colors.accent,
      iconColor: context.colors.onAccent,
    );
  }

  /// Failure / error notification toast
  static void showError(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      icon: Icons.priority_high_rounded,
      badge: context.colors.dangerSoft,
      iconColor: context.colors.dangerStrong,
    );
  }

  /// Warning notification toast
  static void showWarning(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      badge: context.colors.warningSoft,
      iconColor: context.colors.warningStrong,
    );
  }

  /// General information toast
  static void showInfo(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      badge: context.colors.infoSoft,
      iconColor: context.colors.infoStrong,
    );
  }
}
