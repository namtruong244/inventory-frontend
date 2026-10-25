import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import 'settings_common.dart';

import '../providers/inventory_provider.dart';
import 'app_feedback.dart';

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
        isOnline ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
      ),
      title: Row(
        children: [
          const Text(
            'Server Endpoint',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF18181B)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isOnline ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isOnline ? 'ONLINE' : 'OFFLINE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isOnline ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        serverUrl,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontFamily: 'monospace'),
      ),
      trailing: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
      onTap: () => showChangeServerUrlDialog(context, provider),
    ),
    const Divider(height: 1),

    // 2. Authenticated Account Tile
    ListTile(
      leading: buildIconBox(
        Icons.verified_user_outlined,
        const Color(0xFF6366F1),
        const Color(0xFFEEF2FF),
      ),
      title: const Text(
        'API Authentication',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF18181B)),
      ),
      subtitle: Text(
        currentUser != null
            ? '${currentUser.email} (${currentUser.role})'
            : 'Authenticated as ${provider.userName}',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
        child: const Text('Login / Switch', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
      title: const Text(
        'Sync With Server',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF18181B)),
      ),
      subtitle: Text(
        provider.isSyncing
            ? 'Synchronizing boxes, items & alerts...'
            : 'Pull latest inventory & lending records',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: provider.isSyncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF18181B)),
            )
          : const Icon(Icons.refresh_rounded, color: Colors.grey, size: 20),
      onTap: provider.isSyncing
          ? null
          : () async {
              await provider.fetchAllData();
              if (context.mounted) {
                if (provider.isConnected) {
                  AppFeedback.showSuccess(context, 'Successfully synchronized with backend server');
                } else {
                  AppFeedback.showError(context, provider.errorMessage ?? 'Sync failed');
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
        const Color(0xFFF3E8FF),
      ),
      title: const Text(
        'Seed Demo Data to Server',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF18181B)),
      ),
      subtitle: Text(
        'Populate backend with rooms, items, alerts & loans',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
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
      title: const Text('Backend API URL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter the backend base URL (default: http://localhost:8080):',
            style: TextStyle(fontSize: 13, color: Colors.grey),
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final newUrl = controller.text.trim();
            if (newUrl.isNotEmpty) {
              Navigator.pop(ctx);
              await provider.setServerUrl(newUrl);
              if (context.mounted) {
                AppFeedback.showSuccess(context, 'Server URL updated to $newUrl');
              }
            }
          },
          child: const Text('Save & Connect'),
        ),
      ],
    ),
  );
}
