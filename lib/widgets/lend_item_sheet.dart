import 'package:flutter/material.dart';
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

/// The "lend an item" form. Opened from an item it comes with that item already chosen;
/// opened from the lending tracker the item is picked from a searchable list.
class LendItemSheet extends StatefulWidget {
  final Item? initialItem;

  const LendItemSheet({super.key, this.initialItem});

  static Future<void> show(BuildContext context, {Item? initialItem}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
    _selectedItemId = widget.initialItem?.id;
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    // Only items not currently lent
    final availableItems = provider.items
        .where((i) => i.status != ItemStatus.lent)
        .toList();
    final selectedItem = availableItems
        .where((i) => i.id == _selectedItemId)
        .firstOrNull;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
                    tooltip: MaterialLocalizations.of(context)
                        .closeButtonTooltip,
                    onPressed: () => Navigator.pop(context),
                    icon: const AppIcon(Icons.close_rounded),
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
              Tappable(
                // The item is fixed when the form was opened from it.
                onTap: widget.initialItem != null
                    ? null
                    : () => _pickItem(availableItems),
                semanticLabel: context.l10n.selectItemToLend,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.fill,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedItem?.name ??
                              context.l10n.chooseAnAvailableItem,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selectedItem != null
                                ? context.colors.textPrimary
                                : context.colors.textMuted,
                            fontWeight: selectedItem != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (widget.initialItem == null)
                        AppIcon(
                          Icons.search_rounded,
                          size: 20,
                          color: context.colors.textSecondary,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (selectedItem != null && selectedItem.quantity > 1) ...[
                AppFormField(
                  label: context.l10n.quantityToLend,
                  hintText: context.l10n.leaveEmptyToLendAll(
                    provider.formatQty(
                      selectedItem.quantity,
                      selectedItem.unit,
                    ),
                  ),
                  controller: _quantityCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (val) {
                    final text = val?.trim() ?? '';
                    if (text.isEmpty) return null;
                    final qty = double.tryParse(text);
                    if (qty == null || qty <= 0) {
                      return context.l10n.enterAQuantityGreaterThan;
                    }
                    if (qty > selectedItem.quantity) {
                      return context.l10n.onlyInStock(selectedItem.quantity);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              AppFormField(
                label: context.l10n.borrowerName,
                hintText: context.l10n.eGJohnDoe,
                controller: _borrowerNameCtrl,
                validator: (val) => val == null || val.trim().isEmpty
                    ? context.l10n.pleaseEnterBorrowerName
                    : null,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.fill,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _expectedReturnDate != null
                            ? DateFormat.yMMMd(
                                Localizations.localeOf(context).toString(),
                              ).format(_expectedReturnDate!)
                            : context.l10n.selectDueDateOptional,
                        style: TextStyle(
                          color: _expectedReturnDate != null
                              ? context.colors.textPrimary
                              : context.colors.textMuted,
                          fontWeight: _expectedReturnDate != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      const AppIcon(Icons.calendar_month_outlined, size: 20),
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
                  onPressed: _submitting
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_selectedItemId == null) {
                              AppFeedback.showError(
                                context,
                                context.l10n.pleaseSelectAnItem,
                              );
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
                              quantity: double.tryParse(
                                _quantityCtrl.text.trim(),
                              ),
                            );

                            if (!context.mounted) return;
                            if (ok) {
                              Navigator.pop(context);
                              AppFeedback.showSuccess(
                                context,
                                context.l10n.itemMarkedAsLentSuccessfully,
                              );
                            } else {
                              setState(() => _submitting = false);
                              AppFeedback.showError(
                                context,
                                context.l10n.somethingWentWrongPleaseTry,
                              );
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    context.l10n.saveLoan,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
