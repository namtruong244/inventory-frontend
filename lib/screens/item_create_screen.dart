import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_form_field.dart';
import '../widgets/app_image_view.dart';
import '../widgets/location_picker_sheet.dart';

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

  String _selectedCategory = 'Electronics';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedUnit && widget.existingItem == null) {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      if (provider.defaultUnit.trim().isNotEmpty) {
        _unitController.text = provider.defaultUnit.trim();
      }
      _initializedUnit = true;
    }
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

  Future<void> _captureFromCamera(bool isReceipt) async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        final provider = Provider.of<InventoryProvider>(context, listen: false);
        String photoUrl = photo.path;
        if (provider.isConnected) {
          final uploaded = await provider.uploadMedia(
            photo.path,
            folder: isReceipt ? 'receipts' : 'items',
          );
          if (uploaded != null) {
            photoUrl = uploaded;
          }
        }

        setState(() {
          if (isReceipt) {
            _receiptPhotos.add(photoUrl);
          } else {
            _photos.add(photoUrl);
          }
        });
        if (mounted) {
          AppFeedback.showSuccess(context, isReceipt ? 'Receipt captured' : 'Photo captured');
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Camera unavailable: $e');
      }
    }
  }

  Future<void> _pickFromGallery(bool isReceipt) async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        final provider = Provider.of<InventoryProvider>(context, listen: false);
        String photoUrl = photo.path;
        if (provider.isConnected) {
          final uploaded = await provider.uploadMedia(
            photo.path,
            folder: isReceipt ? 'receipts' : 'items',
          );
          if (uploaded != null) {
            photoUrl = uploaded;
          }
        }

        setState(() {
          if (isReceipt) {
            _receiptPhotos.add(photoUrl);
          } else {
            _photos.add(photoUrl);
          }
        });
        if (mounted) {
          AppFeedback.showSuccess(context, isReceipt ? 'Receipt selected' : 'Photo selected');
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Gallery unavailable: $e');
      }
    }
  }

  void _showAddPhotoModal(bool isReceipt) {
    final urlController = TextEditingController();

    // Sample presets for quick testing
    final presets = isReceipt
        ? [
            {
              'title': 'Paper Receipt',
              'url': 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&auto=format&fit=crop&q=80',
            },
            {
              'title': 'Store Invoice',
              'url': 'https://images.unsplash.com/photo-1450133064473-71024230f91b?w=800&auto=format&fit=crop&q=80',
            },
            {
              'title': 'Warranty Card',
              'url': 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800&auto=format&fit=crop&q=80',
            },
          ]
        : [
            {
              'title': 'Laptop',
              'url': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&auto=format&fit=crop&q=80',
            },
            {
              'title': 'Gamepad',
              'url': 'https://images.unsplash.com/photo-1600080972464-8e5f35f63d08?w=800&auto=format&fit=crop&q=80',
            },
            {
              'title': 'Charger',
              'url': 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=800&auto=format&fit=crop&q=80',
            },
            {
              'title': 'Jacket',
              'url': 'https://images.unsplash.com/photo-1544923246-77307dd654cb?w=800&auto=format&fit=crop&q=80',
            },
            {
              'title': 'Medicine',
              'url': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&auto=format&fit=crop&q=80',
            },
            {
              'title': 'Batteries',
              'url': 'https://images.unsplash.com/photo-1619725002198-6a689b72f41d?w=800&auto=format&fit=crop&q=80',
            },
          ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isReceipt ? 'Add Receipt Photo' : 'Add Product Photo',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Camera and Gallery Action Buttons
              Row(
                children: [
                  // Camera Button
                  Expanded(
                    child: Material(
                      color: const Color(0xFF18181B),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pop(ctx);
                          _captureFromCamera(isReceipt);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Column(
                            children: const [
                              Icon(Icons.camera_alt_rounded, color: Colors.white, size: 26),
                              SizedBox(height: 6),
                              Text(
                                'Camera',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Gallery Button
                  Expanded(
                    child: Material(
                      color: const Color(0xFFF4F4F6),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickFromGallery(isReceipt);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Column(
                            children: const [
                              Icon(Icons.photo_library_rounded, color: Color(0xFF18181B), size: 26),
                              SizedBox(height: 6),
                              Text(
                                'Gallery',
                                style: TextStyle(
                                  color: Color(0xFF18181B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR VIA URL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                ],
              ),
              const SizedBox(height: 14),

              // Image URL input
              AppFormField(
                label: 'Image URL',
                hintText: 'https://example.com/image.jpg',
                controller: urlController,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF18181B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final text = urlController.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        if (isReceipt) {
                          _receiptPhotos.add(text);
                        } else {
                          _photos.add(text);
                        }
                      });
                      Navigator.pop(ctx);
                      AppFeedback.showSuccess(context, 'Photo added');
                    }
                  },
                  child: const Text('Add via URL'),
                ),
              ),
              const SizedBox(height: 20),

              // Quick preset photos
              const Text(
                'Or choose sample photo',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: presets.length,
                  itemBuilder: (context, idx) {
                    final p = presets[idx];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isReceipt) {
                            _receiptPhotos.add(p['url']!);
                          } else {
                            _photos.add(p['url']!);
                          }
                        });
                        Navigator.pop(ctx);
                        AppFeedback.showSuccess(context, 'Sample photo selected');
                      },
                      child: Container(
                        width: 76,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(p['url']!, fit: BoxFit.cover),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  color: Colors.black.withValues(alpha: 0.6),
                                  child: Text(
                                    p['title']!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(InventoryProvider provider) async {
    final textController = TextEditingController();
    String? errorText;

    final newCategory = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (dialogCtx, setSheetState) {
            final categoryName = textController.text.trim();
            final previewIcon = CategoryHelper.getCategoryIcon(categoryName.isEmpty ? 'General' : categoryName);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(previewIcon, color: const Color(0xFF18181B), size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New Category',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF18181B),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Create a custom category for your assets',
                                style: TextStyle(fontSize: 12, color: Color(0xFF71717A)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppFormField(
                      label: 'Category Name',
                      hintText: 'e.g. Photography, Watches, Board Games',
                      controller: textController,
                      onChanged: (_) {
                        setSheetState(() {
                          errorText = null;
                        });
                      },
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        errorText!,
                        style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF18181B),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: () {
                              final name = textController.text.trim();
                              if (name.isEmpty) {
                                setSheetState(() {
                                  errorText = 'Please enter a category name';
                                });
                                return;
                              }
                              if (provider.categories.any((c) => c.toLowerCase() == name.toLowerCase())) {
                                setSheetState(() {
                                  errorText = 'Category already exists';
                                });
                                return;
                              }
                              provider.addCategory(name);
                              Navigator.pop(sheetContext, name);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF18181B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Add & Select', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (newCategory != null && mounted) {
      setState(() {
        _selectedCategory = newCategory;
      });
      AppFeedback.showSuccess(context, 'Category "$newCategory" created');
    }
  }

  void _showCategoryPickerSheet(InventoryProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4E4E7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Category',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showAddCategoryDialog(provider);
                          },
                          icon: const Icon(Icons.add, size: 16, color: Color(0xFF18181B)),
                          label: const Text(
                            'New Category',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF18181B), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: provider.categories.length,
                        separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF4F4F6)),
                        itemBuilder: (context, idx) {
                          final cat = provider.categories[idx];
                          final isSelected = _selectedCategory == cat;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                CategoryHelper.getCategoryIcon(cat),
                                size: 18,
                                color: isSelected ? Colors.white : const Color(0xFF18181B),
                              ),
                            ),
                            title: Text(
                              cat,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 14,
                                color: const Color(0xFF18181B),
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF18181B), size: 20)
                                : null,
                            onTap: () {
                              setState(() => _selectedCategory = cat);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final isEditing = widget.existingItem != null;
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
        Provider.of<InventoryProvider>(context, listen: false).updateItem(updatedItem);
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
        Provider.of<InventoryProvider>(context, listen: false).addItem(newItem);
      }

      Navigator.pop(context);
      AppFeedback.showSuccess(
        context,
        isEditing ? 'Item "$itemName" updated successfully' : 'Item "$itemName" added successfully',
      );
    } else {
      AppFeedback.showError(context, 'Please enter an item name');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;
    final provider = Provider.of<InventoryProvider>(context);
    final currentBox = provider.getBoxById(_currentBoxId);
    final breadcrumb = provider.getBreadcrumbString(_currentBoxId);

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
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF18181B),
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          isEditing ? 'Edit Item' : 'New Item',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF18181B),
          ),
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFDC2626)),
                ),
                onPressed: () async {
                  final confirmed = await AppFeedback.showConfirmDialog(
                    context,
                    title: 'Delete this item',
                    message: 'Are you sure you want to delete item "${widget.existingItem!.name}"?',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                    icon: Icons.delete_outline,
                  );
                  if (confirmed && context.mounted) {
                    final name = widget.existingItem!.name;
                    provider.deleteItem(widget.existingItem!.id);
                    Navigator.pop(context);
                    AppFeedback.showSuccess(context, 'Item "$name" deleted successfully');
                  }
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: FilledButton(
              onPressed: _isLoading ? null : _saveItem,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF18181B),
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
                      isEditing ? 'Save' : 'Create',
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
            // Section 1: Photos & Media
            _buildSectionTitle('Product Photos'),
            const SizedBox(height: 12),
            _buildPhotosGallery(false),
            const SizedBox(height: 24),

            // Section 2: Basic Info
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 12),

            AppFormField(
              label: 'Item Name',
              hintText: 'e.g. MacBook Pro, First Aid Kit, USB Cable',
              controller: _nameController,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Please enter item name' : null,
            ),
            const SizedBox(height: 16),

            // Category Section with Bottom Sheet Picker
            const Text(
              'Category',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF18181B)),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showCategoryPickerSheet(provider),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4E4E7)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CategoryHelper.getCategoryIcon(_selectedCategory),
                        size: 20,
                        color: const Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedCategory.isNotEmpty ? _selectedCategory : 'Select Category',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _selectedCategory.isNotEmpty ? const Color(0xFF18181B) : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap to change category',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF71717A), size: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity & Unit Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AppFormField(
                    label: 'Quantity',
                    hintText: '1',
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: AppFormField(
                    label: 'Unit',
                    hintText: provider.defaultUnit.isNotEmpty ? provider.defaultUnit : 'pcs',
                    controller: _unitController,
                    suffixIcon: PopupMenuButton<String>(
                      icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF71717A)),
                      tooltip: 'Select Unit',
                      onSelected: (val) {
                        setState(() {
                          _unitController.text = val;
                        });
                      },
                      itemBuilder: (context) {
                        final commonUnits = _getCommonUnits(provider.defaultUnit);
                        return commonUnits.map((u) {
                          return PopupMenuItem<String>(
                            value: u,
                            child: Text(u, style: const TextStyle(fontWeight: FontWeight.w500)),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Low Stock Threshold per item
            AppFormField(
              label: 'Low Stock Alert Threshold (Optional)',
              hintText: 'e.g. 2 (Alert when quantity ≤ this number)',
              controller: _minQuantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // Storage Location Selector
            const Text(
              'Storage Location',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF18181B)),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickStorageLocation,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4E4E7)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        currentBox?.type.icon ?? Icons.location_on_outlined,
                        color: const Color(0xFF18181B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentBox?.name ?? 'Select Storage Container',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF18181B)),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.route_outlined, size: 12, color: Color(0xFF71717A)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  breadcrumb.isNotEmpty ? breadcrumb : 'Unassigned',
                                  style: const TextStyle(color: Color(0xFF71717A), fontSize: 12, fontWeight: FontWeight.w500),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F4F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF18181B), size: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            AppFormField(
              label: 'Description',
              hintText: 'Color, condition, accessories (Optional)',
              controller: _descriptionController,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Consumable Item Option Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isConsumable ? const Color(0xFF18181B) : const Color(0xFFF4F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shopping_basket_outlined,
                      color: _isConsumable ? Colors.white : const Color(0xFF71717A),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Consumable Item',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Consumable items (batteries, masks, food, medicine...)',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isConsumable,
                    activeTrackColor: const Color(0xFF18181B),
                    activeThumbColor: Colors.white,
                    onChanged: (val) => setState(() => _isConsumable = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Asset Status
            _buildSectionTitle('Asset Status'),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ItemStatus.values.map((status) {
                  final isSelected = _selectedStatus == status;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedStatus = status),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF18181B) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF18181B) : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            status.icon,
                            size: 16,
                            color: isSelected ? Colors.white : status.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status.displayName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF18181B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Section 4: Asset, Price & Serial
            _buildSectionTitle('Asset & Warranty Details'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: AppFormField(
                    label: 'Purchase Price (${provider.currency})',
                    hintText: '0.00',
                    prefixText: '${provider.currency} ',
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppFormField(
                    label: 'Serial Number',
                    hintText: 'SN-XXXX-XXXX',
                    controller: _serialController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barcode (UPC/EAN)
            AppFormField(
              label: 'Product Barcode (UPC / EAN)',
              hintText: 'Scan or enter product barcode',
              controller: _barcodeController,
            ),
            const SizedBox(height: 16),

            // Dates: Warranty & Expiry
            Row(
              children: [
                Expanded(
                  child: _buildDatePickerTile(
                    label: 'Warranty Expiry',
                    date: _warrantyExpiryDate,
                    onSelected: (d) => setState(() => _warrantyExpiryDate = d),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDatePickerTile(
                    label: 'Perishable Expiry',
                    date: _expiryDate,
                    onSelected: (d) => setState(() => _expiryDate = d),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section 5: Specifications & Attributes
            _buildCustomAttributesSection(),
            const SizedBox(height: 24),

            // Section 6: Receipts & Invoices
            _buildSectionTitle('Receipts & Warranty Proof'),
            const SizedBox(height: 12),
            _buildPhotosGallery(true),
            const SizedBox(height: 36),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _saveItem,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF18181B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Save Item',
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
  );
}

  Widget _buildPhotosGallery(bool isReceipt) {
    final list = isReceipt ? _receiptPhotos : _photos;

    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Add Photo button card
          GestureDetector(
            onTap: () => _showAddPhotoModal(isReceipt),
            child: Container(
              width: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isReceipt ? Icons.receipt_long_outlined : Icons.add_a_photo_outlined,
                    color: const Color(0xFF18181B),
                    size: 26,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isReceipt ? '+ Receipt' : '+ Photo',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Thumbnails
          ...list.asMap().entries.map((entry) {
            final idx = entry.key;
            final url = entry.value;

            return Container(
              width: 90,
              margin: const EdgeInsets.only(right: 12),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AppImageView(
                      imageUrlOrPath: url,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  // Cover badge on first product photo
                  if (!isReceipt && idx == 0)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF18181B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Cover', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  // Delete button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          list.removeAt(idx);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF18181B),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildDatePickerTile({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime?> onSelected,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF18181B)),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now().add(const Duration(days: 365)),
              firstDate: DateTime(2000),
              lastDate: DateTime(2050),
            );
            if (picked != null) onSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    date != null ? dateFormat.format(date) : 'Not set',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: date != null ? FontWeight.bold : FontWeight.normal,
                      color: date != null ? const Color(0xFF18181B) : Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (date != null)
                  GestureDetector(
                    onTap: () => onSelected(null),
                    child: const Icon(Icons.clear, size: 16, color: Colors.grey),
                  )
                else
                  const Icon(Icons.event_outlined, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickStorageLocation() async {
    final selectedBox = await LocationPickerSheet.show(
      context,
      initialBoxId: _currentBoxId,
      title: 'Select Storage Location',
      subtitle: 'Choose container or scan QR to assign',
      confirmButtonText: 'Set Location',
    );
    if (!mounted || selectedBox == null) return;
    setState(() {
      _currentBoxId = selectedBox.id;
    });
  }

  Widget _buildCustomAttributesSection() {
    final suggestedAttributes = [
      'Color',
      'Size',
      'Brand',
      'Model',
      'Material',
      'Weight',
      'RAM',
      'Storage',
      'Dimensions',
      'Voltage',
    ].where((attr) => !_customAttributes.containsKey(attr)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: _buildSectionTitle('Specifications & Attributes'),
                  ),
                  if (_customAttributes.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_customAttributes.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddEditAttributeSheet(),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Attribute'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Quick suggestions chips
        if (suggestedAttributes.isNotEmpty) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: suggestedAttributes.take(6).map((attr) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: const Color(0xFFF4F4F6),
                    side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    avatar: const Icon(Icons.add, size: 14, color: Color(0xFF71717A)),
                    label: Text(
                      attr,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3F3F46),
                      ),
                    ),
                    onPressed: () => _showAddEditAttributeSheet(initialKey: attr),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Attributes List or Empty State
        if (_customAttributes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4E4E7)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: Color(0xFFA1A1AA),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No specifications added yet',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3F3F46),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add custom attributes like Color, Size, RAM, or Brand',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF71717A),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _showAddEditAttributeSheet(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Specification'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF18181B),
                    side: const BorderSide(color: Color(0xFFD4D4D8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4E4E7)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _customAttributes.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: Color(0xFFF4F4F6),
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final entry = _customAttributes.entries.elementAt(index);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  dense: true,
                  title: Text(
                    entry.key.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  subtitle: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF18181B),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF71717A)),
                        tooltip: 'Edit',
                        onPressed: () => _showAddEditAttributeSheet(
                          existingKey: entry.key,
                          existingValue: entry.value,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFFEF4444)),
                        tooltip: 'Remove',
                        onPressed: () {
                          setState(() {
                            _customAttributes.remove(entry.key);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showAddEditAttributeSheet({
    String? existingKey,
    String? existingValue,
    String? initialKey,
  }) {
    final keyController = TextEditingController(text: existingKey ?? initialKey ?? '');
    final valueController = TextEditingController(text: existingValue ?? '');
    final isEditing = existingKey != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E4E7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      isEditing ? 'Edit Specification' : 'Add Specification',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF18181B),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: 'Attribute Name',
                  hintText: 'e.g. Color, RAM, Size, Material, Weight',
                  controller: keyController,
                ),
                const SizedBox(height: 14),
                AppFormField(
                  label: 'Attribute Value',
                  hintText: 'e.g. Space Black, 16GB, XL, Leather',
                  controller: valueController,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      final k = keyController.text.trim();
                      final v = valueController.text.trim();
                      if (k.isEmpty) {
                        AppFeedback.showError(ctx, 'Please enter an attribute name');
                        return;
                      }
                      if (v.isEmpty) {
                        AppFeedback.showError(ctx, 'Please enter an attribute value');
                        return;
                      }
                      setState(() {
                        if (isEditing && existingKey != k) {
                          _customAttributes.remove(existingKey);
                        }
                        _customAttributes[k] = v;
                      });
                      Navigator.pop(ctx);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF18181B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Save Specification' : 'Add Specification',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
