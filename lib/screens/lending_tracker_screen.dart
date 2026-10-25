import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_form_field.dart';
import '../widgets/app_refresh.dart';
import '../widgets/tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

class LendingTrackerScreen extends StatefulWidget {
  const LendingTrackerScreen({super.key});

  @override
  State<LendingTrackerScreen> createState() => _LendingTrackerScreenState();
}

class _LendingTrackerScreenState extends State<LendingTrackerScreen> with SingleTickerProviderStateMixin {
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
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: context.colors.textPrimary),
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
        backgroundColor: context.colors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: Text(context.l10n.lendItem, style: TextStyle(fontWeight: FontWeight.bold)),
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
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
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
                          style: TextStyle(color: context.colors.dangerStrong, fontSize: 12),
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
                _buildTabChip(1, context.l10n.commonHistory(returnedLoans.length)),
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
                    : AppRefresh(child: ListView.builder(
 physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: activeLoans.length,
                        itemBuilder: (context, index) {
                          return _buildLoanCard(context, activeLoans[index]);
                        },
                      )),

                // History
                returnedLoans.isEmpty
                    ? _buildEmptyState(
                        icon: Icons.history_rounded,
                        title: context.l10n.noLendingHistory,
                        message: context.l10n.returnedItemsWillAppearHere,
                      )
                    : AppRefresh(child: ListView.builder(
 physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: returnedLoans.length,
                        itemBuilder: (context, index) {
                          return _buildLoanCard(context, returnedLoans[index]);
                        },
                      )),
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
          color: isSelected ? context.colors.primary : context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : context.colors.textPrimary,
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
            Icon(icon, size: 56, color: context.colors.textMuted),
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

    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: isOverdue ? Border.all(color: const Color(0xFFEF4444), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? context.colors.dangerSoft
                      : isActive
                          ? context.colors.warningSoft
                          : context.colors.successSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isOverdue
                      ? 'OVERDUE'
                      : isActive
                          ? 'LENT'
                          : 'RETURNED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isOverdue
                        ? const Color(0xFFDC2626)
                        : isActive
                            ? const Color(0xFFD97706)
                            : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Details row
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: context.colors.textMuted),
              const SizedBox(width: 6),
              Text(
                context.l10n.commonLent2(dateFormat.format(record.lentDate)),
                style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
              ),
              if (record.expectedReturnDate != null) ...[
                const SizedBox(width: 14),
                Icon(Icons.event_outlined, size: 14, color: isOverdue ? Colors.red : context.colors.textMuted),
                const SizedBox(width: 6),
                Text(
                  context.l10n.commonDue(dateFormat.format(record.expectedReturnDate!)),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    color: isOverdue ? Colors.red.shade700 : context.colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),

          if (record.borrowerContact.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 14, color: context.colors.textMuted),
                const SizedBox(width: 6),
                Text(
                  record.borrowerContact,
                  style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                ),
              ],
            ),
          ],

          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              record.notes,
              style: TextStyle(fontSize: 12, color: context.colors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],

          // Action if Active
          if (isActive) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _confirmReturn(context, record, item),
                icon: const Icon(Icons.assignment_turned_in_outlined, size: 18),
                label: Text(context.l10n.markAsReturned),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmReturn(BuildContext context, LendingRecord record, Item? item) async {
    final provider = Provider.of<InventoryProvider>(context, listen: false);

    final confirmed = await AppFeedback.showConfirmDialog(
      context,
      title: context.l10n.confirmItemReturn,
      message: context.l10n.markReturnedBy(item?.name ?? context.l10n.itemFallbackName, record.borrowerName),
      confirmLabel: context.l10n.confirmReturn,
      icon: Icons.check_circle_outline,
    );

    if (confirmed && context.mounted) {
      provider.returnItem(record.id);
      AppFeedback.showSuccess(context, context.l10n.itemMarkedAsReturnedSuccessfully);
    }
  }

  void _showLendItemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LendItemFormSheet(),
    );
  }
}

class _LendItemFormSheet extends StatefulWidget {
  const _LendItemFormSheet();

  @override
  State<_LendItemFormSheet> createState() => _LendItemFormSheetState();
}

class _LendItemFormSheetState extends State<_LendItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedItemId;
  final _borrowerNameCtrl = TextEditingController();
  final _borrowerContactCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final DateTime _lentDate = DateTime.now();
  DateTime? _expectedReturnDate;

  @override
  void dispose() {
    _borrowerNameCtrl.dispose();
    _borrowerContactCtrl.dispose();
    _notesCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    // Only items not currently lent
    final availableItems = provider.items.where((i) => i.status != ItemStatus.lent).toList();
    final selectedItem = availableItems.where((i) => i.id == _selectedItemId).firstOrNull;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.lendAnItem,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
 tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Item selector
              Text(
                context.l10n.selectItemToLend,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: context.colors.fill,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedItemId,
                    hint: Text(context.l10n.chooseAnAvailableItem),
                    items: availableItems.map((item) {
                      return DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() {
                      _selectedItemId = val;
                      _quantityCtrl.clear();
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (selectedItem != null && selectedItem.quantity > 1) ...[
                AppFormField(
                  label: context.l10n.quantityToLend,
                  hintText: context.l10n.leaveEmptyToLendAll(provider.formatQty(selectedItem.quantity, selectedItem.unit)),
                  controller: _quantityCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    final text = val?.trim() ?? '';
                    if (text.isEmpty) return null;
                    final qty = double.tryParse(text);
                    if (qty == null || qty <= 0) return context.l10n.enterAQuantityGreaterThan;
                    if (qty > selectedItem.quantity) return context.l10n.onlyInStock(selectedItem.quantity);
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              AppFormField(
                label: context.l10n.borrowerName,
                hintText: context.l10n.eGJohnDoe,
                controller: _borrowerNameCtrl,
                validator: (val) => val == null || val.trim().isEmpty ? context.l10n.pleaseEnterBorrowerName : null,
              ),
              const SizedBox(height: 16),

              AppFormField(
                label: context.l10n.borrowerContact,
                hintText: context.l10n.phoneNumberOrEmailOptional,
                controller: _borrowerContactCtrl,
              ),
              const SizedBox(height: 16),

              // Expected return date picker
              Text(
                context.l10n.expectedReturnDate,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Tappable(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _expectedReturnDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  decoration: BoxDecoration(
                    color: context.colors.fill,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _expectedReturnDate != null
                            ? DateFormat('MMM dd, yyyy').format(_expectedReturnDate!)
                            : context.l10n.selectDueDateOptional,
                        style: TextStyle(
                          color: _expectedReturnDate != null ? context.colors.textPrimary : context.colors.textMuted,
                          fontWeight: _expectedReturnDate != null ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const Icon(Icons.calendar_month_outlined, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              AppFormField(
                label: context.l10n.commonNotes,
                hintText: context.l10n.eGBorrowedForPhotography,
                controller: _notesCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedItemId == null) {
                        AppFeedback.showError(context, context.l10n.pleaseSelectAnItem);
                        return;
                      }

                      provider.lendItem(
                        itemId: _selectedItemId!,
                        borrowerName: _borrowerNameCtrl.text.trim(),
                        borrowerContact: _borrowerContactCtrl.text.trim(),
                        lentDate: _lentDate,
                        expectedReturnDate: _expectedReturnDate,
                        notes: _notesCtrl.text.trim(),
                        quantity: double.tryParse(_quantityCtrl.text.trim()),
                      );

                      Navigator.pop(context);
                      AppFeedback.showSuccess(context, context.l10n.itemMarkedAsLentSuccessfully);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(context.l10n.saveLoan, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
