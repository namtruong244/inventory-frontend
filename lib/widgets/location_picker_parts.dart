part of 'location_picker_sheet.dart';

/// Breadcrumb and hierarchy tile builders.
extension _LocationPickerParts on _LocationPickerSheetState {
  /// Builds the breadcrumb bar showing current navigation level with jump-to capability
  Widget _buildBreadcrumbBar(InventoryProvider provider) {
    final List<Widget> crumbs = [];

    // Root crumb
    final isAtRoot = _currentLevelParentId == null;
    crumbs.add(
      InkWell(
        onTap: isAtRoot ? null : () => _update(() => _currentLevelParentId = null),
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
            onTap: isCurrent ? null : () => _update(() => _currentLevelParentId = box.id),
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
