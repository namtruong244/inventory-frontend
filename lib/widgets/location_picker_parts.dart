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
            color: isAtRoot ? context.colors.accent : context.colors.fill,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                Icons.home_outlined,
                size: 14,
                color: isAtRoot ? context.colors.onAccent : context.colors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                context.l10n.commonRoot,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isAtRoot ? context.colors.onAccent : context.colors.textSecondary,
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
            child: AppIcon(Icons.chevron_right_rounded, size: 16, color: context.colors.textMuted),
          ),
        );

        crumbs.add(
          InkWell(
            onTap: isCurrent ? null : () => _update(() => _currentLevelParentId = box.id),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCurrent ? context.colors.accent : context.colors.fill,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                box.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  color: isCurrent ? context.colors.onAccent : context.colors.textSecondary,
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
                  color: context.colors.fill,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppIcon(Icons.arrow_upward_rounded, size: 14, color: context.colors.textPrimary),
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
    final c = context.colors;

    return Material(
      color: isSelected ? c.accent.withValues(alpha: 0.35) : c.fill,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _selectBox(currentParentBox.id),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              _buildRadioCircle(isSelected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            context.l10n.storeDirectlyIn(currentParentBox.name),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 6),
                          SoftChip(label: context.l10n.commonCurrent, background: c.surface, foreground: c.textPrimary),
                        ],
                      ],
                    ),
                    Text(
                      context.l10n.placeItemAtThisLevel,
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
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
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? c.accent.withValues(alpha: 0.35) : c.fill,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _selectBox(box.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _buildRadioCircle(isSelected),
                const SizedBox(width: 10),
                SoftIconTile(box.type.icon, color: c.textPrimary, background: c.surface, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              box.name,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 6),
                            SoftChip(label: context.l10n.commonCurrent, background: c.surface, foreground: c.textPrimary),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          SoftChip(label: box.type.displayName, background: c.surface, foreground: c.textSecondary),
                          SoftChip.tone(context.l10n.itemsCountLabel(itemCount), AppTones.sky),
                          if (hasChildren) SoftChip.tone(context.l10n.nestedCountLabel(childBoxes.length), AppTones.lilac),
                        ],
                      ),
                    ],
                  ),
                ),
                // Drill-down: opens the children of this box
                if (hasChildren)
                  Tappable(
                    semanticLabel: context.l10n.scanOpen,
                    onTap: () => _drillDown(box.id),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: c.surface, shape: BoxShape.circle),
                      child: AppIcon(Icons.chevron_right_rounded, size: 22, color: c.textPrimary),
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
    final c = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? c.primary : c.surface,
      ),
      child: isSelected ? AppIcon(Icons.check_rounded, size: 15, color: c.accent) : null,
    );
  }
}
