import 'package:flutter/material.dart';

import '../utils/e2e.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../utils/text_normalize.dart';
import 'app_feedback.dart';
import 'app_form_field.dart';
import 'tappable.dart';
import 'app_icon.dart';
import 'soft_sheet.dart';
import 'soft_ui.dart';

/// The "lend an item" form. Opened from an item it comes with that item already chosen;
/// opened from the lending tracker the item is picked from a searchable list.
class LendItemSheet extends StatefulWidget {
  final Item? initialItem;

  const LendItemSheet({super.key, this.initialItem});

  static Future<void> show(BuildContext context, {Item? initialItem}) {
    return showSoftSheet<void>(
      context,
      title: context.l10n.lendAnItem,
      subtitle: context.l10n.lendSheetSubtitle,
      builder: (_) => LendItemSheet(initialItem: initialItem),
    );
  }

  @override
  State<LendItemSheet> createState() => _LendItemSheetState();
}

class _LendItemSheetState extends State<LendItemSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedItemId;
  final _borrowerNameCtrl = TextEditingController();
  final _borrowerContactCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final DateTime _lentDate = DateTime.now();
  DateTime? _expectedReturnDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // A non-lendable initial item (broken, lent...) is not preselected.
    final initial = widget.initialItem;
    _selectedItemId = initial != null && initial.canLend ? initial.id : null;
  }

  Future<void> _pickItem(List<Item> available) async {
    final picked = await showItemPickerSheet(context, available);
    if (picked != null && mounted) {
      setState(() {
        _selectedItemId = picked.id;
        _quantityCtrl.clear();
      });
    }
  }

  @override
  void dispose() {
    _borrowerNameCtrl.dispose();
    _borrowerContactCtrl.dispose();
    _notesCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  DateTime _inDays(int days) {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day).add(Duration(days: days));
  }

  bool _isPreset(int days) =>
      _expectedReturnDate != null &&
      daysBetweenToday(_expectedReturnDate!) == days;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _expectedReturnDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _expectedReturnDate = picked);
  }

  Future<void> _submit(InventoryProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItemId == null) {
      AppFeedback.showError(context, context.l10n.pleaseSelectAnItem);
      return;
    }
    setState(() => _submitting = true);
    final ok = await provider.lendItem(
      itemId: _selectedItemId!,
      borrowerName: _borrowerNameCtrl.text.trim(),
      borrowerContact: _borrowerContactCtrl.text.trim(),
      lentDate: _lentDate,
      expectedReturnDate: _expectedReturnDate,
      notes: _notesCtrl.text.trim(),
      quantity: double.tryParse(_quantityCtrl.text.trim()),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      AppFeedback.showSuccess(
        context,
        context.l10n.itemMarkedAsLentSuccessfully,
      );
    } else {
      setState(() => _submitting = false);
      AppFeedback.showError(context, context.l10n.somethingWentWrongPleaseTry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final c = context.colors;
    final l10n = context.l10n;
    // Only items that can be lent (stored or in use)
    final availableItems = provider.items
        .where((i) => i.canLend)
        .toList();
    final selectedItem = availableItems
        .where((i) => i.id == _selectedItemId)
        .firstOrNull;
    final labelStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: c.textPrimary,
    );

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SelectedItemCard(
              item: selectedItem,
              locked: selectedItem != null && widget.initialItem != null,
              onChange: () => _pickItem(availableItems),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppFormField(
                    id: 'lend_borrower',
                    label: '${l10n.borrowerName} *',
                    hintText: l10n.eGJohnDoe,
                    controller: _borrowerNameCtrl,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? l10n.pleaseEnterBorrowerName
                        : null,
                  ),
                ),
                if (selectedItem != null && selectedItem.quantity > 1) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 96,
                    child: AppFormField(
                      id: 'lend_quantity',
                      label: l10n.commonQuantity,
                      hintText: l10n.lendQuantityAll,
                      controller: _quantityCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) {
                        final text = val?.trim() ?? '';
                        if (text.isEmpty) return null;
                        final qty = double.tryParse(text);
                        if (qty == null || qty <= 0) {
                          return l10n.enterAQuantityGreaterThan;
                        }
                        if (qty > selectedItem.quantity) {
                          return l10n.onlyInStock(selectedItem.quantity);
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            AppFormField(
              id: 'lend_contact',
              label: l10n.borrowerContact,
              hintText: l10n.phoneNumberOrEmailOptional,
              controller: _borrowerContactCtrl,
            ),
            const SizedBox(height: 16),
            Text(l10n.expectedReturnDate, style: labelStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final (days, label) in [
                  (7, l10n.lendWeek1),
                  (14, l10n.lendWeeks2),
                  (30, l10n.lendMonth1),
                ]) ...[
                  Expanded(
                    child: _DateChip(
                      label: label,
                      selected: _isPreset(days),
                      onTap: () =>
                          setState(() => _expectedReturnDate = _inDays(days)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Tappable(
                  semanticLabel: l10n.lendPickDate,
                  onTap: _pickDate,
                  child: Container(
                    width: 44,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.fill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppIcon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: c.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (_expectedReturnDate != null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.lendDueBackOn(
                  DateFormat.yMMMEd(Localizations.localeOf(context).toString())
                      .format(_expectedReturnDate!),
                ),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            AppFormField(
              id: 'lend_notes',
              label: l10n.commonNotes,
              hintText: l10n.eGBorrowedForPhotography,
              controller: _notesCtrl,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            e2eId(
              'lend_save',
              SoftButton(
                expand: true,
                label: l10n.saveLoan,
                loading: _submitting,
                onPressed: _submitting ? null : () => _submit(provider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DateChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tappable(
      semanticLabel: label,
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? c.primary : c.fill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : c.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SelectedItemCard extends StatelessWidget {
  final Item? item;
  final bool locked;
  final VoidCallback onChange;

  const _SelectedItemCard({
    required this.item,
    required this.locked,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final provider = context.read<InventoryProvider>();
    final it = item;
    final sub = it == null
        ? null
        : l10n.lendAvailable(provider.formatQty(it.quantity, it.unit));
    final card = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: AppIcon(
              Icons.inventory_2_outlined,
              size: 20,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  it?.name ?? l10n.chooseAnAvailableItem,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: it == null ? c.textMuted : c.textPrimary,
                  ),
                ),
                if (sub != null)
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (!locked)
            Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                l10n.commonChange,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
    if (locked) return card;
    return Tappable(
      semanticLabel: l10n.selectItemToLend,
      onTap: onChange,
      child: card,
    );
  }
}

/// A searchable list of items to choose from (accent- and case-insensitive).
Future<Item?> showItemPickerSheet(BuildContext context, List<Item> items) {
  return showModalBottomSheet<Item>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ItemPickerSheet(items: items),
  );
}

class _ItemPickerSheet extends StatefulWidget {
  final List<Item> items;
  const _ItemPickerSheet({required this.items});

  @override
  State<_ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends State<_ItemPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = normalizeVi(_query.trim());
    final shown = q.isEmpty
        ? widget.items
        : widget.items
              .where(
                (i) =>
                    containsNormalized(i.name, q) ||
                    containsNormalized(i.barcode, q) ||
                    containsNormalized(i.serialNumber, q),
              )
              .toList();
    final c = context.colors;
    // Material (not a coloured Container) so the list tiles can paint their ink.
    return Material(
      color: c.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: context.l10n.searchItemsBarcodesSerials,
                  prefixIcon: const AppIcon(Icons.search, size: 20),
                ),
              ),
            ),
            Expanded(
              child: shown.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.noMatchingItemsFound,
                        style: TextStyle(color: c.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: shown.length,
                      itemBuilder: (context, i) {
                        final item = shown[i];
                        return ListTile(
                          title: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle:
                              item.barcode == null || item.barcode!.isEmpty
                              ? null
                              : Text(item.barcode!),
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks before marking a loan as returned, then reports the real outcome.
Future<void> confirmAndReturnLoan(
  BuildContext context,
  LendingRecord loan, {
  required String itemName,
}) async {
  final provider = context.read<InventoryProvider>();
  final confirmed = await AppFeedback.showConfirmDialog(
    context,
    title: context.l10n.confirmItemReturn,
    message: context.l10n.markReturnedBy(itemName, loan.borrowerName),
    confirmLabel: context.l10n.confirmReturn,
    icon: Icons.check_circle_outline,
  );
  if (!confirmed || !context.mounted) return;
  final ok = await provider.returnItem(loan.id);
  if (!context.mounted) return;
  if (ok) {
    AppFeedback.showSuccess(
      context,
      context.l10n.itemMarkedAsReturnedSuccessfully,
    );
  } else {
    AppFeedback.showError(context, context.l10n.somethingWentWrongPleaseTry);
  }
}
