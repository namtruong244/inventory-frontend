import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';

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
    final theme = Theme.of(context);
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.syncDismiss,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack).value;
        return Transform.scale(
          scale: 0.8 + (0.2 * curvedValue),
          child: Opacity(
            opacity: anim1.value.clamp(0.0, 1.0),
            child: Dialog(
              backgroundColor: context.colors.surface,
              elevation: 10,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Icon Circle
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isDestructive
                            ? context.colors.dangerSoft // Light red
                            : context.colors.border, // Light slate
                        shape: BoxShape.circle,
                      ),
                      child: AppIcon(
                        icon,
                        size: 32,
                        color: isDestructive
                            ? AppTones.coral // Strong red
                            : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Message
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              side: BorderSide(color: context.colors.border),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              cancelLabel ?? context.l10n.commonCancel,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: FilledButton.styleFrom(
                              backgroundColor: isDestructive
                                  ? AppTones.coral
                                  : theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              confirmLabel ?? context.l10n.commonConfirm,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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

  /// Helper method for modern translucent floating toasts
  static void _showToast(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
    required Color iconColor,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: EdgeInsets.zero,
        duration: Duration(seconds: onAction == null ? 3 : 6),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: context.colors.surface.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: AppIcon(
                      icon,
                      color: iconColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  if (actionLabel != null && onAction != null)
                    TextButton(
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                        onAction();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size(48, 48),
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                ],
              ),
            ),
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
      color: AppTones.matcha, // Emerald
      iconColor: AppTones.matcha,
    );
  }

  /// Failure / error notification toast
  static void showError(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      icon: Icons.priority_high_rounded,
      color: AppTones.coral, // Rose red
      iconColor: AppTones.coral,
    );
  }

  /// Warning notification toast
  static void showWarning(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      color: AppTones.amber, // Amber
      iconColor: AppTones.amber,
    );
  }

  /// General information toast
  static void showInfo(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      color: AppTones.ink, // Deep navy / charcoal
      iconColor: AppTones.ink,
    );
  }
}
