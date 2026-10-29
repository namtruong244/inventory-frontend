import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_refresh.dart';
import '../widgets/lend_item_sheet.dart';
import '../widgets/tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../utils/date_format.dart';
import '../widgets/app_icon.dart';
import '../widgets/soft_ui.dart';

class LendingTrackerScreen extends StatefulWidget {
  const LendingTrackerScreen({super.key});

  @override
  State<LendingTrackerScreen> createState() => _LendingTrackerScreenState();
}

class _LendingTrackerScreenState extends State<LendingTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    final activeLoans = provider.getActiveLoans();
    final overdueLoans = provider.getOverdueLoans();
    final allLoans = provider.lendingRecords;
    final returnedLoans = allLoans.where((l) => !l.isActive).toList();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: context.colors.textPrimary,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          context.l10n.lendingTracker,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLendItemSheet(context),
        icon: const AppIcon(Icons.add_rounded, size: 22),
        label: Text(context.l10n.lendItem),
      ),
      body: Column(
        children: [
          // Overdue Banner if any
          if (overdueLoans.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.dangerSoft, // Light red
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTones.coral,
                      shape: BoxShape.circle,
                    ),
                    child: const AppIcon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${overdueLoans.length} Overdue ${overdueLoans.length == 1 ? 'Loan' : context.l10n.commonLoans}',
                          style: TextStyle(
                            color: context.colors.dangerStrong,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.itemsHavePassedTheirExpected,
                          style: TextStyle(
                            color: context.colors.dangerStrong,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Filter Tabs (Consistent with Items and Boxes screens)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                _buildTabChip(0, context.l10n.commonActive(activeLoans.length)),
                const SizedBox(width: 8),
                _buildTabChip(
                  1,
                  context.l10n.commonHistory(returnedLoans.length),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tab Contents
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Loans
                activeLoans.isEmpty
                    ? _buildEmptyState(
                        icon: Icons.check_circle_outline_rounded,
                        title: context.l10n.noActiveLoans,
                        message: context.l10n.allYourItemsAreSafely,
                      )
                    : AppRefresh(
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: activeLoans.length,
                          itemBuilder: (context, index) {
                            return _buildLoanCard(context, activeLoans[index]);
                          },
                        ),
                      ),

                // History
                returnedLoans.isEmpty
                    ? _buildEmptyState(
                        icon: Icons.history_rounded,
                        title: context.l10n.noLendingHistory,
                        message: context.l10n.returnedItemsWillAppearHere,
                      )
                    : AppRefresh(
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: returnedLoans.length,
                          itemBuilder: (context, index) {
                            return _buildLoanCard(
                              context,
                              returnedLoans[index],
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(int index, String label) {
    final isSelected = _tabController.index == index;

    return Tappable(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.accent : context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? context.colors.onAccent
                : context.colors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 56, color: context.colors.textMuted),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard(BuildContext context, LendingRecord record) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final item = provider.getItemById(record.itemId);
    final isOverdue = record.isOverdue;
    final isActive = record.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: context.colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Item name + Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item?.name ?? context.l10n.unknownItem,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.lentTo(record.borrowerName),
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SoftChip.tone(
                isOverdue
                    ? context.l10n.tagOverdue
                    : isActive
                    ? context.l10n.tagLent
                    : context.l10n.tagReturned,
                isOverdue
                    ? AppTones.coral
                    : (isActive ? AppTones.amber : AppTones.matcha),
                dot: true,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Details row
          Row(
            children: [
              AppIcon(
                Icons.calendar_today_outlined,
                size: 14,
                color: context.colors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                context.l10n.commonLent2(formatDate(context, record.lentDate)),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ),
              if (record.expectedReturnDate != null) ...[
                const SizedBox(width: 14),
                AppIcon(
                  Icons.event_outlined,
                  size: 14,
                  color: isOverdue ? AppTones.coral : context.colors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.commonDue(
                    formatDate(context, record.expectedReturnDate!),
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    color: isOverdue
                        ? AppTones.coral
                        : context.colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),

          // Time elapsed between lend date and due date
          if (isActive && record.expectedReturnDate != null) ...[
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final total = record.expectedReturnDate!
                    .difference(record.lentDate)
                    .inMinutes;
                final spent = DateTime.now()
                    .difference(record.lentDate)
                    .inMinutes;
                final ratio = total <= 0
                    ? 1.0
                    : (spent / total).clamp(0.0, 1.0);
                return SoftBar(
                  value: ratio,
                  color: isOverdue ? AppTones.coral : AppTones.amber,
                  height: 6,
                );
              },
            ),
          ],

          if (record.borrowerContact.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                AppIcon(
                  Icons.phone_outlined,
                  size: 14,
                  color: context.colors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  record.borrowerContact,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              record.notes,
              style: TextStyle(
                fontSize: 12,
                color: context.colors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Action if Active
          if (isActive) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _confirmReturn(context, record, item),
                icon: const AppIcon(
                  Icons.assignment_turned_in_outlined,
                  size: 18,
                ),
                label: Text(context.l10n.markAsReturned),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmReturn(BuildContext context, LendingRecord record, Item? item) =>
      confirmAndReturnLoan(
        context,
        record,
        itemName: item?.name ?? context.l10n.itemFallbackName,
      );

  void _showLendItemSheet(BuildContext context) => LendItemSheet.show(context);
}
