import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_form_field.dart';
import '../widgets/export_barcodes_sheet.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const SettingsScreen({super.key, this.scrollController});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _versionTapCount = 0;
  bool _developerModeUnlocked = false;

  void _handleVersionTap() {
    setState(() {
      _versionTapCount++;
      if (_developerModeUnlocked) {
        return;
      }
      if (_versionTapCount >= 7) {
        _developerModeUnlocked = true;
        HapticFeedback.heavyImpact();
        AppFeedback.showSuccess(context, 'Developer options activated!');
      } else if (_versionTapCount >= 4) {
        final remaining = 7 - _versionTapCount;
        HapticFeedback.selectionClick();
        AppFeedback.showInfo(context, 'Tap $remaining more times to unlock developer tools');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: Consumer<InventoryProvider>(
          builder: (context, provider, child) {
            final totalBoxes = provider.boxes.length;
            final totalItems = provider.items.length;
            final activeLoans = provider.getActiveLoans().length;

            return ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
              children: [
                // Page Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: const Color(0xFF18181B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Preferences, taxonomy & inventory tools',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 1. User Profile Card
                _buildProfileCard(context, provider),
                const SizedBox(height: 16),

                // 2. Inventory Stats Overview Banner
                _buildStatsBanner(provider, totalBoxes, totalItems, activeLoans),
                const SizedBox(height: 24),

                // 3. Category Management Section
                _buildSectionHeader('TAXONOMY & CATEGORIES'),
                const SizedBox(height: 8),
                _buildCardContainer([
                  ListTile(
                    leading: _buildIconBox(Icons.category_rounded, const Color(0xFF6366F1), const Color(0xFFEEF2FF)),
                    title: const Text(
                      'Manage Categories',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF18181B)),
                    ),
                    subtitle: Text(
                      '${provider.categories.length} item categories available',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${provider.categories.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF18181B)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                      ],
                    ),
                    onTap: () => _showCategoryManagementSheet(context, provider),
                  ),
                ]),
                const SizedBox(height: 24),

                // 4. Inventory Preferences
                _buildSectionHeader('INVENTORY PREFERENCES'),
                const SizedBox(height: 8),
                _buildCardContainer([
                  _buildPreferenceTile(
                    icon: Icons.payments_outlined,
                    iconColor: const Color(0xFF10B981),
                    iconBg: const Color(0xFFECFDF5),
                    title: 'Currency Symbol',
                    subtitle: 'Used for purchase prices & valuation',
                    valueText: provider.currency,
                    onTap: () => _showCurrencyPicker(context, provider),
                  ),
                  const Divider(height: 1),
                  _buildPreferenceTile(
                    icon: Icons.straighten_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    iconBg: const Color(0xFFFEF3C7),
                    title: 'Default Item Unit',
                    subtitle: 'Pre-filled unit for newly created items',
                    valueText: provider.defaultUnit,
                    onTap: () => _showDefaultUnitPicker(context, provider),
                  ),
                  const Divider(height: 1),
                  _buildPreferenceTile(
                    icon: Icons.event_available_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    iconBg: const Color(0xFFEFF6FF),
                    title: 'Expiry Warning Window',
                    subtitle: 'Days before expiration to trigger alert',
                    valueText: '${provider.expiryWarningDays} days',
                    onTap: () => _showExpiryDaysPicker(context, provider),
                  ),
                ]),
                const SizedBox(height: 24),

                // 5. Scanner & Barcode Options
                _buildSectionHeader('SCANNER & RECOGNITION'),
                const SizedBox(height: 8),
                _buildCardContainer([
                  SwitchListTile.adaptive(
                    value: provider.vibrateOnScan,
                    onChanged: (val) {
                      provider.setVibrateOnScan(val);
                      if (val) HapticFeedback.mediumImpact();
                    },
                    secondary: _buildIconBox(Icons.vibration_rounded, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
                    title: const Text('Vibration on Scan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Haptic feedback when QR/Barcode detected', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    activeTrackColor: const Color(0xFF18181B),
                    activeThumbColor: Colors.white,
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: provider.beepOnScan,
                    onChanged: (val) => provider.setBeepOnScan(val),
                    secondary: _buildIconBox(Icons.volume_up_outlined, const Color(0xFF06B6D4), const Color(0xFFECFEFF)),
                    title: const Text('Sound Feedback', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Play subtle tone on scan confirmation', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    activeTrackColor: const Color(0xFF18181B),
                    activeThumbColor: Colors.white,
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: provider.autoOpenOnScan,
                    onChanged: (val) => provider.setAutoOpenOnScan(val),
                    secondary: _buildIconBox(Icons.open_in_new_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5)),
                    title: const Text('Auto-Open Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Instantly navigate to matched container/item', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    activeTrackColor: const Color(0xFF18181B),
                    activeThumbColor: Colors.white,
                  ),
                ]),
                const SizedBox(height: 24),

                // 6. Alerts & Notifications
                _buildSectionHeader('ALERTS & NOTIFICATIONS'),
                const SizedBox(height: 8),
                _buildCardContainer([
                  SwitchListTile.adaptive(
                    value: provider.notifyExpiring,
                    onChanged: (val) => provider.setNotifyExpiring(val),
                    secondary: _buildIconBox(Icons.alarm_rounded, const Color(0xFFEF4444), const Color(0xFFFEF2F2)),
                    title: const Text('Expiring Items Alert', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Notify on items expiring in the alert window', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    activeTrackColor: const Color(0xFF18181B),
                    activeThumbColor: Colors.white,
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: provider.notifyOverdue,
                    onChanged: (val) => provider.setNotifyOverdue(val),
                    secondary: _buildIconBox(Icons.assignment_late_outlined, const Color(0xFFF97316), const Color(0xFFFFF7ED)),
                    title: const Text('Overdue Lending Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Remind when borrowed assets pass due date', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    activeTrackColor: const Color(0xFF18181B),
                    activeThumbColor: Colors.white,
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: provider.notifyLowStock,
                    onChanged: (val) => provider.setNotifyLowStock(val),
                    secondary: _buildIconBox(Icons.production_quantity_limits_rounded, const Color(0xFFEAB308), const Color(0xFFFEFCE8)),
                    title: const Text('Low Stock Warnings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Flag items needing replenishment', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    activeTrackColor: const Color(0xFF18181B),
                    activeThumbColor: Colors.white,
                  ),
                ]),
                const SizedBox(height: 24),

                // 7. Reports & Audit
                _buildSectionHeader('REPORTS & INVENTORY AUDIT'),
                const SizedBox(height: 8),
                _buildCardContainer([
                  ListTile(
                    leading: _buildIconBox(Icons.qr_code_2_rounded, const Color(0xFF6366F1), const Color(0xFFEEF2FF)),
                    title: const Text(
                      'Export All Box Barcodes (PDF)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF18181B)),
                    ),
                    subtitle: Text(
                      'Generate printable PDF sticker sheet with box QR codes & names',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                    onTap: () => ExportBarcodesSheet.showAll(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: _buildIconBox(Icons.summarize_outlined, const Color(0xFF059669), const Color(0xFFD1FAE5)),
                    title: const Text(
                      'Export Inventory Report',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF18181B)),
                    ),
                    subtitle: Text(
                      'Generate & copy formatted summary of all assets',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                    onTap: () => _showExportReportSheet(context, provider),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: _buildIconBox(Icons.donut_large_outlined, const Color(0xFF2563EB), const Color(0xFFDBEAFE)),
                    title: const Text(
                      'Inventory Health Breakdown',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF18181B)),
                    ),
                    subtitle: Text(
                      'Status distribution: In Stock, Lent, Low Stock, Expired',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                    onTap: () => _showInventoryStatusSheet(context, provider),
                  ),
                ]),
                const SizedBox(height: 24),

                // 8. Backend Server & API (Developer Mode Only - Unlocked via 7 taps on Version)
                if (_developerModeUnlocked) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('DEVELOPER OPTIONS & BACKEND API'),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _developerModeUnlocked = false;
                            _versionTapCount = 0;
                          });
                          AppFeedback.showInfo(context, 'Developer mode deactivated');
                        },
                        icon: const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                        label: const Text('Hide', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildBackendSection(context, provider),
                  const SizedBox(height: 24),
                ],

                // 9. Application Info
                _buildSectionHeader('APPLICATION INFO'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Application Version',
                        '1.0.0 (Build 2026)',
                        onTap: _handleVersionTap,
                        trailingBadge: _developerModeUnlocked
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'DEVELOPER',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow('Design System', 'Minimal Charcoal (iOS Style)'),
                      const Divider(height: 20),
                      _buildInfoRow('QR & Barcode Engine', 'MobileScanner v5'),
                      const Divider(height: 20),
                      _buildInfoRow('Storage Architecture', 'Hierarchical Multi-Level Tree'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 10. Account Sign Out / Switch
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmSignOut(context, provider),
                    icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
                    label: const Text(
                      'Log Out / Switch Account',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFEE2E2), width: 1.5),
                      backgroundColor: const Color(0xFFFEF2F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Profile Card ---
  Widget _buildProfileCard(BuildContext context, InventoryProvider provider) {
    final email = provider.userEmail;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF18181B),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF18181B),
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  provider.userRole,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Switch Account / Login',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.sync_alt_rounded, size: 18, color: Color(0xFF18181B)),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Edit Profile',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF18181B)),
            ),
            onPressed: () => _showEditProfileDialog(context, provider),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, InventoryProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text(
          'Are you sure you want to log out? You can sign back in anytime using Google or your email.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // --- Stats Banner ---
  Widget _buildStatsBanner(InventoryProvider provider, int totalBoxes, int totalItems, int activeLoans) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'Inventory Quick Metrics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Containers', '$totalBoxes'),
              Container(width: 1, height: 32, color: Colors.white24),
              _buildStatItem('Total Assets', '$totalItems'),
              Container(width: 1, height: 32, color: Colors.white24),
              _buildStatItem('On Loan', '$activeLoans'),
              Container(width: 1, height: 32, color: Colors.white24),
              _buildStatItem('Est. Value', provider.formatPrice(provider.totalInventoryValue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // --- Reusable UI Elements ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildIconBox(IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildPreferenceTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String valueText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: _buildIconBox(icon, iconColor, iconBg),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              valueText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF18181B)),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    VoidCallback? onTap,
    Widget? trailingBadge,
  }) {
    final rowContent = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingBadge != null) ...[
              trailingBadge,
              const SizedBox(width: 6),
            ],
            Text(value, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: rowContent,
        ),
      );
    }
    return rowContent;
  }

  // ==========================================
  // MODAL BOTTOM SHEETS & DIALOGS
  // ==========================================

  // 1. Edit Profile Sheet
  void _showEditProfileDialog(BuildContext context, InventoryProvider provider) {
    final nameController = TextEditingController(text: provider.userName);
    final roleController = TextEditingController(text: provider.userRole);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
              ),
              const SizedBox(height: 4),
              Text(
                'Update your display name and inventory role',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              AppFormField(
                label: 'Display Name',
                hintText: 'e.g. Sara Wilson',
                controller: nameController,
              ),
              const SizedBox(height: 14),
              AppFormField(
                label: 'Role / Department',
                hintText: 'e.g. Asset Manager, Home Owner',
                controller: roleController,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF18181B),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        provider.updateUserProfile(nameController.text, roleController.text);
                        Navigator.pop(sheetContext);
                        AppFeedback.showSuccess(context, 'Profile updated successfully');
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF18181B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Category Management Modal Sheet
  void _showCategoryManagementSheet(BuildContext context, InventoryProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (dialogCtx, setSheetState) {
            final filteredCategories = provider.categories
                .where((c) => c.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Manage Categories',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${provider.categories.length} total categories configured',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          FilledButton.icon(
                            onPressed: () {
                              _showAddCategorySubDialog(context, provider, (newCat) {
                                setSheetState(() {});
                              });
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('New', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF18181B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search bar
                      TextField(
                        onChanged: (val) => setSheetState(() => searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search categories...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFF4F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filteredCategories.isEmpty
                            ? Center(
                                child: Text('No categories match "$searchQuery"', style: TextStyle(color: Colors.grey.shade500)),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: filteredCategories.length,
                                separatorBuilder: (_, _) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final cat = filteredCategories[index];
                                  final count = provider.getItemCountForCategory(cat);
                                  final isDefault = CategoryHelper.defaultCategories.contains(cat);

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F4F6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        CategoryHelper.getCategoryIcon(cat),
                                        color: const Color(0xFF18181B),
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      cat,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF18181B)),
                                    ),
                                    subtitle: Text(
                                      '$count ${count == 1 ? "item" : "items"}${isDefault ? " • Built-in" : " • Custom"}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    trailing: !isDefault
                                        ? IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444)),
                                            onPressed: () async {
                                              final confirmed = await AppFeedback.showConfirmDialog(
                                                dialogCtx,
                                                title: 'Delete Category',
                                                message: 'Delete category "$cat"? Any items in this category will be reassigned to "General".',
                                                confirmLabel: 'Delete',
                                                isDestructive: true,
                                                icon: Icons.delete_outline,
                                              );
                                              if (confirmed && dialogCtx.mounted) {
                                                provider.deleteCategory(cat);
                                                setSheetState(() {});
                                                AppFeedback.showSuccess(dialogCtx, 'Category "$cat" removed');
                                              }
                                            },
                                          )
                                        : null,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddCategorySubDialog(BuildContext context, InventoryProvider provider, Function(String) onAdded) {
    final textController = TextEditingController();
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (subSheetContext) {
        return StatefulBuilder(
          builder: (dialogCtx, setSubState) {
            final catName = textController.text.trim();
            final previewIcon = CategoryHelper.getCategoryIcon(catName.isEmpty ? 'General' : catName);

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(subSheetContext).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(previewIcon, color: const Color(0xFF18181B), size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Category',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Enter a category name for your catalog',
                              style: TextStyle(fontSize: 12, color: Color(0xFF71717A)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppFormField(
                      label: 'Category Name',
                      hintText: 'e.g. Photography, Board Games, Hardware',
                      controller: textController,
                      onChanged: (_) {
                        setSubState(() => errorText = null);
                      },
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 6),
                      Text(errorText!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(subSheetContext),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF18181B),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final name = textController.text.trim();
                              if (name.isEmpty) {
                                setSubState(() => errorText = 'Please enter a category name');
                                return;
                              }
                              if (provider.categories.any((c) => c.toLowerCase() == name.toLowerCase())) {
                                setSubState(() => errorText = 'Category already exists');
                                return;
                              }
                              provider.addCategory(name);
                              Navigator.pop(subSheetContext);
                              onAdded(name);
                              AppFeedback.showSuccess(context, 'Category "$name" created');
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF18181B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 3. Currency Picker Sheet
  void _showCurrencyPicker(BuildContext context, InventoryProvider provider) {
    final currencies = [
      {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
      {'code': 'VND', 'symbol': '₫', 'name': 'Vietnamese Dong'},
      {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
      {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
      {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    ];

    _showSelectionSheet(
      context: context,
      title: 'Select Currency',
      subtitle: 'Applied to price calculations & asset valuation',
      items: currencies.map((c) => c['symbol']!).toList(),
      currentValue: provider.currency,
      displayBuilder: (sym) {
        final item = currencies.firstWhere((c) => c['symbol'] == sym);
        return '${item['symbol']} (${item['code']} - ${item['name']})';
      },
      onSelected: (sym) {
        provider.setCurrency(sym);
        AppFeedback.showSuccess(context, 'Currency changed to $sym');
      },
    );
  }

  // 4. Default Unit Picker Sheet
  void _showDefaultUnitPicker(BuildContext context, InventoryProvider provider) {
    final units = [
      {'code': 'pcs', 'name': 'Pieces'},
      {'code': 'box', 'name': 'Boxes'},
      {'code': 'pack', 'name': 'Packs'},
      {'code': 'kg', 'name': 'Kilograms'},
      {'code': 'set', 'name': 'Sets'},
      {'code': 'pair', 'name': 'Pairs'},
      {'code': 'bottle', 'name': 'Bottles'},
      {'code': 'm', 'name': 'Meters'},
    ];

    _showSelectionSheet(
      context: context,
      title: 'Default Item Unit',
      subtitle: 'Default measuring unit when creating new items',
      items: units.map((u) => u['code']!).toList(),
      currentValue: provider.defaultUnit,
      displayBuilder: (code) {
        final item = units.firstWhere((u) => u['code'] == code);
        return '${item['code']} (${item['name']})';
      },
      onSelected: (unit) {
        provider.setDefaultUnit(unit);
        AppFeedback.showSuccess(context, 'Default unit set to "$unit"');
      },
    );
  }

  // 5. Expiry Days Warning Picker
  void _showExpiryDaysPicker(BuildContext context, InventoryProvider provider) {
    final daysOptions = [7, 14, 30, 60, 90];

    _showSelectionSheet<int>(
      context: context,
      title: 'Expiry Warning Window',
      subtitle: 'How many days before expiration to alert you',
      items: daysOptions,
      currentValue: provider.expiryWarningDays,
      displayBuilder: (days) => '$days days before expiration / warranty ends',
      onSelected: (days) {
        provider.setExpiryWarningDays(days);
        AppFeedback.showSuccess(context, 'Alert window set to $days days');
      },
    );
  }

  // Generic Selection Sheet Helper
  void _showSelectionSheet<T>({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<T> items,
    required T currentValue,
    required String Function(T) displayBuilder,
    required Function(T) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottomPadding = MediaQuery.of(sheetContext).padding.bottom;
        final maxHeight = MediaQuery.of(sheetContext).size.height * 0.75;

        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding > 0 ? 8 : 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: items.map((item) {
                          final isSelected = item == currentValue;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: isSelected ? const Color(0xFFF4F4F6) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: isSelected ? const Color(0xFF18181B) : Colors.grey.shade200,
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                                title: Text(
                                  displayBuilder(item),
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: const Color(0xFF18181B),
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF18181B), size: 20)
                                    : null,
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  onSelected(item);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 7. Export Report Sheet
  void _showExportReportSheet(BuildContext context, InventoryProvider provider) {
    final report = provider.generateInventoryReport();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventory Report',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Generated plain-text inventory status report',
                        style: TextStyle(fontSize: 12, color: Color(0xFF71717A)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: SelectableText(
                      report,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.5,
                        color: Color(0xFF27272A),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: report));
                    Navigator.pop(sheetContext);
                    AppFeedback.showSuccess(context, 'Report copied to clipboard!');
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy Report to Clipboard', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF18181B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 8. Inventory Health & Status Sheet
  void _showInventoryStatusSheet(BuildContext context, InventoryProvider provider) {
    final total = provider.items.length;
    final stored = provider.items.where((i) => i.status == ItemStatus.stored).length;
    final inUse = provider.items.where((i) => i.status == ItemStatus.inUse).length;
    final lent = provider.items.where((i) => i.status == ItemStatus.lent).length;
    final lowStock = provider.getLowStockItems().length;
    final expired = provider.getExpiredItems().length;
    final expiringSoon = provider.getExpiringItems(withinDays: provider.expiryWarningDays).length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottomPadding = MediaQuery.of(sheetContext).padding.bottom;
        final maxHeight = MediaQuery.of(sheetContext).size.height * 0.8;

        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding > 0 ? 8 : 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 18),
                  const Text(
                    'Inventory Health Breakdown',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time condition breakdown of $total tracked items',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 18),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusRow('Stored in Containers', stored, total, const Color(0xFF10B981)),
                          _buildStatusRow('In Use / Active', inUse, total, const Color(0xFF3B82F6)),
                          _buildStatusRow('Lent to Borrowers', lent, total, const Color(0xFF8B5CF6)),
                          _buildStatusRow('Low Stock Warning', lowStock, total, const Color(0xFFF59E0B)),
                          _buildStatusRow('Expiring Soon (≤ ${provider.expiryWarningDays}d)', expiringSoon, total, const Color(0xFFF97316)),
                          _buildStatusRow('Expired Assets', expired, total, const Color(0xFFEF4444)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF18181B))),
                ],
              ),
              Text(
                '$count items (${(percentage * 100).toStringAsFixed(0)}%)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: const Color(0xFFF4F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // --- Backend Server Section ---
  Widget _buildBackendSection(BuildContext context, InventoryProvider provider) {
    final isOnline = provider.isConnected;
    final serverUrl = provider.serverUrl;
    final currentUser = provider.currentUser;

    return _buildCardContainer([
      // 1. Connection Status Tile
      ListTile(
        leading: _buildIconBox(
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
        onTap: () => _showChangeServerUrlDialog(context, provider),
      ),
      const Divider(height: 1),

      // 2. Authenticated Account Tile
      ListTile(
        leading: _buildIconBox(
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
        leading: _buildIconBox(
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
        leading: _buildIconBox(
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
        onTap: () => _confirmSeedData(context, provider),
      ),
    ]);
  }

  void _showChangeServerUrlDialog(BuildContext context, InventoryProvider provider) {
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

  void _confirmSeedData(BuildContext context, InventoryProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Seed Demo Inventory?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will upload sample multi-level rooms, cabinets, boxes, tech gear, medicine, low-stock items, and lending records directly into your backend database at http://localhost:8080.\n\nExisting items will be preserved.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.seedBackendWithSampleData();
              if (context.mounted) {
                if (success) {
                  AppFeedback.showSuccess(context, 'Successfully seeded sample inventory to backend server!');
                } else {
                  AppFeedback.showError(context, 'Failed to seed sample data: ${provider.errorMessage}');
                }
              }
            },
            child: const Text('Seed Data'),
          ),
        ],
      ),
    );
  }
}

