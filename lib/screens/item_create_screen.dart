import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/date_format.dart';
import 'package:provider/provider.dart';
import '../widgets/item_category_sheets.dart';
import '../widgets/item_form_attributes.dart';
import '../widgets/item_photo_modal.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/trash_actions.dart';
import '../widgets/app_form_field.dart';
import '../widgets/app_image_view.dart';
import '../widgets/barcode_scan_sheet.dart';
import '../widgets/location_picker_sheet.dart';
import '../widgets/tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../widgets/app_icon.dart';

part 'item_create_sections.dart';

class ItemCreateScreen extends StatefulWidget {
  final String boxId;
  final Item? existingItem;
  final String? initialBarcode;

  const ItemCreateScreen({
    super.key,
    required this.boxId,
    this.existingItem,
    this.initialBarcode,
  });

  @override
  State<ItemCreateScreen> createState() => _ItemCreateScreenState();
}

class _ItemCreateScreenState extends State<ItemCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _currentBoxId;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _minQuantityController = TextEditingController();
  final _unitController = TextEditingController(text: 'pcs');
  final _serialController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = '';
  ItemStatus _selectedStatus = ItemStatus.stored;
  bool _isConsumable = false;

  DateTime? _purchaseDate;
  DateTime? _warrantyExpiryDate;
  DateTime? _expiryDate;

  bool _isLoading = false;
  List<String> _photos = [];
  List<String> _receiptPhotos = [];
  final Map<String, String> _customAttributes = {};
  bool _initializedUnit = false;

  /// True once the user changed something; leaving then asks for confirmation.
  bool _dirty = false;

  /// setState entry point for the section extensions in the part file.
  void _update(VoidCallback fn) {
    _dirty = true;
    setState(fn);
  }

  bool _tracking = false;

  /// Typing marks the form as changed (once the starting values are in place).
  void _markDirty() {
    if (_tracking && !_dirty) setState(() => _dirty = true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedUnit && widget.existingItem == null) {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      if (provider.defaultUnit.trim().isNotEmpty) {
        _unitController.text = provider.defaultUnit.trim();
      }
      _selectedCategory = _suggestedCategory(provider);
      _initializedUnit = true;
    }
  }

  /// The category of the newest item if it still exists, else the first category.
  String _suggestedCategory(InventoryProvider provider) {
    if (provider.items.isNotEmpty) {
      final newest = provider.items.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
      if (provider.categories.contains(newest.categoryId)) return newest.categoryId;
    }
    return provider.categories.isNotEmpty ? provider.categories.first : 'General';
  }

  List<String> _getCommonUnits(String defaultUnit) {
    final list = <String>[];
    if (defaultUnit.trim().isNotEmpty) {
      list.add(defaultUnit.trim());
    }
    const standard = ["pcs", "box", "pack", "set", "kg", "g", "pair", "bottle", "m", "can", "roll"];
    for (final s in standard) {
      if (!list.any((item) => item.toLowerCase() == s.toLowerCase())) {
        list.add(s);
      }
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _currentBoxId = widget.boxId;

    if (widget.existingItem != null) {
      final i = widget.existingItem!;
      _currentBoxId = i.boxId;
      _nameController.text = i.name;
      _descriptionController.text = i.description;
      _quantityController.text = i.quantity % 1 == 0 ? i.quantity.toInt().toString() : i.quantity.toString();
      if (i.minQuantity != null) {
        _minQuantityController.text = i.minQuantity! % 1 == 0
            ? i.minQuantity!.toInt().toString()
            : i.minQuantity!.toString();
      }
      _unitController.text = i.unit;
      _serialController.text = i.serialNumber ?? '';
      _barcodeController.text = i.barcode ?? '';
      _priceController.text = i.purchasePrice != null ? i.purchasePrice!.toStringAsFixed(2) : '';
      _selectedCategory = i.categoryId;
      _selectedStatus = i.status;
      _isConsumable = i.isConsumable;
      _purchaseDate = i.purchaseDate;
      _warrantyExpiryDate = i.warrantyExpiryDate;
      _expiryDate = i.expiryDate;
      _photos = List<String>.from(i.photos);
      _receiptPhotos = List<String>.from(i.receiptPhotos);
      if (i.customAttributes.isNotEmpty) {
        i.customAttributes.forEach((k, v) {
          _customAttributes[k] = v.toString();
        });
      }
    } else if (widget.initialBarcode != null) {
      _barcodeController.text = widget.initialBarcode!;
    }
    // Only edits from here on count: the values above are the starting point.
    WidgetsBinding.instance.addPostFrameCallback((_) => _tracking = true);
    for (final c in [
      _nameController,
      _descriptionController,
      _quantityController,
      _minQuantityController,
      _unitController,
      _serialController,
      _barcodeController,
      _priceController,
    ]) {
      c.addListener(_markDirty);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _minQuantityController.dispose();
    _unitController.dispose();
    _serialController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _openPhotoModal(bool isReceipt) {
    showAddPhotoModal(
      context,
      isReceipt: isReceipt,
      onCamera: () => _captureFromCamera(isReceipt),
      onGallery: () => _pickFromGallery(isReceipt),
      onPhotoAdded: (url) => _update(() => (isReceipt ? _receiptPhotos : _photos).add(url)),
    );
  }

  void _openCategoryPicker(InventoryProvider provider) {
    showCategoryPickerSheet(
      context,
      provider,
      selected: _selectedCategory,
      onSelected: (cat) => _update(() => _selectedCategory = cat),
      onAddNew: () async {
        final created = await showAddCategoryDialog(context, provider);
        if (created != null && mounted) {
          _update(() => _selectedCategory = created);
          AppFeedback.showSuccess(context, context.l10n.categoryCreated(created));
        }
      },
    );
  }

  Future<void> _saveItem() async {
    if (_isLoading) return;
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      final isEditing = widget.existingItem != null;
      var ok = false;
      final itemName = _nameController.text.trim();
      final qty = double.tryParse(_quantityController.text.trim()) ?? 1.0;
      final price = double.tryParse(_priceController.text.trim());
      final minQty = _minQuantityController.text.trim().isNotEmpty
          ? double.tryParse(_minQuantityController.text.trim())
          : null;

      if (isEditing) {
        final updatedItem = widget.existingItem!.copyWith(
          name: itemName,
          description: _descriptionController.text.trim(),
          boxId: _currentBoxId,
          categoryId: _selectedCategory,
          quantity: qty,
          unit: _unitController.text.trim().isEmpty ? 'pcs' : _unitController.text.trim(),
          minQuantity: minQty,
          clearMinQuantity: minQty == null,
          serialNumber: _serialController.text.trim().isEmpty ? null : _serialController.text.trim(),
          barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
          purchasePrice: price,
          purchaseDate: _purchaseDate,
          warrantyExpiryDate: _warrantyExpiryDate,
          expiryDate: _expiryDate,
          status: _selectedStatus,
          isConsumable: _isConsumable,
          photos: _photos,
          receiptPhotos: _receiptPhotos,
          customAttributes: Map<String, dynamic>.from(_customAttributes),
        );
        ok = await provider.updateItem(updatedItem);
      } else {
        final newItem = Item(
          name: itemName,
          description: _descriptionController.text.trim(),
          boxId: _currentBoxId,
          categoryId: _selectedCategory,
          quantity: qty,
          unit: _unitController.text.trim().isEmpty ? 'pcs' : _unitController.text.trim(),
          minQuantity: minQty,
          serialNumber: _serialController.text.trim().isEmpty ? null : _serialController.text.trim(),
          barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
          purchasePrice: price,
          purchaseDate: _purchaseDate,
          warrantyExpiryDate: _warrantyExpiryDate,
          expiryDate: _expiryDate,
          status: _selectedStatus,
          isConsumable: _isConsumable,
          photos: _photos,
          receiptPhotos: _receiptPhotos,
          customAttributes: Map<String, dynamic>.from(_customAttributes),
        );
        ok = await provider.addItem(newItem);
      }

      if (!mounted) return;
      if (ok) {
        Navigator.pop(context);
        AppFeedback.showSuccess(
          context,
          isEditing ? context.l10n.itemUpdatedSuccessfully(itemName) : context.l10n.itemAddedSuccessfully(itemName),
        );
      } else {
        // The provider already undid the change; stay on the form so nothing typed is lost.
        setState(() => _isLoading = false);
        AppFeedback.showError(context, context.l10n.somethingWentWrongPleaseTry);
      }
    } else {
      AppFeedback.showError(context, context.l10n.pleaseFixTheHighlightedFields);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;
    final provider = Provider.of<InventoryProvider>(context);
    final currentBox = provider.getBoxById(_currentBoxId);
    final breadcrumb = provider.getBreadcrumbString(_currentBoxId);

    return PopScope(
      canPop: !_dirty || _isLoading,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await AppFeedback.showConfirmDialog(
          context,
          title: context.l10n.discardChangesTitle,
          message: context.l10n.discardChangesMessage,
          confirmLabel: context.l10n.commonDiscard,
          isDestructive: true,
        );
        if (leave && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
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
                size: 16,
                color: context.colors.textPrimary,
              ),
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        title: Text(
          isEditing ? context.l10n.editItem : context.l10n.newItem,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: IconButton(
 tooltip: context.l10n.commonDelete,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const AppIcon(Icons.delete_outline, size: 20, color: AppTones.coral),
                ),
                onPressed: () async {
                  final name = widget.existingItem!.name;
                  final itemId = widget.existingItem!.id;
                  final confirmed = await TrashActions.confirm(context, name: name);
                  if (confirmed && context.mounted) {
                    final ok = await provider.deleteItem(itemId);
                    if (!context.mounted) return;
                    if (ok) {
                      Navigator.pop(context);
                      TrashActions.showMoved(context, provider, name: name, itemId: itemId);
                    } else {
                      AppFeedback.showError(context, context.l10n.couldNotDeletePleaseTry2(name));
                    }
                  }
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: FilledButton(
              onPressed: _isLoading ? null : _saveItem,
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isEditing ? context.l10n.commonSave : context.l10n.commonCreate,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            // The name and the few fields everyone fills in come first.
            ..._basicInfoSection(provider, currentBox, breadcrumb),

            _buildSectionTitle(context.l10n.productPhotos),
            const SizedBox(height: 12),
            _buildPhotosGallery(false),
            const SizedBox(height: 24),

            // Everything else is optional: collapsed for a new item, open when editing.
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: isEditing,
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text(
                  context.l10n.moreDetails,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
                children: [
                  const SizedBox(height: 8),
                  ..._statusSection(provider, currentBox, breadcrumb),

                  ..._assetDetailsSection(provider, currentBox, breadcrumb),

                  ..._specificationsSection(provider, currentBox, breadcrumb),

                  // Receipts & Invoices
                  _buildSectionTitle(context.l10n.receiptsWarrantyProof),
                  const SizedBox(height: 12),
                  _buildPhotosGallery(true),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isLoading ? null : _saveItem,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isEditing ? context.l10n.saveChanges : context.l10n.saveItem,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    ),
  );
}
}
