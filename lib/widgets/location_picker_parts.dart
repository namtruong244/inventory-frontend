part of 'location_picker_sheet.dart';

/// Breadcrumb and hierarchy tile builders.
extension _LocationPickerParts on _LocationPickerSheetState {
  /// Breadcrumb: up tile, then "All › ancestors › current" (crumbs jump up).
  Widget _buildBreadcrumbBar(InventoryProvider provider) {
    final c = context.colors;
    final trail = provider.getBreadcrumb(_currentLevelParentId!);
    Widget chevron() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AppIcon(Icons.chevron_right_rounded, size: 13, color: c.textMuted),
    );
    Widget crumb(String label, bool current, VoidCallback? onTap) => Tappable(
      semanticLabel: label,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            fontSize: 13,
            fontWeight: current ? FontWeight.w800 : FontWeight.w600,
            color: current ? c.textPrimary : c.textSecondary,
          ),
        ),
      ),
    );
    return Row(
      children: [
        Tappable(
          semanticLabel: context.l10n.locationPickerUp,
          onTap: _stepUp,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c.fill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppIcon(
              Icons.arrow_back_rounded,
              size: 16,
              color: c.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LayoutBuilder(
            // Reversed so a long trail keeps the current crumb visible; the
            // min width keeps a short trail left-aligned.
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Row(
                  children: [
                    crumb(
                      context.l10n.locationPickerAll,
                      false,
                      () => _update(() => _currentLevelParentId = null),
                    ),
                    for (int i = 0; i < trail.length; i++) ...[
                      chevron(),
                      crumb(
                        trail[i].name,
                        i == trail.length - 1,
                        i == trail.length - 1
                            ? null
                            : () => _update(
                                () => _currentLevelParentId = trail[i].id,
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioCircle(bool isSelected, {double size = 22}) {
    final c = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? c.primary : Colors.transparent,
        border: isSelected ? null : Border.all(color: c.trackOff, width: 1.5),
      ),
      child: isSelected
          ? AppIcon(Icons.check_rounded, size: size * 0.62, color: c.accent)
          : null,
    );
  }

  /// "CURRENT LOCATION" card: the level being browsed, selectable as a whole.
  Widget _buildCurrentParentCard(Box box) {
    final c = context.colors;
    final tone = boxTypeTone(box.type);
    final isSelected = _selectedBoxId == box.id;
    return Tappable(
      semanticLabel: box.name,
      onTap: () => _selectBox(box.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.warningSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTones.amber, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(13),
              ),
              child: AppIcon(box.type.icon, size: 20, color: tone.fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.locationCurrentKicker.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: c.warningStrong,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    box.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildRadioCircle(isSelected, size: 24),
          ],
        ),
      ),
    );
  }

  /// One grouped card with a divider between rows.
  Widget _buildBoxList(List<Box> boxes, InventoryProvider provider) {
    final c = context.colors;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < boxes.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: c.border),
            _buildBoxHierarchyTile(boxes[i], provider),
          ],
        ],
      ),
    );
  }

  Widget _buildBoxHierarchyTile(Box box, InventoryProvider provider) {
    final isSelected = _selectedBoxId == box.id;
    final childBoxes = provider.getBoxesIn(box.id);
    final hasChildren = childBoxes.isNotEmpty;
    final itemCount = provider.countTotalItemsIn(box.id);
    final c = context.colors;
    final tone = boxTypeTone(box.type);
    final meta = hasChildren
        ? '${context.l10n.itemsCountLabel(itemCount)} \u00b7 '
              '${context.l10n.locationInsideCount(childBoxes.length)}'
        : context.l10n.itemsCountLabel(itemCount);

    return Material(
      color: isSelected ? c.fill : Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: e2eId(
              'loc_pick_${box.name}',
              InkWell(
                onTap: () => _selectBox(box.id),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    10,
                    hasChildren ? 0 : 12,
                    10,
                  ),
                  child: Row(
                    children: [
                      _buildRadioCircle(isSelected),
                      const SizedBox(width: 12),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: tone.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppIcon(box.type.icon, size: 18, color: tone.fg),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              box.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (hasChildren)
            e2eId(
              'loc_drill_${box.name}',
              Tappable(
                semanticLabel: context.l10n.scanOpen,
                onTap: () => _drillDown(box.id),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c.fill,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AppIcon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: c.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyLevel(Box? parent) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          AppIcon(Icons.inventory_2_outlined, size: 32, color: c.textMuted),
          const SizedBox(height: 8),
          Text(
            parent != null
                ? context.l10n.noSubContainersInside(parent.name)
                : context.l10n.noLocationsAvailable,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// "Create location here" row with the level it will be created in.
  Widget _buildCreateHere(Box? parent) {
    final c = context.colors;
    return e2eId(
      'location_create_here',
      Tappable(
        semanticLabel: context.l10n.locationCreateHereShort,
        onTap: _createHere,
        child: Container(
          constraints: const BoxConstraints(minHeight: 42),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: c.fill,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              AppIcon(Icons.add_rounded, size: 18, color: c.textPrimary),
              const SizedBox(width: 10),
              Text(
                context.l10n.locationCreateHereShort,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  textAlign: TextAlign.end,
                  context.l10n.locationPickerIn(
                    parent?.name ?? context.l10n.commonRoot,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _searchResults(InventoryProvider provider) {
    final c = context.colors;
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
              style: TextStyle(color: c.textSecondary),
            ),
          ),
        ),
      ];
    }
    return [
      for (final box in matches)
        e2eId(
          'loc_pick_${box.name}',
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Tappable(
              semanticLabel: box.name,
              onTap: () => _update(() {
                _selectedBoxId = box.id;
                _currentLevelParentId = box.parentId;
                _query = '';
              }),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: box.id == _selectedBoxId ? c.border : c.fill,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    SoftIconTile(
                      box.type.icon,
                      color: boxTypeTone(box.type).fg,
                      background: boxTypeTone(box.type).bg,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            box.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            provider.getBreadcrumbString(box.id),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    ];
  }
}
