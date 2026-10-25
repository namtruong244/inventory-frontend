import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'box_qr_scan_sheet.dart';

/// Reusable modal sheet to pick a storage location hierarchically
/// (Level-by-level drill down) or by scanning a box QR code directly.
/// Used in:
/// 1. Add Item Form (ItemCreateScreen) for selecting storage container
/// 2. Move Item actions (ItemDetailsScreen, ItemsScreen, BoxDetailsScreen)
class LocationPickerSheet extends StatefulWidget {
  final String? initialBoxId;
  final String title;
  final String subtitle;
  final String confirmButtonText;
  final String? currentBoxId;

  const LocationPickerSheet({
    super.key,
    this.initialBoxId,
    this.title = 'Select Storage Location',
    this.subtitle = 'Choose a room, shelf, or container',
    this.confirmButtonText = 'Select Location',
    this.currentBoxId,
  });

  static Future<Box?> show(
    BuildContext context, {
    String? initialBoxId,
    String title = 'Select Storage Location',
    String subtitle = 'Choose a room, shelf, or container',
    String confirmButtonText = 'Select Location',
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
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
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

            // Current Location Badge if applicable
            if (currentAssignedBox != null) ...[
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
                        currentAssignedBox.type.icon,
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
                            provider.getBreadcrumbString(currentAssignedBox.id),
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
                        border: Border.all(color: Colors.grey.shade200),
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
                              'You can select "${currentParentBox.name}" directly above.',
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
                  color: isSameAsCurrent
                      ? const Color(0xFFFEF3C7).withValues(alpha: 0.6)
                      : const Color(0xFFECFDF5),
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
                          ? const Color(0xFFB45309)
                          : const Color(0xFF047857),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSameAsCurrent
                                ? 'Currently selected location'
                                : 'Selected Storage Destination',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSameAsCurrent
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFF047857),
                            ),
                          ),
                          Text(
                            provider.getBreadcrumbString(selectedBox.id),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSameAsCurrent
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

            // Confirm Button
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
                onPressed: canConfirm ? _confirmSelection : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.confirmButtonText,
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

  /// Option to select current parent container directly
  Widget _buildCurrentParentDirectSelectCard(Box currentParentBox, InventoryProvider provider) {
    final isSelected = _selectedBoxId == currentParentBox.id;
    final isCurrent = widget.currentBoxId == currentParentBox.id;

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
    final isCurrent = widget.currentBoxId == box.id;
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
