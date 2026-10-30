import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../utils/text_normalize.dart';
import 'app_feedback.dart';
import 'box_qr_scan_sheet.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';
import 'soft_ui.dart';
import 'tappable.dart';

/// Reusable modal sheet to pick a storage location hierarchically
/// (Level-by-level drill down) or by scanning a box QR code directly.
/// Used in:
/// 1. Add Item Form (ItemCreateScreen) for selecting storage container
/// 2. Move Item actions (ItemDetailsScreen, ItemsScreen, BoxDetailsScreen)
part 'location_picker_parts.dart';

class LocationPickerSheet extends StatefulWidget {
  final String? initialBoxId;
  final String? title;
  final String? subtitle;
  final String? confirmButtonText;
  final String? currentBoxId;

  const LocationPickerSheet({
    super.key,
    this.initialBoxId,
    this.title,
    this.subtitle,
    this.confirmButtonText,
    this.currentBoxId,
  });

  static Future<Box?> show(
    BuildContext context, {
    String? initialBoxId,
    String? title,
    String? subtitle,
    String? confirmButtonText,
    String? currentBoxId,
  }) {
    return showModalBottomSheet<Box>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationPickerSheet(
        initialBoxId: initialBoxId,
        title: title,
        subtitle: subtitle,
        confirmButtonText: confirmButtonText,
        currentBoxId: currentBoxId,
      ),
    );
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  /// setState entry point for the extension in the part file.
  void _update(VoidCallback fn) => setState(fn);

  String? _currentLevelParentId;
  String? _selectedBoxId;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedBoxId = widget.initialBoxId ?? widget.currentBoxId;

