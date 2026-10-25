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
      _buildSectionTitle(context.l10n.basicInformation),
      const SizedBox(height: 12),

      AppFormField(
        label: context.l10n.itemName,
        hintText: context.l10n.eGMacbookProFirst,
        controller: _nameController,
        validator: (value) => value == null || value.trim().isEmpty
            ? context.l10n.pleaseEnterItemName
            : null,
      ),
      const SizedBox(height: 16),

      // Category Section with Bottom Sheet Picker
      Text(
        context.l10n.commonCategory,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      Tappable(
        onTap: () => _openCategoryPicker(provider),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.colors.fill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  CategoryHelper.getCategoryIcon(_selectedCategory),
                  size: 20,
                  color: context.colors.textPrimary,
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
                          : context.l10n.selectCategory,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _selectedCategory.isNotEmpty
                            ? context.colors.textPrimary
                            : context.colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.tapToChangeCategory,
                      style: TextStyle(
                        color: context.colors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: context.colors.textSecondary,
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
              label: context.l10n.commonQuantity,
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
              label: context.l10n.commonUnit,
              hintText: provider.defaultUnit.isNotEmpty
                  ? provider.defaultUnit
                  : 'pcs',
              controller: _unitController,
              suffixIcon: PopupMenuButton<String>(
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: context.colors.textSecondary,
                ),
                tooltip: context.l10n.selectUnit,
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
        label: context.l10n.lowStockAlertThresholdOptional,
        hintText: context.l10n.eG2AlertWhen,
        controller: _minQuantityController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: 16),

      // Storage Location Selector
      Text(
        context.l10n.storageLocation,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      Tappable(
        onTap: _pickStorageLocation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.fill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  currentBox?.type.icon ?? Icons.location_on_outlined,
                  color: context.colors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentBox?.name ?? context.l10n.selectStorageContainer,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.route_outlined,
                          size: 12,
                          color: context.colors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            breadcrumb.isNotEmpty ? breadcrumb : context.l10n.commonUnassigned,
                            style: TextStyle(
                              color: context.colors.textSecondary,
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
                decoration: BoxDecoration(
                  color: context.colors.fill,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: context.colors.textPrimary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),

      AppFormField(
        label: context.l10n.commonDescription,
        hintText: context.l10n.colorConditionAccessoriesOptional,
        controller: _descriptionController,
        maxLines: 2,
      ),
      const SizedBox(height: 16),

      // Consumable Item Option Card
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.colors.border, width: 1),
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
                    ? context.colors.primary
                    : context.colors.fill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.shopping_basket_outlined,
                color: _isConsumable ? Colors.white : context.colors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.consumableItem,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.consumableItemsBatteriesMasksFood,
                    style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _isConsumable,
              activeTrackColor: context.colors.primary,
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
      _buildSectionTitle(context.l10n.assetStatus),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ItemStatus.values.map((status) {
            final isSelected = _selectedStatus == status;
            return Tappable(
              onTap: () => _update(() => _selectedStatus = status),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? context.colors.primary : context.colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.border,
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
                            : context.colors.textPrimary,
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
      _buildSectionTitle(context.l10n.assetWarrantyDetails),
      const SizedBox(height: 12),

      Row(
        children: [
          Expanded(
            child: AppFormField(
              label: context.l10n.purchasePrice(provider.currency),
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
              label: context.l10n.serialNumber,
              hintText: 'SN-XXXX-XXXX',
              controller: _serialController,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      // Barcode (UPC/EAN)
      AppFormField(
        label: context.l10n.productBarcodeUpcEan,
        hintText: context.l10n.scanOrEnterProductBarcode,
        controller: _barcodeController,
      ),
      const SizedBox(height: 16),

      // Dates: Warranty & Expiry
      Row(
        children: [
          Expanded(
            child: _buildDatePickerTile(
              label: context.l10n.warrantyExpiry,
              date: _warrantyExpiryDate,
              onSelected: (d) => _update(() => _warrantyExpiryDate = d),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDatePickerTile(
              label: context.l10n.perishableExpiry,
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
            isReceipt ? context.l10n.receiptCaptured : context.l10n.photoCaptured,
          );
        }
      }
    } catch (e) {
      debugPrint('item_create_sections.dart error: $e');
      if (mounted) {
        AppFeedback.showError(context, context.l10n.cameraIsnTAvailableCheck);
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
            isReceipt ? context.l10n.receiptSelected : context.l10n.photoSelected,
          );
        }
      }
    } catch (e) {
      debugPrint('item_create_sections.dart error: $e');
      if (mounted) {
        AppFeedback.showError(context, context.l10n.couldnTOpenYourPhotos);
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
          Tappable(
            onTap: () => _openPhotoModal(isReceipt),
            child: Container(
              width: 90,
              decoration: BoxDecoration(
                color: context.colors.fill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colors.border,
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
                    color: context.colors.textPrimary,
                    size: 26,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isReceipt ? '+ Receipt' : '+ Photo',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
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
                          color: context.colors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          context.l10n.commonCover,
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
                    child: Tappable(
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
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: context.colors.textPrimary,
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
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Tappable(
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
              color: context.colors.fill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    date != null ? dateFormat.format(date) : context.l10n.notSet,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: date != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: date != null
                          ? context.colors.textPrimary
                          : context.colors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (date != null)
                  Tappable(
                    onTap: () => onSelected(null),
                    child: Icon(
                      Icons.clear,
                      size: 16,
                      color: context.colors.textSecondary,
                    ),
                  )
                else
                  Icon(
                    Icons.event_outlined,
                    size: 16,
                    color: context.colors.textSecondary,
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
      title: context.l10n.selectStorageLocation,
      subtitle: context.l10n.chooseContainerOrScanQr,
      confirmButtonText: context.l10n.setLocation,
    );
    if (!mounted || selectedBox == null) return;
    _update(() {
      _currentBoxId = selectedBox.id;
    });
  }
}
