part of 'item_create_screen.dart';

/// Form sections and helpers of the item editor.
extension _ItemCreateSections on _ItemCreateScreenState {
  BoxDecoration _cardDeco() => BoxDecoration(
    color: context.colors.surface,
    borderRadius: BorderRadius.circular(24),
    boxShadow: context.colors.cardShadow,
  );

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.colors.textSecondary,
      ),
    ),
  );

  Widget _pillButton(String id, IconData icon, String label, VoidCallback tap) {
    final c = context.colors;
    return e2eId(
      id,
      Tappable(
        semanticLabel: label,
        onTap: tap,
        child: Container(
          height: 29,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: c.fill,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(icon, size: 14, color: c.textPrimary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverCard() {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Row(
        children: [
          e2eId(
            'item_photo_add',
            Tappable(
              semanticLabel: context.l10n.photoSheetTitle,
              onTap: () => _openPhotoModal(false),
              child: SizedBox(
                width: 76,
                height: 76,
                child: _photos.isNotEmpty
                    ? AppImageView(
                        imageUrlOrPath: _photos.first,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(20),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: c.fill,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppIcon(
                          Icons.add_a_photo_outlined,
                          size: 26,
                          color: c.textSecondary,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.itemCoverPhoto,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pillButton(
                      'item_cover_camera',
                      Icons.photo_camera_outlined,
                      context.l10n.commonCamera,
                      () => _captureFromCamera(false),
                    ),
                    _pillButton(
                      'item_cover_gallery',
                      Icons.image_outlined,
                      context.l10n.commonGallery,
                      () => _pickFromGallery(false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, String tip, bool accent, VoidCallback tap) {
    final c = context.colors;
    return Tappable(
      semanticLabel: tip,
      onTap: tap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: accent ? c.accent : c.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AppIcon(
          icon,
          size: 18,
          color: accent ? c.onAccent : c.textPrimary,
        ),
      ),
    );
  }

  void _stepQuantity(double delta) {
    final cur = double.tryParse(_quantityController.text.trim()) ?? 0;
    final next = (cur + delta).clamp(0, 999999).toDouble();
    _update(() {
      _quantityController.text = next % 1 == 0
          ? next.toInt().toString()
          : next.toString();
    });
  }

  Widget _quantityStepper() {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context.l10n.commonQuantity),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: c.fill,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _stepButton(
                Icons.remove_rounded,
                context.l10n.itemQuantityDecrease,
                false,
                () => _stepQuantity(-1),
              ),
              Expanded(
                child: e2eId(
                  'item_quantity',
                  TextFormField(
                    controller: _quantityController,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    validator: (v) => _isValidAmount(v)
                        ? null
                        : context.l10n.pleaseEnterAValidQuantity,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      errorStyle: TextStyle(fontSize: 0, height: 0),
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              _stepButton(
                Icons.add_rounded,
                context.l10n.itemQuantityIncrease,
                true,
                () => _stepQuantity(1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _unitField(InventoryProvider provider) {
    return AppFormField(
      id: 'item_unit',
      label: context.l10n.commonUnit,
      hintText: provider.defaultUnit.isNotEmpty ? provider.defaultUnit : 'pcs',
      controller: _unitController,
      suffixIcon: PopupMenuButton<String>(
        icon: AppIcon(
          Icons.keyboard_arrow_down_rounded,
          color: context.colors.textSecondary,
        ),
        tooltip: context.l10n.selectUnit,
        onSelected: (val) => _update(() => _unitController.text = val),
        itemBuilder: (context) => [
          for (final u in _getCommonUnits(provider.defaultUnit))
            PopupMenuItem<String>(
              value: u,
              child: Text(
                u,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _locationField(Box? currentBox, String breadcrumb) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context.l10n.storageLocation),
        e2eId(
          'item_location',
          Tappable(
            semanticLabel: context.l10n.storageLocation,
            onTap: _pickStorageLocation,
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: c.fill,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  AppIcon(
                    currentBox?.type.icon ?? Icons.location_on_outlined,
                    size: 18,
                    color: AppTones.sky,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      breadcrumb.isNotEmpty
                          ? breadcrumb
                          : context.l10n.selectStorageContainer,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: breadcrumb.isNotEmpty
                            ? c.textPrimary
                            : c.textMuted,
                      ),
                    ),
                  ),
                  AppIcon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: c.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryChip(String label, bool selected, VoidCallback tap) {
    final c = context.colors;
    return e2eId(
      'category_chip_$label',
      Tappable(
        semanticLabel: label,
        onTap: tap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? c.accent : c.fill,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                CategoryHelper.getCategoryIcon(label),
                size: 14,
                color: selected ? c.onAccent : c.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? c.onAccent : c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryRow(InventoryProvider provider) {
    final c = context.colors;
    final cats = <String>[
      if (_selectedCategory.isNotEmpty) _selectedCategory,
      ...provider.categories.where((x) => x != _selectedCategory).take(5),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context.l10n.commonCategory),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final cat in cats) ...[
                _categoryChip(
                  cat,
                  cat == _selectedCategory,
                  () => _update(() => _selectedCategory = cat),
                ),
                const SizedBox(width: 8),
              ],
              e2eId(
                'item_category',
                Tappable(
                  semanticLabel: context.l10n.selectCategory,
                  onTap: () => _openCategoryPicker(provider),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: c.fill,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.l10n.specMore,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _basicsCard(InventoryProvider provider, Box? box, String breadcrumb) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormField(
            id: 'item_name',
            label: context.l10n.itemName,
            hintText: context.l10n.eGMacbookProFirst,
            controller: _nameController,
            validator: (value) => value == null || value.trim().isEmpty
                ? context.l10n.pleaseEnterItemName
                : null,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _quantityStepper()),
              const SizedBox(width: 12),
              Expanded(child: _unitField(provider)),
            ],
          ),
          const SizedBox(height: 16),
          _locationField(box, breadcrumb),
          const SizedBox(height: 16),
          _categoryRow(provider),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDate(DateTime? initial) => showDatePicker(
    context: context,
    initialDate: initial ?? DateTime.now().add(const Duration(days: 365)),
    firstDate: DateTime(2000),
    lastDate: DateTime(2050),
  );

  Widget _toggleRow({
    required String id,
    required IconData icon,
    required Color fg,
    required Color bg,
    required String title,
    required String sub,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? onTap,
  }) {
    final c = context.colors;
    return Tappable(
      semanticLabel: title,
      onTap: onTap ?? () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SoftIconTile(icon, color: fg, background: bg, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            e2eId(id, SoftToggle(value: value, onChanged: onChanged)),
          ],
        ),
      ),
    );
  }

  Widget _trackingCard() {
    final c = context.colors;
    Widget divider() => Divider(height: 1, thickness: 1, color: c.border);
    Future<void> dateToggle(
      bool on,
      DateTime? current,
      ValueChanged<DateTime?> set,
    ) async {
      if (!on) {
        _update(() => set(null));
        return;
      }
      final d = await _pickDate(current);
      if (d != null && mounted) _update(() => set(d));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: _cardDeco(),
      child: Column(
        children: [
          _toggleRow(
            id: 'item_consumable_toggle',
            icon: Icons.shopping_basket_outlined,
            fg: AppTones.matcha,
            bg: AppTones.matchaSoft,
            title: context.l10n.consumableItem,
            sub: context.l10n.itemConsumableHint,
            value: _isConsumable,
            onChanged: (v) => _update(() => _isConsumable = v),
          ),
          divider(),
          _toggleRow(
            id: 'item_perishable_toggle',
            icon: Icons.event_outlined,
            fg: AppTones.amber,
            bg: AppTones.amberSoft,
            title: context.l10n.itemPerishable,
            sub: _expiryDate != null
                ? context.l10n.itemExpiresOn(formatDate(context, _expiryDate!))
                : context.l10n.itemPerishableHint,
            value: _expiryDate != null,
            onChanged: (v) =>
                dateToggle(v, _expiryDate, (d) => _expiryDate = d),
            onTap: () => dateToggle(true, _expiryDate, (d) => _expiryDate = d),
          ),
          divider(),
          _toggleRow(
            id: 'item_warranty_toggle',
            icon: Icons.verified_user_outlined,
            fg: AppTones.sky,
            bg: AppTones.skySoft,
            title: context.l10n.itemWarranty,
            sub: _warrantyExpiryDate != null
                ? context.l10n.itemWarrantyEnds(
                    formatDate(context, _warrantyExpiryDate!),
                  )
                : context.l10n.itemWarrantyHint,
            value: _warrantyExpiryDate != null,
            onChanged: (v) => dateToggle(
              v,
              _warrantyExpiryDate,
              (d) => _warrantyExpiryDate = d,
            ),
            onTap: () => dateToggle(
              true,
              _warrantyExpiryDate,
              (d) => _warrantyExpiryDate = d,
            ),
          ),
        ],
      ),
    );
  }

  Widget _moreDetailsCard(InventoryProvider provider) {
    final c = context.colors;
    return Container(
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          e2eId(
            'item_more_details',
            Tappable(
              semanticLabel: context.l10n.moreDetails,
              onTap: _toggleMore,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.moreDetails,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.l10n.itemMoreDetailsHint,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c.fill,
                        shape: BoxShape.circle,
                      ),
                      child: AppIcon(
                        _moreOpen
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: c.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_moreOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppFormField(
                    id: 'item_description',
                    label: context.l10n.commonDescription,
                    hintText: context.l10n.colorConditionAccessoriesOptional,
                    controller: _descriptionController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  AppFormField(
                    id: 'item_min_quantity',
                    label: context.l10n.lowStockAlertThresholdOptional,
                    hintText: context.l10n.eG2AlertWhen,
                    controller: _minQuantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => _isValidAmount(v)
                        ? null
                        : context.l10n.pleaseEnterAValidQuantity,
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle(context.l10n.assetStatus),
                  _statusChips(),
                  const SizedBox(height: 20),
                  _sectionTitle(context.l10n.assetWarrantyDetails),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppFormField(
                          id: 'item_price',
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
                          id: 'item_serial',
                          label: context.l10n.serialNumber,
                          hintText: 'SN-XXXX',
                          controller: _serialController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppFormField(
                    id: 'item_barcode',
                    label: context.l10n.productBarcodeUpcEan,
                    hintText: context.l10n.scanOrEnterProductBarcode,
                    controller: _barcodeController,
                    suffixIcon: IconButton(
                      tooltip: context.l10n.scanBarcode,
                      icon: const AppIcon(Icons.qr_code_scanner_rounded),
                      onPressed: () async {
                        final code = await showBarcodeScanSheet(context);
                        if (code != null) {
                          _update(() => _barcodeController.text = code);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _datePickerField(
                    label: context.l10n.purchaseDate,
                    date: _purchaseDate,
                    onSelected: (d) => _update(() => _purchaseDate = d),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle(context.l10n.productPhotos),
                  _buildPhotosGallery(false),
                  const SizedBox(height: 20),
                  buildCustomAttributesSection(
                    context,
                    attributes: _customAttributes,
                    onSave: (key, value, replacedKey) => _update(() {
                      if (replacedKey != null) {
                        _customAttributes.remove(replacedKey);
                      }
                      _customAttributes[key] = value;
                    }),
                    onRemove: (key) =>
                        _update(() => _customAttributes.remove(key)),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle(context.l10n.receiptsWarrantyProof),
                  _buildPhotosGallery(true),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      t,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: context.colors.textPrimary,
      ),
    ),
  );

  Widget _statusChips() {
    final c = context.colors;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final status in ItemStatus.values)
          Tappable(
            semanticLabel: status.displayName,
            onTap: () => _update(() => _selectedStatus = status),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _selectedStatus == status ? c.accent : c.fill,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(
                    status.icon,
                    size: 14,
                    color: _selectedStatus == status
                        ? c.onAccent
                        : status.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status.displayName,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _selectedStatus == status
                          ? c.onAccent
                          : c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _datePickerField({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime?> onSelected,
  }) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        Tappable(
          semanticLabel: label,
          onTap: () async {
            final picked = await _pickDate(date);
            if (picked != null) onSelected(picked);
          },
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: c.fill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? formatDate(context, date)
                        : context.l10n.notSet,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: date != null ? c.textPrimary : c.textMuted,
                    ),
                  ),
                ),
                if (date != null)
                  Tappable(
                    semanticLabel: MaterialLocalizations.of(context)
                        .clearButtonTooltip,
                    onTap: () => onSelected(null),
                    child: AppIcon(
                      Icons.clear,
                      size: 16,
                      color: c.textSecondary,
                    ),
                  )
                else
                  AppIcon(
                    Icons.event_outlined,
                    size: 16,
                    color: c.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
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
          ? (isReceipt
                ? context.l10n.receiptCaptured
                : context.l10n.photoCaptured)
          : (isReceipt
                ? context.l10n.receiptSelected
                : context.l10n.photoSelected),
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
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: context.colors.cardShadow,
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
                    isReceipt
                        ? context.l10n.photoTabReceipt
                        : context.l10n.photoTabProduct,
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
                      semanticLabel: MaterialLocalizations.of(context)
                          .deleteButtonTooltip,
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

  Future<void> _pickStorageLocation() async {
    final selectedBox = await LocationPickerSheet.show(
      context,
      initialBoxId: _currentBoxId,
    );
    if (!mounted || selectedBox == null) return;
    _update(() {
      _currentBoxId = selectedBox.id;
    });
  }
}
