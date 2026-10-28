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
            boxShadow: context.colors.cardShadow,
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
                child: AppIcon(
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
              AppIcon(
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
              validator: (v) => _isValidAmount(v)
                  ? null
                  : context.l10n.pleaseEnterAValidQuantity,
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
                icon: AppIcon(
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
        validator: (v) => _isValidAmount(v)
            ? null
            : context.l10n.pleaseEnterAValidQuantity,
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
            boxShadow: context.colors.cardShadow,
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
                child: AppIcon(
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
                        AppIcon(
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
                child: AppIcon(
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
          boxShadow: context.colors.cardShadow,
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
              child: AppIcon(
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
                  color: isSelected ? context.colors.accent : context.colors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    AppIcon(
                      status.icon,
                      size: 16,
                      color: isSelected ? context.colors.onAccent : status.color,
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
                            ? context.colors.onAccent
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
        suffixIcon: IconButton(
          tooltip: context.l10n.scanBarcode,
          icon: const AppIcon(Icons.qr_code_scanner_rounded),
          onPressed: () async {
            final code = await showBarcodeScanSheet(context);
            if (code != null) _update(() => _barcodeController.text = code);
          },
        ),
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

  Future<void> _captureFromCamera(bool isReceipt) =>
      _addPhoto(ImageSource.camera, isReceipt);

  Future<void> _pickFromGallery(bool isReceipt) =>
      _addPhoto(ImageSource.gallery, isReceipt);

  /// Uploads the picked image and stores the server URL. A local file path is never
  /// saved on the item: no other device (or reinstall) could open it. Offline or on a
  /// failed upload the user is told so and can try again.
  Future<void> _addPhoto(ImageSource source, bool isReceipt) async {
    final XFile? photo;
    try {
      photo = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('item_create_sections.dart error: $e');
      if (mounted) {
        AppFeedback.showError(
          context,
          source == ImageSource.camera
              ? context.l10n.cameraIsnTAvailableCheck
              : context.l10n.couldnTOpenYourPhotos,
        );
      }
      return;
    }
    if (photo == null || !mounted) return;

    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final uploaded = provider.isConnected
        ? await provider.uploadMedia(
            photo.path,
            folder: isReceipt ? 'receipts' : 'items',
          )
        : null;
    if (!mounted) return;
    if (uploaded == null) {
      AppFeedback.showError(context, context.l10n.couldnTUploadThePhoto);
      return;
    }

    _update(() => (isReceipt ? _receiptPhotos : _photos).add(uploaded));
    AppFeedback.showSuccess(
      context,
      source == ImageSource.camera
          ? (isReceipt ? context.l10n.receiptCaptured : context.l10n.photoCaptured)
          : (isReceipt ? context.l10n.receiptSelected : context.l10n.photoSelected),
    );
  }

  /// Empty means "use the default"; otherwise a number that is 0 or more.
  bool _isValidAmount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return true;
    final n = double.tryParse(text);
    return n != null && n >= 0;
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
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(
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
                      semanticLabel: MaterialLocalizations.of(context).deleteButtonTooltip,
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
                        child: const AppIcon(
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
                    date != null ? formatDate(context, date) : context.l10n.notSet,
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
                    semanticLabel: MaterialLocalizations.of(context).clearButtonTooltip,
                    onTap: () => onSelected(null),
                    child: AppIcon(
                      Icons.clear,
                      size: 16,
                      color: context.colors.textSecondary,
                    ),
                  )
                else
                  AppIcon(
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