    // Start hierarchy at root
    _currentLevelParentId = null;
  }

  void _drillDown(String boxId) {
    setState(() {
      _currentLevelParentId = boxId;
    });
  }

  void _stepUp() {
    if (_currentLevelParentId == null) return;
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final currentBox = provider.getBoxById(_currentLevelParentId!);
    setState(() {
      _currentLevelParentId = currentBox?.parentId;
    });
  }

  /// Asks for a name and creates a location inside the level being browsed, then selects it.
  Future<void> _createHere() async {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(context.l10n.createLocationHere),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: context.l10n.locationNameHint,
            ),
            onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(context.l10n.commonCreate),
            ),
          ],
        );
      },
    );
    if (name == null || !mounted) return;
    if (name.isEmpty) {
      AppFeedback.showError(context, context.l10n.pleaseEnterAValidLocation);
      return;
    }
    final box = Box(
      name: name,
      type: _currentLevelParentId == null ? StorageType.room : StorageType.box,
      label: 'loc_${const Uuid().v4().substring(0, 8)}',
      parentId: _currentLevelParentId,
    );
    final ok = await provider.addBox(box);
    if (!mounted) return;
    if (ok) {
      setState(() => _selectedBoxId = box.id);
    } else {
      AppFeedback.showError(context, context.l10n.somethingWentWrongPleaseTry);
    }
  }

  void _selectBox(String boxId) {
    setState(() {
      _selectedBoxId = boxId;
    });
  }

  Future<void> _openQRScanner() async {
    final scannedBox = await showModalBottomSheet<Box>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const BoxQRScanSheet(),
    );

    if (scannedBox != null && mounted) {
      setState(() {
        _selectedBoxId = scannedBox.id;
        _currentLevelParentId = scannedBox.parentId;
      });

      // Directly select and close
      Navigator.pop(context, scannedBox);
    }
  }

  List<Widget> _searchResults(InventoryProvider provider) {
    final q = normalizeVi(_query.trim());
    final matches = provider.boxes
        .where(
          (b) =>
              containsNormalized(b.name, q) ||
              containsNormalized(b.label, q) ||
              containsNormalized(provider.getBreadcrumbString(b.id), q),
        )
        .toList();
    if (matches.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              context.l10n.noMatchingLocationsFound,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
        ),
      ];
    }
    return [
      for (final box in matches)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: AppIcon(box.type.icon, color: context.colors.textPrimary),
          title: Text(box.name),
          subtitle: Text(
            provider.getBreadcrumbString(box.id),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          selected: box.id == _selectedBoxId,
          onTap: () => setState(() {
            _selectedBoxId = box.id;
            _currentLevelParentId = box.parentId;
            _query = '';
          }),
        ),
    ];
  }

  void _confirmSelection() {
    if (_selectedBoxId == null) return;
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final box = provider.getBoxById(_selectedBoxId!);
    if (box != null) {
      Navigator.pop(context, box);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final Box? currentAssignedBox = widget.currentBoxId != null
        ? provider.getBoxById(widget.currentBoxId!)
        : null;

    final List<Box> visibleBoxes = _currentLevelParentId == null
        ? provider.getRootBoxes()
        : provider.getBoxesIn(_currentLevelParentId!);

    final Box? currentParentBox = _currentLevelParentId != null
        ? provider.getBoxById(_currentLevelParentId!)
        : null;

    final Box? selectedBox = _selectedBoxId != null
        ? provider.getBoxById(_selectedBoxId!)
        : null;

    final isSameAsCurrent =
        widget.currentBoxId != null && _selectedBoxId == widget.currentBoxId;
    final canConfirm = _selectedBoxId != null;

    return Material(
      color: context.colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Top Header: Title & Scan QR action button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title ?? context.l10n.selectStorageLocation,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle ?? context.l10n.chooseARoomShelfOr,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quick Scan QR Button
                Tappable(
                  semanticLabel: context.l10n.scanQr,
                  onTap: _openQRScanner,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.accent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          Icons.qr_code_scanner_rounded,
                          color: context.colors.onAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          context.l10n.scanQr,
                          style: TextStyle(
                            color: context.colors.onAccent,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Current Location Badge if applicable
            if (currentAssignedBox != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: context.colors.fill,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppIcon(
                        currentAssignedBox.type.icon,
                        size: 16,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.currentLocation,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textSecondary,
                            ),
                          ),
                          Text(
                            provider.getBreadcrumbString(currentAssignedBox.id),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: context.colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Search every location by name, ignoring case and accents
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: context.l10n.searchLocationsRoomsContainers,
                prefixIcon: const AppIcon(Icons.search_rounded, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),

            // Level Drill-down Breadcrumb Navigation
            if (_query.trim().isEmpty) ...[
              _buildBreadcrumbBar(provider),
              const SizedBox(height: 10),
            ],

            // Level Content: Either root boxes or sub-containers
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.42,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (_query.trim().isNotEmpty)
                    ..._searchResults(provider)
                  else ...[
                    // Option to select current parent level directly
                    if (currentParentBox != null) ...[
                      _buildCurrentParentDirectSelectCard(
                        currentParentBox,
                        provider,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            context.l10n.subContainersInside(
                              visibleBoxes.length,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (visibleBoxes.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.fill,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppIcon(
                              Icons.inventory_2_outlined,
                              size: 36,
                              color: context.colors.textMuted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentParentBox != null
                                  ? context.l10n.noSubContainersInside(
                                      currentParentBox.name,
                                    )
                                  : context.l10n.noLocationsAvailable,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.colors.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            if (currentParentBox != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                context.l10n.youCanSelectDirectlyAbove(
                                  currentParentBox.name,
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: context.colors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      ...visibleBoxes.map((box) {
                        return _buildBoxHierarchyTile(box, provider);
                      }),

                    // Make the place you are looking for, right where you are
                    TextButton.icon(
                      onPressed: _createHere,
                      icon: const AppIcon(Icons.add_rounded, size: 20),
                      label: Text(context.l10n.createLocationHere),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Selected Target Destination Card
            if (selectedBox != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSameAsCurrent
                      ? context.colors.warningSoft.withValues(alpha: 0.6)
                      : context.colors.successSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    AppIcon(
                      isSameAsCurrent
                          ? Icons.info_outline_rounded
                          : Icons.check_circle_rounded,
                      size: 20,
                      color: isSameAsCurrent
                          ? context.colors.warningStrong
                          : context.colors.successStrong,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSameAsCurrent
                                ? context.l10n.currentlySelectedLocation
                                : context.l10n.selectedStorageDestination,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSameAsCurrent
                                  ? context.colors.warningStrong
                                  : context.colors.successStrong,
                            ),
                          ),
                          Text(
                            provider.getBreadcrumbString(selectedBox.id),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSameAsCurrent
                                  ? context.colors.warningStrong
                                  : AppTones.matcha,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.accent,
                  foregroundColor: context.colors.onAccent,
                  disabledBackgroundColor: context.colors.fill,
                  disabledForegroundColor: context.colors.textMuted,
                ),
                onPressed: canConfirm ? _confirmSelection : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppIcon(Icons.check_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.confirmButtonText ?? context.l10n.selectLocation,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
