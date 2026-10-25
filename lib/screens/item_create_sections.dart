part of 'item_create_screen.dart';

/// Form sections and helpers of the item editor.
extension _ItemCreateSections on _ItemCreateScreenState {
  List<Widget> _basicInfoSection(
    InventoryProvider provider,
    Box? currentBox,
    String breadcrumb,
  ) {
    return [
      // Section 2: Basic Info
      _buildSectionTitle('Basic Information'),
      const SizedBox(height: 12),

      AppFormField(
        label: 'Item Name',
        hintText: 'e.g. MacBook Pro, First Aid Kit, USB Cable',
        controller: _nameController,
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Please enter item name'
            : null,
      ),
      const SizedBox(height: 16),

      // Category Section with Bottom Sheet Picker
      const Text(
        'Category',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF18181B),
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () => _openCategoryPicker(provider),
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
                      _selectedCategory.isNotEmpty
                          ? _selectedCategory
                          : 'Select Category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _selectedCategory.isNotEmpty
                            ? const Color(0xFF18181B)
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to change category',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF71717A),
                size: 22,
              ),
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: AppFormField(
              label: 'Unit',
              hintText: provider.defaultUnit.isNotEmpty
                  ? provider.defaultUnit
                  : 'pcs',
              controller: _unitController,
              suffixIcon: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Color(0xFF71717A),
                ),
                tooltip: 'Select Unit',
                onSelected: (val) {
                  _update(() {
                    _unitController.text = val;
                  });
                },
                itemBuilder: (context) {
                  final commonUnits = _getCommonUnits(provider.defaultUnit);
                  return commonUnits.map((u) {
                    return PopupMenuItem<String>(
                      value: u,
                      child: Text(
                        u,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
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
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF18181B),
        ),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.route_outlined,
                          size: 12,
                          color: Color(0xFF71717A),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            breadcrumb.isNotEmpty ? breadcrumb : 'Unassigned',
                            style: const TextStyle(
                              color: Color(0xFF71717A),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
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
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF18181B),
                  size: 18,
                ),
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
          border: Border.all(color: Colors.grey.shade200, width: 1),
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
                color: _isConsumable
                    ? const Color(0xFF18181B)
                    : const Color(0xFFF4F4F6),
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
              onChanged: (val) => _update(() => _isConsumable = val),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _statusSection(
    InventoryProvider provider,
    Box? currentBox,
    String breadcrumb,
  ) {
    return [
      // Section 3: Asset Status
      _buildSectionTitle('Asset Status'),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ItemStatus.values.map((status) {
            final isSelected = _selectedStatus == status;
            return GestureDetector(
              onTap: () => _update(() => _selectedStatus = status),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF18181B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF18181B)
                        : Colors.grey.shade300,
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
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF18181B),
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
    ];
  }

  List<Widget> _assetDetailsSection(
    InventoryProvider provider,
    Box? currentBox,
    String breadcrumb,
  ) {
    return [
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
              onSelected: (d) => _update(() => _warrantyExpiryDate = d),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDatePickerTile(
              label: 'Perishable Expiry',
              date: _expiryDate,
              onSelected: (d) => _update(() => _expiryDate = d),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _specificationsSection(
    InventoryProvider provider,
    Box? currentBox,
    String breadcrumb,
  ) {
    return [
      // Section 5: Specifications & Attributes
      buildCustomAttributesSection(
        context,
        attributes: _customAttributes,
        onSave: (key, value, replacedKey) => _update(() {
          if (replacedKey != null) _customAttributes.remove(replacedKey);
          _customAttributes[key] = value;
        }),
        onRemove: (key) => _update(() => _customAttributes.remove(key)),
      ),
      const SizedBox(height: 24),
    ];
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

        _update(() {
          if (isReceipt) {
            _receiptPhotos.add(photoUrl);
          } else {
            _photos.add(photoUrl);
          }
        });
        if (mounted) {
          AppFeedback.showSuccess(
            context,
            isReceipt ? 'Receipt captured' : 'Photo captured',
          );
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

        _update(() {
          if (isReceipt) {
            _receiptPhotos.add(photoUrl);
          } else {
            _photos.add(photoUrl);
          }
        });
        if (mounted) {
          AppFeedback.showSuccess(
            context,
            isReceipt ? 'Receipt selected' : 'Photo selected',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Gallery unavailable: $e');
      }
    }
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
            onTap: () => _openPhotoModal(isReceipt),
            child: Container(
              width: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isReceipt
                        ? Icons.receipt_long_outlined
                        : Icons.add_a_photo_outlined,
                    color: const Color(0xFF18181B),
                    size: 26,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isReceipt ? '+ Receipt' : '+ Photo',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF18181B),
                    ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF18181B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Cover',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Delete button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        _update(() {
                          list.removeAt(idx);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 12,
                          color: Colors.white,
                        ),
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF18181B),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  date ?? DateTime.now().add(const Duration(days: 365)),
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
                      fontWeight: date != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: date != null
                          ? const Color(0xFF18181B)
                          : Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (date != null)
                  GestureDetector(
                    onTap: () => onSelected(null),
                    child: const Icon(
                      Icons.clear,
                      size: 16,
                      color: Colors.grey,
                    ),
                  )
                else
                  const Icon(
                    Icons.event_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
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
    _update(() {
      _currentBoxId = selectedBox.id;
    });
  }
}
