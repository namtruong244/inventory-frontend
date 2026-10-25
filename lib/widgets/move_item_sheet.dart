import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import 'location_picker_sheet.dart';

/// Modal bottom sheet to move an item to another storage location.
/// Features:
/// 1. Hierarchical, level-by-level drill down selection (Room -> Shelf -> Box -> Drawer).
/// 2. Interactive breadcrumb trail and back navigation.
/// 3. Direct QR code scanner to scan any box's label/QR to move instantly.
class MoveItemSheet extends StatefulWidget {
  final Item item;

  const MoveItemSheet({super.key, required this.item});

  static Future<bool?> show(BuildContext context, Item item) async {
    final pickedBox = await LocationPickerSheet.show(
      context,
      initialBoxId: item.boxId,
      currentBoxId: item.boxId,
      title: 'Move Item Location',
      subtitle: 'Select new storage destination for "${item.name}"',
      confirmButtonText: 'Confirm Move',
    );

    if (pickedBox != null && pickedBox.id != item.boxId && context.mounted) {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      provider.moveItem(item.id, pickedBox.id);
      AppFeedback.showSuccess(
        context,
        'Moved "${item.name}" to "${pickedBox.name}"',
      );
      return true;
    }
    return false;
  }

  @override
  State<MoveItemSheet> createState() => _MoveItemSheetState();
}

