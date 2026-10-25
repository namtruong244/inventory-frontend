import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'item_details_screen.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    final expiredItems = provider.getExpiredItems();
    final expiringSoon = provider.getExpiringItems(withinDays: provider.expiryWarningDays);
    final expiringWarranties = provider.getExpiringWarranties(withinDays: provider.warrantyWarningDays);
    final overdueLoans = provider.getOverdueLoans();
    final lowStockItems = provider.notifyLowStock ? provider.getLowStockItems() : <Item>[];

    final totalAlerts = expiredItems.length +
        expiringSoon.length +
        expiringWarranties.length +
        overdueLoans.length +
        lowStockItems.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF18181B)),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Lifecycle & Alerts',
          style: TextStyle(
            color: Color(0xFF18181B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: totalAlerts == 0
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1FAE5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_rounded, size: 56, color: Color(0xFF059669)),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'All Good!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No items are expired, expiring soon, or overdue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              children: [
                // 1. Expired Items Section
                if (expiredItems.isNotEmpty) ...[
                  _buildSectionHeader(
                    title: 'Expired Items',
                    count: expiredItems.length,
                    color: const Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 10),
                  ...expiredItems.map((item) => _buildExpiredCard(context, item, provider)),
                  const SizedBox(height: 24),
                ],

                // 2. Expiring Soon Section (within 30 days)
                if (expiringSoon.isNotEmpty) ...[
                  _buildSectionHeader(
                    title: 'Expiring Soon (Perishables)',
                    count: expiringSoon.length,
                    color: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 10),
                  ...expiringSoon.map((item) => _buildExpiringCard(context, item, provider)),
                  const SizedBox(height: 24),
                ],

                // 3. Warranty Expiring Section
                if (expiringWarranties.isNotEmpty) ...[
                  _buildSectionHeader(
                    title: 'Warranties Ending Soon',
                    count: expiringWarranties.length,
                    color: const Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 10),
                  ...expiringWarranties.map((item) => _buildWarrantyCard(context, item, provider)),
                  const SizedBox(height: 24),
                ],

                // 4. Overdue Loans Section
                if (overdueLoans.isNotEmpty) ...[
                  _buildSectionHeader(
                    title: 'Overdue Borrowed Items',
                    count: overdueLoans.length,
                    color: const Color(0xFF9333EA),
                  ),
                  const SizedBox(height: 10),
                  ...overdueLoans.map((loan) {
                    final item = provider.getItemById(loan.itemId);
                    return _buildOverdueLoanCard(context, loan, item);
                  }),
                  const SizedBox(height: 24),
                ],

                // 5. Low Stock Warnings Section
                if (lowStockItems.isNotEmpty) ...[
                  _buildSectionHeader(
                    title: 'Low Stock Warnings',
                    count: lowStockItems.length,
                    color: const Color(0xFFD97706),
                  ),
                  const SizedBox(height: 10),
                  ...lowStockItems.map((item) => _buildLowStockAlertCard(context, item, provider)),
                ],
              ],
            ),
    );
  }

  Widget _buildLowStockAlertCard(BuildContext context, Item item, InventoryProvider provider) {
    final parentBox = provider.getBoxById(item.boxId);
    final breadcrumb = parentBox != null ? provider.getBreadcrumbString(parentBox.id) : 'Storage';
    final qty = item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity;
    final minQty = item.minQuantity! % 1 == 0 ? item.minQuantity!.toInt() : item.minQuantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.production_quantity_limits_rounded, color: Color(0xFFD97706), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  breadcrumb,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Only $qty ${item.unit} remaining (Threshold: ≤ $minQty ${item.unit})',
                  style: const TextStyle(color: Color(0xFFD97706), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemDetailsScreen(itemId: item.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required int count, required Color color}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF18181B),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpiredCard(BuildContext context, Item item, InventoryProvider provider) {
    final breadcrumb = provider.getBreadcrumbString(item.boxId);
    final daysAgo = DateTime.now().difference(item.expiryDate!).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.dangerous_outlined, color: Color(0xFFDC2626), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  breadcrumb,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Expired $daysAgo ${daysAgo == 1 ? 'day' : 'days'} ago (${DateFormat('MMM dd, yyyy').format(item.expiryDate!)})',
                  style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemDetailsScreen(itemId: item.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringCard(BuildContext context, Item item, InventoryProvider provider) {
    final breadcrumb = provider.getBreadcrumbString(item.boxId);
    final daysLeft = item.expiryDate!.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent ? const Color(0xFFFCD34D) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUrgent ? const Color(0xFFFEF3C7) : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              color: isUrgent ? const Color(0xFFD97706) : Colors.grey.shade700,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  breadcrumb,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Expires in $daysLeft days (${DateFormat('MMM dd, yyyy').format(item.expiryDate!)})',
                  style: TextStyle(
                    color: isUrgent ? const Color(0xFFD97706) : Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: isUrgent ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemDetailsScreen(itemId: item.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWarrantyCard(BuildContext context, Item item, InventoryProvider provider) {
    final breadcrumb = provider.getBreadcrumbString(item.boxId);
    final daysLeft = item.warrantyExpiryDate!.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.security_outlined, color: Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  breadcrumb,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Warranty ends in $daysLeft days',
                  style: const TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemDetailsScreen(itemId: item.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverdueLoanCard(BuildContext context, LendingRecord loan, Item? item) {
    final daysOverdue = DateTime.now().difference(loan.expectedReturnDate!).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF3E8FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_late_outlined, color: Color(0xFF9333EA), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item?.name ?? 'Borrowed Item',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  'Borrower: ${loan.borrowerName} • ${loan.borrowerContact}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '$daysOverdue ${daysOverdue == 1 ? 'day' : 'days'} overdue',
                  style: const TextStyle(color: Color(0xFF9333EA), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
