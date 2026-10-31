import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import '../utils/e2e.dart';
import '../widgets/app_refresh.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/lend_item_sheet.dart';
import '../widgets/lending_parts.dart';
import '../widgets/soft_ui.dart';
import 'item_details_screen.dart';

class LendingTrackerScreen extends StatefulWidget {
  const LendingTrackerScreen({super.key});

  @override
  State<LendingTrackerScreen> createState() => _LendingTrackerScreenState();
}

class _LendingTrackerScreenState extends State<LendingTrackerScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final c = context.colors;
    final l10n = context.l10n;

    final activeLoans = provider.getActiveLoans();
    final overdue = activeLoans.where((l) => l.isOverdue).toList();
    final onTime = activeLoans.where((l) => !l.isOverdue).toList();
    final returned = provider.lendingRecords.where((l) => !l.isActive).toList();

    final List<Widget> content;
    if (_tab == 0) {
      content = activeLoans.isEmpty
          ? [
              EmptyStateCard(
                icon: Icons.check_circle_outline_rounded,
                title: l10n.noActiveLoans,
                subtitle: l10n.allYourItemsAreSafely,
              ),
            ]
          : [
              if (overdue.isNotEmpty) ...[
                LendingGroupLabel(l10n.tagOverdue, color: c.dangerStrong),
                for (final loan in overdue) _card(context, provider, loan),
              ],
              if (onTime.isNotEmpty) ...[
                LendingGroupLabel(l10n.lendingSectionOnTime.toUpperCase()),
                for (final loan in onTime) _card(context, provider, loan),
              ],
            ];
    } else {
      content = returned.isEmpty
          ? [
              EmptyStateCard(
                icon: Icons.history_rounded,
                title: l10n.noLendingHistory,
                subtitle: l10n.returnedItemsWillAppearHere,
              ),
            ]
          : [for (final loan in returned) _card(context, provider, loan)];
    }

    return Scaffold(
      backgroundColor: c.background,
      appBar: SoftTopAppBar(title: l10n.lendingTracker, backId: 'lending_back'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: LendingSegmented(
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
              tabs: [
                (
                  key: 'active',
                  label: l10n.lendingTabActive,
                  count: activeLoans.length,
                ),
                (
                  key: 'history',
                  label: l10n.lendingTabHistory,
                  count: returned.length,
                ),
              ],
            ),
          ),
          Expanded(
            child: AppRefresh(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  for (final w in content) ...[
                    w,
                    if (w is LoanCard) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: c.background,
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          MediaQuery.paddingOf(context).bottom + 8,
        ),
        child: e2eId(
          'lending_lend',
          SoftButton(
            label: l10n.lendItem,
            icon: Icons.add_rounded,
            expand: true,
            onPressed: () => LendItemSheet.show(context),
          ),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    InventoryProvider provider,
    LendingRecord loan,
  ) {
    final l10n = context.l10n;
    final item = provider.getItemById(loan.itemId);
    final name = item?.name ?? l10n.unknownItem;
    final overdue = loan.isOverdue;
    final active = loan.isActive;
    final c = context.colors;

    final (chipBg, chipFg, chip) = overdue
        ? (c.dangerSoft, c.dangerStrong, l10n.tagOverdue)
        : active
        ? (c.warningSoft, c.warningStrong, l10n.tagLent)
        : (c.successSoft, c.successStrong, l10n.tagReturned);

    var borrower = l10n.lentTo(loan.borrowerName);
    if (loan.isPartial && item != null) {
      borrower = l10n.lentToQty(
        loan.borrowerName,
        provider.formatQty(loan.quantity, item.unit),
      );
    }

    final String dueLabel;
    final String dueValue;
    if (!active) {
      dueLabel = l10n.lendingReturnedLabel;
      dueValue = formatDate(context, loan.actualReturnDate!);
    } else if (loan.expectedReturnDate == null) {
      dueLabel = l10n.lendingLentSince;
      dueValue = formatDate(context, loan.lentDate);
    } else {
      final due = loan.expectedReturnDate!;
      final days = daysBetweenToday(due);
      dueLabel = l10n.lendingExpectedReturn;
      dueValue = days < 0
          ? l10n.loanDueLate(formatDate(context, due), -days)
          : l10n.loanDueIn(formatDate(context, due), days);
    }

    return LoanCard(
      itemName: name,
      borrower: borrower,
      chipLabel: chip,
      chipBackground: chipBg,
      chipForeground: chipFg,
      dueLabel: dueLabel,
      dueValue: dueValue,
      overdue: overdue,
      returnLabel: l10n.markAsReturned,
      onReturn: active
          ? () => confirmAndReturnLoan(context, loan, itemName: name)
          : null,
      onTap: item == null
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemDetailsScreen(itemId: item.id),
              ),
            ),
    );
  }
}
