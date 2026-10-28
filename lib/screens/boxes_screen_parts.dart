part of 'boxes_screen.dart';

/// Box card, empty state and filter chip builders.
extension _BoxesScreenParts on _BoxesScreenState {

  Widget _roundAction({
    required String tooltip,
    required IconData icon,
    required VoidCallback? onTap,
    bool accent = false,
  }) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Tappable(
        semanticLabel: tooltip,
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: accent ? c.accent : c.surface,
            shape: BoxShape.circle,
            boxShadow: accent ? null : c.cardShadow,
          ),
          child: AppIcon(
            icon,
            size: 22,
            color: onTap == null ? c.textMuted : (accent ? c.onAccent : c.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildFlatBoxCard(Box box, InventoryProvider provider) {
    final itemCount = provider.countTotalItemsIn(box.id);
    final subBoxCount = provider.getBoxesIn(box.id).length;
    final breadcrumbList = provider.getBreadcrumb(box.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SoftCard(
        child: Slidable(
          key: ValueKey(box.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.65,
            children: [
              SlidableAction(
                onPressed: (_) => MoveLocationDialog.show(context, box),
                backgroundColor: AppTones.slate,
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
                backgroundColor: AppTones.coral,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: context.l10n.commonDelete,
              ),
            ],
          ),
          child: Material(
            color: context.colors.surface,
            child: InkWell(
              onLongPress: () => showBoxActionsSheet(context, box),
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
                            color: context.colors.accent.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: AppIcon(
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
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  SoftChip(
                                    label: box.type.displayName,
                                    background: context.colors.fill,
                                    foreground: context.colors.textSecondary,
                                  ),
                                  SoftChip.tone(context.l10n.itemsCountLabel(itemCount), AppTones.sky, icon: Icons.category_outlined),
                                  if (subBoxCount > 0)
                                    SoftChip.tone(context.l10n.nestedCountLabel(subBoxCount), AppTones.lilac, icon: Icons.inventory_2_outlined),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AppIcon(Icons.chevron_right_rounded, color: context.colors.textMuted, size: 24),
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
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              AppIcon(Icons.route_outlined, size: 14, color: context.colors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                context.l10n.commonPath,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                              for (int i = 0; i < breadcrumbList.length; i++) ...[
                                if (i > 0)
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                                    child: AppIcon(
                                      Icons.chevron_right_rounded,
                                      size: 14,
                                      color: context.colors.textMuted,
                                    ),
                                  ),
                                Text(
                                  breadcrumbList[i].name,
                                  style: GoogleFonts.plusJakartaSans(
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


  Widget _buildEmptyState({required String title, required String subtitle, VoidCallback? onAction, String? actionLabel}) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: context.colors.cardShadow,
      ),
      child: Column(
        children: [
          SoftIconTile(Icons.inventory_2_outlined, color: context.colors.textPrimary, background: context.colors.accent.withValues(alpha: 0.45), size: 72),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: context.colors.textSecondary),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ],
      ),
    );
  }


  Widget _buildFilterChip(int index, String label) =>
      SoftFilterChip(label: label, selected: _filterIndex == index, onTap: () => _update(() => _filterIndex = index));
}
