import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';

class MoveLocationDialog extends StatefulWidget {
  final Box targetBox;

  const MoveLocationDialog({super.key, required this.targetBox});

  static Future<bool?> show(BuildContext context, Box box) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MoveLocationDialog(targetBox: box),
    );
  }

  @override
  State<MoveLocationDialog> createState() => _MoveLocationDialogState();
}

class _MoveLocationDialogState extends State<MoveLocationDialog> {
  String? _selectedParentId;

  @override
  void initState() {
    super.initState();
    _selectedParentId = widget.targetBox.parentId;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final theme = Theme.of(context);

    // List of candidate parent locations
    final allBoxes = provider.boxes;
    final totalItems = provider.countTotalItemsIn(widget.targetBox.id);
    final totalSubBoxes = provider.getBoxesIn(widget.targetBox.id).length;

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title & Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bulk Move Location',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Move "${widget.targetBox.name}" and contents',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bulk Move Warning Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: Color(0xFF18181B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All $totalItems items and $totalSubBoxes nested containers inside will move along with this container.',
                    style: const TextStyle(fontSize: 12, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Select Destination',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 8),

          // Options List
          Expanded(
            child: ListView(
              children: [
                // Option: Make Root Location (No parent)
                _buildDestinationOption(
                  id: null,
                  name: 'Root Level (No Parent Container)',
                  type: StorageType.room,
                  breadcrumb: 'Top of hierarchy',
                  isSelected: _selectedParentId == null,
                  isEnabled: widget.targetBox.parentId != null,
                ),

                const Divider(height: 20),

                // All candidate containers
                ...allBoxes.map((box) {
                  final canMove = provider.canMoveLocation(widget.targetBox.id, box.id);
                  final isCurrentParent = widget.targetBox.parentId == box.id;
                  final breadcrumb = provider.getBreadcrumbString(box.id);

                  return _buildDestinationOption(
                    id: box.id,
                    name: box.name,
                    type: box.type,
                    breadcrumb: breadcrumb,
                    isSelected: _selectedParentId == box.id,
                    isEnabled: canMove && !isCurrentParent,
                    disabledReason: box.id == widget.targetBox.id
                        ? '(Current container)'
                        : !canMove
                            ? '(Nested child container)'
                            : isCurrentParent
                                ? '(Already current parent)'
                                : null,
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _selectedParentId == widget.targetBox.parentId
                  ? null
                  : () {
                      final success = provider.bulkMoveLocation(
                        widget.targetBox.id,
                        _selectedParentId,
                      );
                      if (success) {
                        Navigator.pop(context, true);
                        AppFeedback.showSuccess(
                          context,
                          'Moved "${widget.targetBox.name}" successfully',
                        );
                      } else {
                        AppFeedback.showError(
                          context,
                          'Cannot move container into its own descendant',
                        );
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF18181B),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Confirm Move',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
        ),
      ),
    ),
  );
}

  Widget _buildDestinationOption({
    required String? id,
    required String name,
    required StorageType type,
    required String breadcrumb,
    required bool isSelected,
    required bool isEnabled,
    String? disabledReason,
  }) {
    return ListTile(
      enabled: isEnabled,
      onTap: isEnabled ? () => setState(() => _selectedParentId = id) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF18181B) : const Color(0xFFF4F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          type.icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.grey.shade700,
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isEnabled ? const Color(0xFF18181B) : Colors.grey.shade400,
        ),
      ),
      subtitle: Text(
        disabledReason ?? breadcrumb,
        style: TextStyle(
          fontSize: 11,
          color: disabledReason != null ? Colors.red.shade400 : Colors.grey.shade500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF18181B))
          : null,
    );
  }
}
