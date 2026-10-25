import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'box_qr_scan_sheet.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

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

    final isSameAsCurrent = widget.currentBoxId != null && _selectedBoxId == widget.currentBoxId;
    final canConfirm = _selectedBoxId != null;

    return Material(
      color: context.colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle ?? context.l10n.chooseARoomShelfOr,
                        style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Quick Scan QR Button
                Material(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _openQRScanner,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            context.l10n.scanQr,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Current Location Badge if applicable
            if (currentAssignedBox != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: context.colors.fill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
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

            // Level Drill-down Breadcrumb Navigation
            _buildBreadcrumbBar(provider),
            const SizedBox(height: 10),

            // Level Content: Either root boxes or sub-containers
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.42,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Option to select current parent level directly
                  if (currentParentBox != null) ...[
                    _buildCurrentParentDirectSelectCard(currentParentBox, provider),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          context.l10n.subContainersInside(visibleBoxes.length),
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
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                      decoration: BoxDecoration(
                        color: context.colors.fill,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 36, color: context.colors.textMuted),
                          const SizedBox(height: 8),
                          Text(
                            currentParentBox != null
                                ? context.l10n.noSubContainersInside(currentParentBox.name)
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
                              context.l10n.youCanSelectDirectlyAbove(currentParentBox.name),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: context.colors.textMuted, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    ...visibleBoxes.map((box) {
                      return _buildBoxHierarchyTile(box, provider);
                    }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Selected Target Destination Card
            if (selectedBox != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSameAsCurrent
                      ? context.colors.warningSoft.withValues(alpha: 0.6)
                      : context.colors.successSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSameAsCurrent
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
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
                                  : const Color(0xFF065F46),
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: context.colors.border,
                  disabledForegroundColor: context.colors.textSecondary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: canConfirm ? _confirmSelection : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.confirmButtonText ?? context.l10n.selectLocation,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
