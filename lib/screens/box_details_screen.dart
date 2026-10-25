import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/box_card.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/export_barcodes_sheet.dart';
import '../widgets/item_card.dart';
import '../widgets/move_location_dialog.dart';
import '../widgets/thermal_label_sheet.dart';
import 'box_create_screen.dart';
import 'item_create_screen.dart';
import 'item_details_screen.dart';
import 'qr_display_screen.dart';

class BoxDetailsScreen extends StatelessWidget {
  final String boxId;

  const BoxDetailsScreen({super.key, required this.boxId});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final box = provider.getBoxById(boxId);

        if (box == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Location not found')),
          );
        }

        final subBoxes = provider.getBoxesIn(box.id);
        final items = provider.getItemsIn(box.id);
        final totalItemsRecursive = provider.countTotalItemsIn(box.id);
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                backgroundColor: const Color(0xFFF8F9FA),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back_ios_new, size: 18, color: theme.colorScheme.primary),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  // 1. Primary Action: Export Barcodes
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: IconButton(
                      tooltip: 'Export Barcodes',
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.qr_code_2_rounded, size: 20, color: Color(0xFF18181B)),
                      ),
                      onPressed: () => ExportBarcodesSheet.show(context, box.id),
                    ),
                  ),
                  // 2. More Options Menu
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      tooltip: 'More Options',
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.more_horiz_rounded, size: 20, color: Color(0xFF18181B)),
                      ),
                      onPressed: () => _showBoxOptionsMenu(context, box, provider),
                    ),
                  ),
                ],
                title: Text(
                  box.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Breadcrumb Bar Navigation (only shown when nested in parent)
                      if (provider.getBreadcrumb(box.id).length > 1) ...[
                        BreadcrumbBar(locationId: box.id),
                        const SizedBox(height: 16),
                      ],

                      // Location Metadata Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Type icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF18181B),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(box.type.icon, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          box.type.displayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF18181B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (!box.label.startsWith('loc_') && box.label.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4F4F6),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            box.label,
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$totalItemsRecursive ${totalItemsRecursive == 1 ? 'total item' : 'total items'} • ${subBoxes.length} nested',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QRDisplayScreen(box: box),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.qr_code, size: 24),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (box.description.isNotEmpty) ...[
                        Text(
                          'Overview',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          box.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // Nested Boxes / Containers Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nested Containers (${subBoxes.length})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BoxCreateScreen(parentId: box.id),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.add_rounded, size: 18, color: theme.colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Add Container',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (subBoxes.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BoxCreateScreen(parentId: box.id),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE4E4E7)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF71717A)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add Container Inside',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: const Color(0xFF27272A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else ...[
                        ...subBoxes.map((subBox) {
                          final count = provider.countTotalItemsIn(subBox.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: BoxCard(
                              name: subBox.name,
                              description: '${subBox.type.displayName} • $count items',
                              label: subBox.label,
                              type: subBox.type,
                              onDelete: () async {
                                final confirmed = await AppFeedback.showConfirmDialog(
                                  context,
                                  title: 'Delete Nested Box',
                                  message: 'Are you sure you want to delete box "${subBox.name}"? All items inside will also be deleted.',
                                  confirmLabel: 'Delete',
                                  isDestructive: true,
                                  icon: Icons.delete_outline,
                                );
                                if (confirmed && context.mounted) {
                                  final ok = await provider.deleteBox(subBox.id, cascade: true);
                                  if (!context.mounted) return;
                                  if (ok) {
                                    AppFeedback.showSuccess(context, 'Box "${subBox.name}" deleted successfully');
                                  } else {
                                    AppFeedback.showError(context, 'Could not delete "${subBox.name}". Please try again.');
                                  }
                                }
                              },
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BoxCreateScreen(existingBox: subBox),
                                  ),
                                );
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BoxDetailsScreen(boxId: subBox.id),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],

                      // Items Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items in this container (${items.length})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ItemCreateScreen(boxId: box.id),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.add, size: 16, color: theme.colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Add Item',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (items.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Column(
                              children: [
                                Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  'No direct items stored here',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...items.map((item) {
                          String desc = item.description;
                          String meta = '${provider.formatQty(item.quantity, item.unit)} • ${item.status.displayName}';
                          if (item.purchasePrice != null) {
                            meta += ' • ${provider.formatPrice(item.purchasePrice)}';
                          }
                          if (item.isExpired) {
                            meta += ' • EXPIRED';
                          } else if (item.daysUntilExpiry != null && item.daysUntilExpiry! <= 30) {
                            meta += ' • Expires in ${item.daysUntilExpiry}d';
                          }

                          final fullDesc = desc.isNotEmpty ? '$desc\n$meta' : meta;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: ItemCard(
                              name: item.name,
                              description: fullDesc,
                              imageUrl: item.imageUrl,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItemCreateScreen(boxId: item.boxId, existingItem: item),
                                  ),
                                );
                              },
                              onDelete: () async {
                                final confirmed = await AppFeedback.showConfirmDialog(
                                  context,
                                  title: 'Delete Item',
                                  message: 'Are you sure you want to delete item "${item.name}"? This action cannot be undone.',
                                  confirmLabel: 'Delete',
                                  isDestructive: true,
                                  icon: Icons.delete_outline,
                                );
                                if (confirmed && context.mounted) {
                                  provider.deleteItem(item.id);
                                  AppFeedback.showSuccess(context, 'Item "${item.name}" deleted successfully');
                                }
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItemDetailsScreen(itemId: item.id),
                                  ),
                                );
                              },
                            ),
                          );
                        }),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBoxOptionsMenu(BuildContext context, Box box, InventoryProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E4E7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(box.type.icon, size: 22, color: const Color(0xFF18181B)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            box.name,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(0xFF18181B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            box.type.displayName,
                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF71717A)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF4F4F5)),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Color(0xFF18181B)),
                title: Text('Edit Location', style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BoxCreateScreen(existingBox: box),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.drive_file_move_outlined, color: Color(0xFF18181B)),
                title: Text('Move Location', style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  MoveLocationDialog.show(context, box);
                },
              ),
              ListTile(
                leading: const Icon(Icons.print_outlined, color: Color(0xFF18181B)),
                title: Text('Print Thermal Label', style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  ThermalLabelSheet.show(context, box);
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_rounded, color: Color(0xFF18181B)),
                title: Text('View Full QR Code', style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QRDisplayScreen(box: box),
                    ),
                  );
                },
              ),
              const Divider(color: Color(0xFFF4F4F5)),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                title: Text(
                  'Delete Location',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFFDC2626)),
                ),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);
                  final confirmed = await AppFeedback.showConfirmDialog(
                    context,
                    title: 'Delete Location',
                    message: 'Are you sure you want to delete "${box.name}"? All nested containers and items inside will also be deleted.',
                    confirmLabel: 'Delete Box',
                    isDestructive: true,
                    icon: Icons.delete_forever_outlined,
                  );
                  if (confirmed && context.mounted) {
                    final boxName = box.name;
                    final ok = await provider.deleteBox(box.id, cascade: true);
                    if (!context.mounted) return;
                    if (ok) {
                      Navigator.pop(context);
                      AppFeedback.showSuccess(context, 'Box "$boxName" deleted successfully');
                    } else {
                      AppFeedback.showError(context, 'Could not delete "$boxName". Please try again.');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
