import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import 'box_qr_scan_sheet.dart';
import 'location_picker_sheet.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

/// Modal bottom sheet to move an item to another storage location.
/// Features:
/// 1. Hierarchical, level-by-level drill down selection (Room -> Shelf -> Box -> Drawer).
/// 2. Interactive breadcrumb trail and back navigation.
/// 3. Direct QR code scanner to scan any box's label/QR to move instantly.
part 'move_item_sheet_parts.dart';

class MoveItemSheet extends StatefulWidget {
  final Item item;

  const MoveItemSheet({super.key, required this.item});

  static Future<bool?> show(BuildContext context, Item item) async {
    final pickedBox = await LocationPickerSheet.show(
      context,
      initialBoxId: item.boxId,
      currentBoxId: item.boxId,
      title: context.l10n.moveItemLocation,
      subtitle: context.l10n.selectNewStorageDestinationFor(item.name),
      confirmButtonText: context.l10n.confirmMove,
    );

    if (pickedBox != null && pickedBox.id != item.boxId && context.mounted) {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      provider.moveItem(item.id, pickedBox.id);
      AppFeedback.showSuccess(
        context,
        context.l10n.movedTo(item.name, pickedBox.name),
      );
      return true;
    }
    return false;
  }

  @override
  State<MoveItemSheet> createState() => _MoveItemSheetState();
}

class _MoveItemSheetState extends State<MoveItemSheet> {
  /// setState entry point for the extension in the part file.
  void _update(VoidCallback fn) => setState(fn);

  // null = Root level (top-level locations like Floors/Rooms without parent)
  String? _currentLevelParentId;
  String? _selectedBoxId;
  bool _isMoving = false;

  @override
  void initState() {
    super.initState();
    _selectedBoxId = widget.item.boxId;
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
      builder: (ctx) => BoxQRScanSheet(item: widget.item),
    );

    if (scannedBox != null && mounted) {
      setState(() {
        _selectedBoxId = scannedBox.id;
        // Also drill into its parent level so user sees where it is
        _currentLevelParentId = scannedBox.parentId;
      });

      // Prompt to confirm or auto-apply
      _confirmMove(targetBoxId: scannedBox.id);
    }
  }

  Future<void> _confirmMove({String? targetBoxId}) async {
    final destId = targetBoxId ?? _selectedBoxId;
    if (destId == null || destId == widget.item.boxId) return;

    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final targetBox = provider.getBoxById(destId);
    if (targetBox == null) return;

    setState(() => _isMoving = true);
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;
    provider.moveItem(widget.item.id, destId);

    if (mounted) {
      Navigator.pop(context, true);
      AppFeedback.showSuccess(
        context,
        context.l10n.movedTo(widget.item.name, targetBox.name),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final currentBox = provider.getBoxById(widget.item.boxId);
    final currentBreadcrumb = provider.getBreadcrumbString(widget.item.boxId);

    // Get items for the current level
    final List<Box> visibleBoxes = _currentLevelParentId == null
        ? provider.getRootBoxes()
        : provider.getBoxesIn(_currentLevelParentId!);

    final Box? currentParentBox = _currentLevelParentId != null
        ? provider.getBoxById(_currentLevelParentId!)
        : null;

    final Box? selectedBox = _selectedBoxId != null
        ? provider.getBoxById(_selectedBoxId!)
        : null;

    final isSelectedSameAsCurrent = _selectedBoxId == widget.item.boxId;
    final canConfirm = _selectedBoxId != null && !isSelectedSameAsCurrent && !_isMoving;

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
                        context.l10n.moveItemLocation,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        context.l10n.selectNewStorageDestinationFor2,
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

            // Current Location Badge
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
                      currentBox?.type.icon ?? Icons.inventory_2_outlined,
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
                          currentBreadcrumb,
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
                  // Option to select the current parent level directly
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
                        border: Border.all(color: context.colors.border, style: BorderStyle.solid),
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
                              context.l10n.youCanStoreDirectlyIn(widget.item.name),
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
                  color: isSelectedSameAsCurrent
                      ? context.colors.warningSoft.withValues(alpha: 0.6)
                      : context.colors.successSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelectedSameAsCurrent
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelectedSameAsCurrent
                          ? Icons.info_outline_rounded
                          : Icons.check_circle_rounded,
                      size: 20,
                      color: isSelectedSameAsCurrent
                          ? context.colors.warningStrong
                          : context.colors.successStrong,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSelectedSameAsCurrent
                                ? context.l10n.itemIsAlreadyInThis
                                : context.l10n.targetDestination,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelectedSameAsCurrent
                                  ? context.colors.warningStrong
                                  : context.colors.successStrong,
                            ),
                          ),
                          Text(
                            provider.getBreadcrumbString(selectedBox.id),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelectedSameAsCurrent
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

            // Confirm Move Button
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
                onPressed: canConfirm ? () => _confirmMove() : null,
                child: _isMoving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.drive_file_move_outlined, size: 20),
                          SizedBox(width: 8),
                          Text(
                            context.l10n.confirmMove,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
