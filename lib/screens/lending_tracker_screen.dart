import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_form_field.dart';

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
          'Lending Tracker',
          style: TextStyle(
            color: Color(0xFF18181B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLendItemSheet(context),
        backgroundColor: const Color(0xFF18181B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Lend Item', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Overdue Banner if any
          if (overdueLoans.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2), // Light red
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
                          '${overdueLoans.length} Overdue ${overdueLoans.length == 1 ? 'Loan' : 'Loans'}',
                          style: const TextStyle(
                            color: Color(0xFF991B1B),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Items have passed their expected return date.',
                          style: TextStyle(color: Color(0xFFB91C1C), fontSize: 12),
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
                _buildTabChip(0, 'Active (${activeLoans.length})'),
                const SizedBox(width: 8),
                _buildTabChip(1, 'History (${returnedLoans.length})'),
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
                        title: 'No active loans',
                        message: 'All your items are safely in storage.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: activeLoans.length,
                        itemBuilder: (context, index) {
                          return _buildLoanCard(context, activeLoans[index]);
                        },
                      ),

                // History
                returnedLoans.isEmpty
                    ? _buildEmptyState(
                        icon: Icons.history_rounded,
                        title: 'No lending history',
                        message: 'Returned items will appear here.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: returnedLoans.length,
                        itemBuilder: (context, index) {
                          return _buildLoanCard(context, returnedLoans[index]);
                        },
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

    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF18181B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF18181B),
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
            Icon(icon, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
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
        color: Colors.white,
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
                      item?.name ?? 'Unknown Item',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lent to ${record.borrowerName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
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
                      ? const Color(0xFFFEE2E2)
                      : isActive
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFD1FAE5),
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
              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                'Lent: ${dateFormat.format(record.lentDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              if (record.expectedReturnDate != null) ...[
                const SizedBox(width: 14),
                Icon(Icons.event_outlined, size: 14, color: isOverdue ? Colors.red : Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  'Due: ${dateFormat.format(record.expectedReturnDate!)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    color: isOverdue ? Colors.red.shade700 : Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),

          if (record.borrowerContact.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  record.borrowerContact,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],

          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              record.notes,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
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
                label: const Text('Mark as Returned'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF18181B),
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
      title: 'Confirm Item Return',
      message: 'Mark "${item?.name ?? 'item'}" as returned by ${record.borrowerName}?\nStatus will change back to Stored.',
      confirmLabel: 'Confirm Return',
      icon: Icons.check_circle_outline,
    );

    if (confirmed && context.mounted) {
      provider.returnItem(record.id);
      AppFeedback.showSuccess(context, 'Item marked as returned successfully');
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
      decoration: const BoxDecoration(
        color: Colors.white,
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lend an Item',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Item selector
              const Text(
                'Select Item to Lend',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedItemId,
                    hint: const Text('Choose an available item...'),
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
                  label: 'Quantity to lend',
                  hintText: 'Leave empty to lend all '
                      '(${provider.formatQty(selectedItem.quantity, selectedItem.unit)} in stock)',
                  controller: _quantityCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    final text = val?.trim() ?? '';
                    if (text.isEmpty) return null;
                    final qty = double.tryParse(text);
                    if (qty == null || qty <= 0) return 'Enter a quantity greater than 0';
                    if (qty > selectedItem.quantity) return 'Only ${selectedItem.quantity} in stock';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              AppFormField(
                label: 'Borrower Name',
                hintText: 'e.g. John Doe',
                controller: _borrowerNameCtrl,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter borrower name' : null,
              ),
              const SizedBox(height: 16),

              AppFormField(
                label: 'Borrower Contact',
                hintText: 'Phone number or email (Optional)',
                controller: _borrowerContactCtrl,
              ),
              const SizedBox(height: 16),

              // Expected return date picker
              const Text(
                'Expected Return Date',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GestureDetector(
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
                    color: const Color(0xFFF4F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _expectedReturnDate != null
                            ? DateFormat('MMM dd, yyyy').format(_expectedReturnDate!)
                            : 'Select due date (Optional)',
                        style: TextStyle(
                          color: _expectedReturnDate != null ? const Color(0xFF18181B) : const Color(0xFFA1A1AA),
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
                label: 'Notes',
                hintText: 'e.g. Borrowed for photography project',
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
                        AppFeedback.showError(context, 'Please select an item');
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
                      AppFeedback.showSuccess(context, 'Item marked as lent successfully');
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF18181B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Loan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
