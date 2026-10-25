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
                label: 'Move',
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
                backgroundColor: const Color(0xFF18181B),
                foregroundColor: Colors.white,
                icon: Icons.edit_outlined,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: (_) async {
                  final confirmed = await AppFeedback.showConfirmDialog(
                    context,
                    title: 'Delete Location',
                    message: 'Are you sure you want to delete "${box.name}"? All nested containers and items inside will also be deleted.',
                    confirmLabel: 'Delete Box',
                    isDestructive: true,
                    icon: Icons.delete_outline,
                  );
                  if (confirmed && mounted) {
                    final ok = await provider.deleteBox(box.id, cascade: true);
                    if (!mounted) return;
                    if (ok) {
                      AppFeedback.showSuccess(context, 'Location "${box.name}" deleted successfully');
                    } else {
                      AppFeedback.showError(context, 'Could not delete "${box.name}". Please try again.');
                    }
                  }
                },
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: 'Delete',
              ),
            ],
          ),
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFE4E4E7), width: 1.0),
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
                            color: const Color(0xFFF4F4F5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            box.type.icon,
                            color: const Color(0xFF18181B),
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
                                  color: const Color(0xFF18181B),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${box.type.displayName} • $itemCount ${itemCount == 1 ? 'item' : 'items'}${subBoxCount > 0 ? ' • $subBoxCount nested' : ''}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF71717A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF4F4F5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF18181B),
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
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE4E4E7)),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Icon(Icons.route_outlined, size: 14, color: Color(0xFF71717A)),
                              const SizedBox(width: 6),
                              Text(
                                'Path: ',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF71717A),
                                ),
                              ),
                              for (int i = 0; i < breadcrumbList.length; i++) ...[
                                if (i > 0)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      size: 14,
                                      color: Color(0xFFA1A1AA),
                                    ),
                                  ),
                                Text(
                                  breadcrumbList[i].name,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: i == breadcrumbList.length - 1 ? FontWeight.w600 : FontWeight.w400,
                                    color: i == breadcrumbList.length - 1 ? const Color(0xFF18181B) : const Color(0xFF52525B),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: const Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF71717A)),
          ),
        ],
      ),
    );
  }


  Widget _buildFilterChip(int index, String label) {
    final isSelected = _filterIndex == index;

    return GestureDetector(
      onTap: () => _update(() => _filterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF18181B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF18181B) : const Color(0xFFE4E4E7),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : const Color(0xFF27272A),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
