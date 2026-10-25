import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../screens/alerts_screen.dart';
import '../screens/lending_tracker_screen.dart';

/// Home tab sections. Navigation and tab switching stay owned by the home
/// screen and are passed in as callbacks.
class HomeSections {
  final BuildContext context;
  final Future<void> Function(Widget page) navigate;
  final void Function(int index) selectTab;

  HomeSections(this.context, {required this.navigate, required this.selectTab});

  Widget buildConnectionBanner() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        if (provider.isConnected) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFCA5A5)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xFFEF4444),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  provider.isOffline
                      ? 'Offline: showing saved data'
                          '${provider.pendingChanges > 0 ? ' · ${provider.pendingChanges} change(s) waiting to sync' : ''}'
                      : 'Cannot connect to backend (${provider.serverUrl})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF991B1B),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => provider.fetchAllData(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildAlertBanner() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        final alertCount = provider.totalAlertCount;
        final overdueCount = provider.getOverdueLoans().length;
        final expiredCount = provider.getExpiredItems().length;
        if (alertCount == 0) return const SizedBox.shrink();

        String alertMessage = '';
        if (overdueCount > 0 && expiredCount > 0) {
          alertMessage =
              '$overdueCount overdue loan & $expiredCount expired item require action';
        } else if (overdueCount > 0) {
          alertMessage = '$overdueCount item loan is currently overdue!';
        } else {
          alertMessage = '$alertCount items/warranties require your attention';
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFCA5A5).withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Action Required',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alertMessage,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => navigate(const AlertsScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildQuickModulesSection() {
    final provider = Provider.of<InventoryProvider>(context);
    final activeLoans = provider.getActiveLoans().length;
    final totalAlerts = provider.totalAlertCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // Lending Tracker Quick Card
          Expanded(
            child: GestureDetector(
              onTap: () => navigate(const LendingTrackerScreen()),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.handshake_outlined,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lending',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF18181B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activeLoans > 0
                                ? '$activeLoans Active'
                                : 'No Loans',
                            style: TextStyle(
                              fontSize: 12,
                              color: activeLoans > 0
                                  ? const Color(0xFF2563EB)
                                  : Colors.grey.shade500,
                              fontWeight: activeLoans > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Expiration & Alerts Quick Card
          Expanded(
            child: GestureDetector(
              onTap: () => navigate(const AlertsScreen()),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            (totalAlerts > 0
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF10B981))
                                .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        totalAlerts > 0
                            ? Icons.notifications_active_outlined
                            : Icons.shield_outlined,
                        color: totalAlerts > 0
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF059669),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alerts',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF18181B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            totalAlerts > 0
                                ? '$totalAlerts Issues'
                                : 'All Clear',
                            style: TextStyle(
                              fontSize: 12,
                              color: totalAlerts > 0
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF059669),
                              fontWeight: totalAlerts > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
