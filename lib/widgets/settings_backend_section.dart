import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import 'settings_common.dart';

import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

Widget buildBackendSection(BuildContext context, InventoryProvider provider) {
  final isOnline = provider.isConnected;
  final serverUrl = provider.serverUrl;
  final currentUser = provider.currentUser;

  return buildCardContainer([
    // 1. Connection Status Tile
    ListTile(
      leading: buildIconBox(
        Icons.dns_rounded,
        isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        isOnline ? context.colors.successSoft : context.colors.dangerSoft,
      ),
      title: Row(
        children: [
          Text(
            context.l10n.serverEndpoint,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.colors.textPrimary),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isOnline ? const Color(0xFFDCFCE7) : context.colors.dangerSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isOnline ? 'ONLINE' : 'OFFLINE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isOnline ? const Color(0xFF15803D) : context.colors.dangerStrong,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        serverUrl,
        style: TextStyle(fontSize: 12, color: context.colors.textSecondary, fontFamily: 'monospace'),
      ),
      trailing: Icon(Icons.edit_outlined, color: context.colors.textSecondary, size: 20),
      onTap: () => showChangeServerUrlDialog(context, provider),
    ),
    const Divider(height: 1),

    // 2. Authenticated Account Tile
    ListTile(
      leading: buildIconBox(
        Icons.verified_user_outlined,
        const Color(0xFF6366F1),
        context.colors.infoSoft,
      ),
      title: Text(
        context.l10n.apiAuthentication,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.colors.textPrimary),
      ),
      subtitle: Text(
        currentUser != null
            ? '${currentUser.email} (${currentUser.role})'
            : context.l10n.authenticatedAs(provider.userName),
        style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
      ),
      trailing: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(context.l10n.loginSwitch, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    ),
    const Divider(height: 1),

    // 3. Sync from Server Tile
    ListTile(
      leading: buildIconBox(
        Icons.sync_rounded,
        const Color(0xFF0284C7),
        const Color(0xFFE0F2FE),
      ),
      title: Text(
        context.l10n.syncWithServer,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.colors.textPrimary),
      ),
      subtitle: Text(
        provider.isSyncing
            ? context.l10n.synchronizingBoxesItemsAlerts
            : context.l10n.pullLatestInventoryLendingRecords,
        style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
      ),
      trailing: provider.isSyncing
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.textPrimary),
            )
          : Icon(Icons.refresh_rounded, color: context.colors.textSecondary, size: 20),
      onTap: provider.isSyncing
          ? null
          : () async {
              await provider.fetchAllData();
              if (context.mounted) {
                if (provider.isConnected) {
                  AppFeedback.showSuccess(context, context.l10n.successfullySynchronizedWithBackendServer);
                } else {
                  AppFeedback.showError(context, provider.errorMessage ?? context.l10n.syncFailed);
                }
              }
            },
    ),
    const Divider(height: 1),

    // 4. Seed Sample Demo Data Tile
    ListTile(
      leading: buildIconBox(
        Icons.cloud_upload_outlined,
        const Color(0xFF8B5CF6),
        context.colors.infoSoft,
      ),
      title: Text(
        context.l10n.seedDemoDataToServer,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.colors.textPrimary),
      ),
      subtitle: Text(
        context.l10n.populateBackendWithRoomsItems,
        style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: context.colors.textSecondary, size: 14),
      onTap: () => confirmSeedData(context, provider),
    ),
  ]);
}


void showChangeServerUrlDialog(BuildContext context, InventoryProvider provider) {
  final controller = TextEditingController(text: provider.serverUrl);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(context.l10n.backendApiUrl, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.enterTheBackendBaseUrl,
            style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'http://localhost:8080',
              prefixIcon: const Icon(Icons.link_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: const Text('localhost:8080', style: TextStyle(fontSize: 11)),
                onPressed: () => controller.text = 'http://localhost:8080',
              ),
              ActionChip(
                label: const Text('10.0.2.2:8080 (Android)', style: TextStyle(fontSize: 11)),
                onPressed: () => controller.text = 'http://10.0.2.2:8080',
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () async {
            final newUrl = controller.text.trim();
            if (newUrl.isNotEmpty) {
              Navigator.pop(ctx);
              await provider.setServerUrl(newUrl);
              if (context.mounted) {
                AppFeedback.showSuccess(context, context.l10n.serverUrlUpdatedTo(newUrl));
              }
            }
          },
          child: Text(context.l10n.saveConnect),
        ),
      ],
    ),
  );
}