class _MoveItemSheetState extends State<MoveItemSheet> {
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
        'Moved "${widget.item.name}" to "${targetBox.name}"',
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
      color: Colors.white,
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
                  color: Colors.grey.shade300,
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
                      const Text(
                        'Move Item Location',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Select new storage destination for item',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                // Quick Scan QR Button
                Material(
                  color: const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _openQRScanner,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Scan QR',
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
                color: const Color(0xFFF4F4F6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      currentBox?.type.icon ?? Icons.inventory_2_outlined,
                      size: 16,
                      color: const Color(0xFF18181B),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Location',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF71717A),
                          ),
                        ),
                        Text(
                          currentBreadcrumb,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF18181B),
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
                          'Sub-containers inside (${visibleBoxes.length})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
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
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 36, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            currentParentBox != null
                                ? 'No sub-containers inside "${currentParentBox.name}"'
                                : 'No locations available',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          if (currentParentBox != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              'You can store "${widget.item.name}" directly in this container.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
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
                      ? const Color(0xFFFEF3C7).withValues(alpha: 0.6)
                      : const Color(0xFFECFDF5),
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
                          ? const Color(0xFFB45309)
                          : const Color(0xFF047857),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSelectedSameAsCurrent
                                ? 'Item is already in this location'
                                : 'Target Destination',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelectedSameAsCurrent
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFF047857),
                            ),
                          ),
                          Text(
                            provider.getBreadcrumbString(selectedBox.id),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelectedSameAsCurrent
                                  ? const Color(0xFF92400E)
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
                  backgroundColor: const Color(0xFF18181B),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
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
                        children: const [
                          Icon(Icons.drive_file_move_outlined, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Confirm Move',
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

  /// Builds the breadcrumb bar showing current navigation level with jump-to capability
  Widget _buildBreadcrumbBar(InventoryProvider provider) {
    final List<Widget> crumbs = [];

    // Root crumb
    final isAtRoot = _currentLevelParentId == null;
    crumbs.add(
      InkWell(
        onTap: isAtRoot ? null : () => setState(() => _currentLevelParentId = null),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isAtRoot ? const Color(0xFF18181B) : const Color(0xFFF4F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.home_outlined,
                size: 14,
                color: isAtRoot ? Colors.white : const Color(0xFF71717A),
              ),
              const SizedBox(width: 4),
              Text(
                'Root',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isAtRoot ? Colors.white : const Color(0xFF71717A),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (_currentLevelParentId != null) {
      final trail = provider.getBreadcrumb(_currentLevelParentId!);
      for (int i = 0; i < trail.length; i++) {
        final box = trail[i];
        final isCurrent = i == trail.length - 1;

        crumbs.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey.shade400),
          ),
        );

        crumbs.add(
          InkWell(
            onTap: isCurrent ? null : () => setState(() => _currentLevelParentId = box.id),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCurrent ? const Color(0xFF18181B) : const Color(0xFFF4F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                box.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  color: isCurrent ? Colors.white : const Color(0xFF71717A),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Step Up / Back Button if nested
          if (_currentLevelParentId != null) ...[
            InkWell(
              onTap: _stepUp,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_upward_rounded, size: 14, color: Color(0xFF18181B)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: crumbs),
            ),
          ),
        ],
      ),
    );
  }

  /// Option to select the current parent container directly
  Widget _buildCurrentParentDirectSelectCard(Box currentParentBox, InventoryProvider provider) {
    final isSelected = _selectedBoxId == currentParentBox.id;
    final isCurrent = widget.item.boxId == currentParentBox.id;

    return Material(
      color: isSelected ? const Color(0xFFF4F4F6) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _selectBox(currentParentBox.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF18181B) : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _buildRadioCircle(isSelected),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Store directly in "${currentParentBox.name}"',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Current', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      'Place item at this level without placing it into any sub-box',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a box tile in the current level with drill-down and selection options
  Widget _buildBoxHierarchyTile(Box box, InventoryProvider provider) {
    final isSelected = _selectedBoxId == box.id;
    final isCurrent = widget.item.boxId == box.id;
    final childBoxes = provider.getBoxesIn(box.id);
    final hasChildren = childBoxes.isNotEmpty;
    final itemCount = provider.countTotalItemsIn(box.id);

    return Material(
      color: isSelected ? const Color(0xFFF4F4F6) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF18181B) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _selectBox(box.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Radio selection
                _buildRadioCircle(isSelected),
                const SizedBox(width: 8),

                // Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(box.type.icon, size: 18, color: const Color(0xFF18181B)),
                ),
                const SizedBox(width: 10),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              box.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Current', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            box.type.displayName,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          Text(' • ', style: TextStyle(color: Colors.grey.shade400)),
                          Text(
                            '$itemCount items',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          if (hasChildren) ...[
                            Text(' • ', style: TextStyle(color: Colors.grey.shade400)),
                            Text(
                              '${childBoxes.length} sub-boxes',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Drill-down button if it has children
                if (hasChildren)
                  InkWell(
                    onTap: () => _drillDown(box.id),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Open',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.chevron_right_rounded, size: 16),
                        ],
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

  Widget _buildRadioCircle(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xFF18181B) : Colors.grey.shade300,
          width: isSelected ? 6.5 : 2,
        ),
        color: Colors.white,
      ),
    );
  }
}

/// Specialized QR Scanner bottom sheet to scan box labels directly
class BoxQRScanSheet extends StatefulWidget {
  final Item? item;

  const BoxQRScanSheet({super.key, this.item});

  @override
  State<BoxQRScanSheet> createState() => _BoxQRScanSheetState();
}

class _BoxQRScanSheetState extends State<BoxQRScanSheet> {
  final MobileScannerController _controller = MobileScannerController();
  final TextEditingController _manualInputController = TextEditingController();
  bool _isProcessing = false;
  Box? _detectedBox;

  @override
  void dispose() {
    _controller.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || _detectedBox != null) return;

    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null) {
        _processScannedCode(code);
      }
    }
  }

  void _processScannedCode(String rawCode) {
    setState(() => _isProcessing = true);
    final code = rawCode.trim();
    final provider = Provider.of<InventoryProvider>(context, listen: false);

    // Look up Box by QR label or UUID
    final box = provider.getBoxByLabel(code) ?? provider.getBoxById(code);

    if (box != null) {
      setState(() {
        _detectedBox = box;
        _isProcessing = false;
      });
    } else {
      setState(() => _isProcessing = false);
      AppFeedback.showError(
        context,
        'No storage box found with code "$code". Please scan a valid box QR label.',
      );
    }
  }

  void _showTestPresetsModal(InventoryProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Test Box QR Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Simulate scanning a physical box QR sticker:',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.boxes.length,
                  itemBuilder: (context, idx) {
                    final b = provider.boxes[idx];
                    final breadcrumb = provider.getBreadcrumbString(b.id);
                    return ListTile(
                      dense: true,
                      leading: Icon(b.type.icon, size: 20, color: const Color(0xFF18181B)),
                      title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('$breadcrumb (${b.label})', style: const TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.qr_code_2_rounded, size: 20),
                      onTap: () {
                        Navigator.pop(ctx);
                        _processScannedCode(b.label);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showManualInputDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Enter Box Label / QR', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _manualInputController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. loc_electronics_box',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF18181B),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final text = _manualInputController.text.trim();
                Navigator.pop(ctx);
                if (text.isNotEmpty) {
                  _processScannedCode(text);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    return Material(
      color: Colors.black,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.82,
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Box QR Code',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Point camera at target box sticker',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Torch toggle
                    IconButton(
                      icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                      onPressed: () => _controller.toggleTorch(),
                    ),
                  ],
                ),
              ),

              // Camera Viewport & Overlay
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                    ),

                    // Viewfinder styling
                    Center(
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            // Corner markers
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF10B981), width: 4),
                                    left: BorderSide(color: Color(0xFF10B981), width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF10B981), width: 4),
                                    right: BorderSide(color: Color(0xFF10B981), width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFF10B981), width: 4),
                                    left: BorderSide(color: Color(0xFF10B981), width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFF10B981), width: 4),
                                    right: BorderSide(color: Color(0xFF10B981), width: 4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Processing overlay
                    if (_isProcessing)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom control & result panel
              Container(
                color: const Color(0xFF18181B),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_detectedBox != null) ...[
                      // Detected box card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27272A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _detectedBox!.type.icon,
                                color: const Color(0xFF10B981),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _detectedBox!.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    provider.getBreadcrumbString(_detectedBox!.id),
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
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

                      // Confirm button
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () => setState(() => _detectedBox = null),
                              child: const Text('Scan Again'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () => Navigator.pop(context, _detectedBox),
                              child: const Text('Move to this Box', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Helper text & test presets buttons
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.white70),
                            onPressed: () => _showTestPresetsModal(provider),
                            icon: const Icon(Icons.science_outlined, size: 16),
                            label: const Text('Test with Presets', style: TextStyle(fontSize: 12)),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.white70),
                            onPressed: _showManualInputDialog,
                            icon: const Icon(Icons.keyboard_outlined, size: 16),
                            label: const Text('Enter Code', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
