import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import 'settings_common.dart';

import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_form_field.dart';
import 'app_icon.dart';
import 'soft_sheet.dart';
import 'soft_ui.dart';

Widget buildBackendSection(BuildContext context, InventoryProvider provider) {
  final c = context.colors;
  final isOnline = provider.isConnected;
  final serverUrl = provider.serverUrl;
  final currentUser = provider.currentUser;

  return SettingsGroup(
    children: [
      // 1. Connection status
      SettingsRow(
        icon: Icons.dns_rounded,
        iconColor: isOnline ? c.successStrong : c.dangerStrong,
        iconBackground: isOnline ? c.successSoft : c.dangerSoft,
        label: context.l10n.serverEndpoint,
        subtitle: serverUrl,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SoftChip(
              label: isOnline
                  ? context.l10n.statusOnlineTag
                  : context.l10n.statusOfflineTag,
              background: isOnline ? c.successSoft : c.dangerSoft,
              foreground: isOnline ? c.successStrong : c.dangerStrong,
            ),
            const SizedBox(width: 8),
            AppIcon(Icons.edit_outlined, color: c.textSecondary, size: 18),
          ],
        ),
        onTap: () => showChangeServerUrlDialog(context, provider),
      ),
      // 2. Authenticated account
      SettingsRow(
        icon: Icons.verified_user_outlined,
        iconColor: c.infoStrong,
        iconBackground: c.infoSoft,
        label: context.l10n.apiAuthentication,
        subtitle: currentUser != null
            ? '${currentUser.email} (${currentUser.role})'
            : context.l10n.authenticatedAs(provider.userName),
        value: context.l10n.loginSwitch,
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
        },
      ),
      // 3. Sync from server
      SettingsRow(
        icon: Icons.sync_rounded,
        iconColor: AppTones.sky,
        iconBackground: AppTones.skySoft,
        label: context.l10n.syncWithServer,
        subtitle: provider.isSyncing
            ? context.l10n.synchronizingBoxesItemsAlerts
            : context.l10n.pullLatestInventoryLendingRecords,
        trailing: provider.isSyncing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: c.textPrimary,
                ),
              )
            : AppIcon(Icons.refresh_rounded, color: c.textSecondary, size: 20),
        onTap: provider.isSyncing
            ? null
            : () async {
                await provider.fetchAllData();
                if (context.mounted) {
                  if (provider.isConnected) {
                    AppFeedback.showSuccess(
                      context,
                      context.l10n.successfullySynchronizedWithBackendServer,
                    );
                  } else {
                    AppFeedback.showError(
                      context,
                      provider.errorMessage ?? context.l10n.syncFailed,
                    );
                  }
                }
              },
      ),
    ],
  );
}

void showChangeServerUrlDialog(
  BuildContext context,
  InventoryProvider provider,
) {
  final controller = TextEditingController(text: provider.serverUrl);
  showSoftSheet(
    context,
    title: context.l10n.backendApiUrl,
    subtitle: context.l10n.enterTheBackendBaseUrl,
    builder: (ctx) => SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormField(
            label: context.l10n.backendApiUrl,
            hintText: kDebugMode ? 'http://localhost:8080' : 'https://',
            controller: controller,
            keyboardType: TextInputType.url,
            prefixIcon: const AppIcon(Icons.link_rounded),
          ),
          // Local development shortcuts mean nothing to end users.
          if (kDebugMode) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SoftFilterChip(
                  label: 'localhost:8080',
                  selected: false,
                  onTap: () => controller.text = 'http://localhost:8080',
                ),
                SoftFilterChip(
                  label: '10.0.2.2:8080 (Android)',
                  selected: false,
                  onTap: () => controller.text = 'http://10.0.2.2:8080',
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SoftButton(
                  label: context.l10n.commonCancel,
                  style: SoftButtonStyle.secondary,
                  expand: true,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SoftButton(
                  label: context.l10n.saveConnect,
                  expand: true,
                  onPressed: () async {
                    final newUrl = controller.text.trim();
                    if (newUrl.isNotEmpty) {
                      Navigator.pop(ctx);
                      await provider.setServerUrl(newUrl);
                      if (context.mounted) {
                        AppFeedback.showSuccess(
                          context,
                          context.l10n.serverUrlUpdatedTo(newUrl),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
