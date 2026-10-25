import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/settings_common.dart';
import '../widgets/settings_profile_sheets.dart';
import '../widgets/settings_pickers.dart';
import '../widgets/settings_report_sheets.dart';
import '../widgets/settings_backend_section.dart';


import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
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
                buildSectionHeader('TAXONOMY & CATEGORIES'),
                const SizedBox(height: 8),
                buildCardContainer([
                  ListTile(
                    leading: buildIconBox(Icons.category_rounded, const Color(0xFF6366F1), const Color(0xFFEEF2FF)),
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
                    onTap: () => showCategoryManagementSheet(context, provider),
                  ),
                ]),
                const SizedBox(height: 24),

                // 4. Inventory Preferences
                buildSectionHeader('INVENTORY PREFERENCES'),
                const SizedBox(height: 8),
                buildCardContainer([
                  buildPreferenceTile(
                    icon: Icons.payments_outlined,
                    iconColor: const Color(0xFF10B981),
                    iconBg: const Color(0xFFECFDF5),
                    title: 'Currency Symbol',
                    subtitle: 'Used for purchase prices & valuation',
                    valueText: provider.currency,
                    onTap: () => showCurrencyPicker(context, provider),
                  ),
                  const Divider(height: 1),
                  buildPreferenceTile(
                    icon: Icons.straighten_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    iconBg: const Color(0xFFFEF3C7),
                    title: 'Default Item Unit',
                    subtitle: 'Pre-filled unit for newly created items',
                    valueText: provider.defaultUnit,
                    onTap: () => showDefaultUnitPicker(context, provider),
                  ),
                  const Divider(height: 1),
                  buildPreferenceTile(
                    icon: Icons.event_available_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    iconBg: const Color(0xFFEFF6FF),
                    title: 'Expiry Warning Window',
                    subtitle: 'Days before expiration to trigger alert',
                    valueText: '${provider.expiryWarningDays} days',
                    onTap: () => showExpiryDaysPicker(context, provider),
                  ),
                  const Divider(height: 1),
                  buildPreferenceTile(
                    icon: Icons.verified_user_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBg: const Color(0xFFF5F3FF),
                    title: 'Warranty Warning Window',
                    subtitle: 'Days before warranty ends to trigger alert',
                    valueText: '${provider.warrantyWarningDays} days',
                    onTap: () => showWarrantyDaysPicker(context, provider),
                  ),
                  const Divider(height: 1),
                  buildPreferenceTile(
                    icon: Icons.public,
                    iconColor: const Color(0xFF0EA5E9),
                    iconBg: const Color(0xFFF0F9FF),
                    title: 'Time Zone',
                    subtitle: 'Used to decide what "today" means for alerts',
                    valueText: provider.timezone,
                    onTap: () => showTimezonePicker(context, provider),
                  ),
                ]),
                const SizedBox(height: 24),

                // 5. Scanner & Barcode Options
                buildSectionHeader('SCANNER & RECOGNITION'),
                const SizedBox(height: 8),
                buildCardContainer([
                  SwitchListTile.adaptive(
                    value: provider.vibrateOnScan,
                    onChanged: (val) {
                      provider.setVibrateOnScan(val);
                      if (val) HapticFeedback.mediumImpact();
                    },
                    secondary: buildIconBox(Icons.vibration_rounded, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
                    title: const Text('Vibration on Scan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Haptic feedback when QR/Barcode detected', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    activeTrackColor: const Color(0xFF18181B),
                    activeThumbColor: Colors.white,
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: provider.beepOnScan,
                    onChanged: (val) => provider.setBeepOnScan(val),
                    secondary: buildIconBox(Icons.volume_up_outlined, const Color(0xFF06B6D4), const Color(0xFFECFEFF)),
                    title: const Text('Sound Feedback', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Play subtle tone on scan confirmation', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    activeTrackColor: const Color(0xFF18181B),
                    activeThumbColor: Colors.white,
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: provider.autoOpenOnScan,
                    onChanged: (val) => provider.setAutoOpenOnScan(val),
                    secondary: buildIconBox(Icons.open_in_new_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5)),
                    title: const Text('Auto-Open Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Instantly navigate to matched container/item', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    activeTrackColor: const Color(0xFF18181B),
                    activeThumbColor: Colors.white,
                  ),
                ]),
                const SizedBox(height: 24),

                // 6. Alerts & Notifications
                buildSectionHeader('ALERTS & NOTIFICATIONS'),
                const SizedBox(height: 8),
                buildCardContainer([
                  SwitchListTile.adaptive(
                    value: provider.notifyExpiring,
                    onChanged: (val) => provider.setNotifyExpiring(val),
                    secondary: buildIconBox(Icons.alarm_rounded, const Color(0xFFEF4444), const Color(0xFFFEF2F2)),
                    title: const Text('Expiring Items Alert', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Notify on items expiring in the alert window', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    activeTrackColor: const Color(0xFF18181B),
                    activeThumbColor: Colors.white,
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: provider.notifyOverdue,
                    onChanged: (val) => provider.setNotifyOverdue(val),
                    secondary: buildIconBox(Icons.assignment_late_outlined, const Color(0xFFF97316), const Color(0xFFFFF7ED)),
                    title: const Text('Overdue Lending Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Remind when borrowed assets pass due date', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    activeTrackColor: const Color(0xFF18181B),
                    activeThumbColor: Colors.white,
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: provider.notifyLowStock,
                    onChanged: (val) => provider.setNotifyLowStock(val),
                    secondary: buildIconBox(Icons.production_quantity_limits_rounded, const Color(0xFFEAB308), const Color(0xFFFEFCE8)),
                    title: const Text('Low Stock Warnings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Flag items needing replenishment', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    activeTrackColor: const Color(0xFF18181B),
                    activeThumbColor: Colors.white,
                  ),
                ]),
                const SizedBox(height: 24),

                // 7. Reports & Audit
                buildSectionHeader('REPORTS & INVENTORY AUDIT'),
                const SizedBox(height: 8),
                buildCardContainer([
                  ListTile(
                    leading: buildIconBox(Icons.qr_code_2_rounded, const Color(0xFF6366F1), const Color(0xFFEEF2FF)),
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
                    leading: buildIconBox(Icons.summarize_outlined, const Color(0xFF059669), const Color(0xFFD1FAE5)),
                    title: const Text(
                      'Export Inventory Report',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF18181B)),
                    ),
                    subtitle: Text(
                      'Generate & copy formatted summary of all assets',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                    onTap: () => showExportReportSheet(context, provider),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: buildIconBox(Icons.donut_large_outlined, const Color(0xFF2563EB), const Color(0xFFDBEAFE)),
                    title: const Text(
                      'Inventory Health Breakdown',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF18181B)),
                    ),
                    subtitle: Text(
                      'Status distribution: In Stock, Lent, Low Stock, Expired',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                    onTap: () => showInventoryStatusSheet(context, provider),
                  ),
                ]),
                const SizedBox(height: 24),

                // 8. Backend Server & API (Developer Mode Only - Unlocked via 7 taps on Version)
                if (_developerModeUnlocked) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildSectionHeader('DEVELOPER OPTIONS & BACKEND API'),
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
                  buildBackendSection(context, provider),
                  const SizedBox(height: 24),
                ],

                // 9. Application Info
                buildSectionHeader('APPLICATION INFO'),
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
                      buildInfoRow(
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
                      buildInfoRow('Design System', 'Minimal Charcoal (iOS Style)'),
                      const Divider(height: 20),
                      buildInfoRow('QR & Barcode Engine', 'MobileScanner v5'),
                      const Divider(height: 20),
                      buildInfoRow('Storage Architecture', 'Hierarchical Multi-Level Tree'),
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
            onPressed: () => showEditProfileDialog(context, provider),
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

  // ==========================================
  // MODAL BOTTOM SHEETS & DIALOGS
  // ==========================================

  // 1. Edit Profile Sheet

  // 2. Category Management Modal Sheet

  // 3. Currency Picker Sheet

  // 4. Default Unit Picker Sheet

  // 5. Expiry Days Warning Picker

  // Generic Selection Sheet Helper

  // 7. Export Report Sheet

  // 8. Inventory Health & Status Sheet

  // --- Backend Server Section ---
}

