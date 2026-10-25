part of 'boxes_screen.dart';

/// Box card, empty state and filter chip builders.
extension _BoxesScreenParts on _BoxesScreenState {

  Widget _buildFlatBoxCard(Box box, InventoryProvider provider) {
    final itemCount = provider.countTotalItemsIn(box.id);
    final subBoxCount = provider.getBoxesIn(box.id).length;
    final breadcrumbList = provider.getBreadcrumb(box.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Slidable(
          key: ValueKey(box.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.65,
            children: [
              SlidableAction(
                onPressed: (_) => MoveLocationDialog.show(context, box),
                backgroundColor: const Color(0xFF64748B),
                foregroundColor: Colors.white,
                icon: Icons.drive_file_move_outlined,
                label: context.l10n.commonMove,
              ),
              SlidableAction(
                onPressed: (_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BoxCreateScreen(existingBox: box),
                    ),
                  );
                },
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                icon: Icons.edit_outlined,
                label: context.l10n.commonEdit,
              ),
              SlidableAction(
                onPressed: (_) async {
                  final confirmed = await TrashActions.confirm(
                    context,
                    name: box.name,
                    isBox: true,
                    hasContents: true,
                  );
                  if (confirmed && mounted) {
                    final ok = await provider.deleteBox(box.id, cascade: true);
                    if (!mounted) return;
                    if (ok) {
                      TrashActions.showMoved(context, provider, name: box.name, boxId: box.id);
                    } else {
                      AppFeedback.showError(context, context.l10n.couldNotDeletePleaseTry2(box.name));
                    }
                  }
                },
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: context.l10n.commonDelete,
              ),
            ],
          ),
          child: Material(
            color: context.colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: context.colors.border, width: 1.0),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BoxDetailsScreen(boxId: box.id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: context.colors.fill,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            box.type.icon,
                            color: context.colors.textPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                box.name,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${box.type.displayName} • $itemCount ${itemCount == 1 ? 'item' : 'items'}${subBoxCount > 0 ? ' • $subBoxCount nested' : ''}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.colors.fill,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: context.colors.textPrimary,
                            size: 16,
                          ),
                        ),
                      ],
                    ),

                    // Full Breadcrumb Row without truncation
                    if (box.parentId != null && breadcrumbList.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.colors.fill,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Icon(Icons.route_outlined, size: 14, color: context.colors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                context.l10n.commonPath,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                              for (int i = 0; i < breadcrumbList.length; i++) ...[
                                if (i > 0)
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      size: 14,
                                      color: context.colors.textMuted,
                                    ),
                                  ),
                                Text(
                                  breadcrumbList[i].name,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: i == breadcrumbList.length - 1 ? FontWeight.w600 : FontWeight.w400,
                                    color: i == breadcrumbList.length - 1 ? context.colors.textPrimary : context.colors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildEmptyState({required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 56, color: context.colors.textMuted),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }


  Widget _buildFilterChip(int index, String label) {
    final isSelected = _filterIndex == index;

    return Tappable(
      onTap: () => _update(() => _filterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? context.colors.primary : context.colors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : context.colors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
