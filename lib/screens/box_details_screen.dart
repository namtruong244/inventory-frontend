import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/trash_actions.dart';
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
import '../widgets/app_refresh.dart';
import '../widgets/tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

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
            body: Center(child: Text(context.l10n.locationNotFound)),
          );
        }

        final subBoxes = provider.getBoxesIn(box.id);
        final items = provider.getItemsIn(box.id);
        final totalItemsRecursive = provider.countTotalItemsIn(box.id);
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: context.colors.background,
          body: AppRefresh(child: CustomScrollView(
 physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar.large(
                backgroundColor: context.colors.fill,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
 tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.colors.border),
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
                      tooltip: context.l10n.exportBarcodes,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.colors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(Icons.qr_code_2_rounded, size: 20, color: context.colors.textPrimary),
                      ),
                      onPressed: () => ExportBarcodesSheet.show(context, box.id),
                    ),
                  ),
                  // 2. More Options Menu
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      tooltip: context.l10n.moreOptions,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.colors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(Icons.more_horiz_rounded, size: 20, color: context.colors.textPrimary),
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
                          color: context.colors.surface,
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
                                color: context.colors.primary,
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
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: context.colors.textPrimary,
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
                                            color: context.colors.fill,
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
                                    style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
 tooltip: context.l10n.showQrCode,
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
                          context.l10n.commonOverview,
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
                            context.l10n.nestedContainers(subBoxes.length),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Tappable(
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
                                  context.l10n.addContainer,
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
                                color: context.colors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: context.colors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_circle_outline_rounded, size: 18, color: context.colors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.l10n.addContainerInside,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: context.colors.textPrimary,
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
                                final confirmed = await TrashActions.confirm(
                                  context,
                                  name: subBox.name,
                                  isBox: true,
                                  hasContents: true,
                                );
                                if (confirmed && context.mounted) {
                                  final ok = await provider.deleteBox(subBox.id, cascade: true);
                                  if (!context.mounted) return;
                                  if (ok) {
                                    TrashActions.showMoved(context, provider, name: subBox.name, boxId: subBox.id);
                                  } else {
                                    AppFeedback.showError(context, context.l10n.couldNotDeletePleaseTry2(subBox.name));
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
                            context.l10n.itemsInThisContainer(items.length),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Tappable(
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
                                  context.l10n.addItem,
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
                                Icon(Icons.inbox_outlined, size: 48, color: context.colors.textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  context.l10n.noDirectItemsStoredHere,
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
                                final confirmed = await TrashActions.confirm(context, name: item.name);
                                if (confirmed && context.mounted) {
                                  final ok = await provider.deleteItem(item.id);
                                  if (!context.mounted) return;
                                  if (ok) {
                                    TrashActions.showMoved(context, provider, name: item.name, itemId: item.id);
                                  } else {
                                    AppFeedback.showError(context, context.l10n.couldNotDeletePleaseTry2(item.name));
                                  }
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
          )),
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
      backgroundColor: context.colors.surface,
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
                    color: context.colors.border,
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
                        color: context.colors.fill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(box.type.icon, size: 22, color: context.colors.textPrimary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            box.name,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: context.colors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            box.type.displayName,
                            style: GoogleFonts.inter(fontSize: 13, color: context.colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: context.colors.border),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: context.colors.textPrimary),
                title: Text(context.l10n.editLocation, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
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
                leading: Icon(Icons.drive_file_move_outlined, color: context.colors.textPrimary),
                title: Text(context.l10n.moveLocation, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  MoveLocationDialog.show(context, box);
                },
              ),
              ListTile(
                leading: Icon(Icons.print_outlined, color: context.colors.textPrimary),
                title: Text(context.l10n.printThermalLabel, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  ThermalLabelSheet.show(context, box);
                },
              ),
              ListTile(
                leading: Icon(Icons.qr_code_rounded, color: context.colors.textPrimary),
                title: Text(context.l10n.viewFullQrCode, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
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
              Divider(color: context.colors.border),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                title: Text(
                  context.l10n.deleteLocation,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFFDC2626)),
                ),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);
                  final confirmed = await TrashActions.confirm(
                    context,
                    name: box.name,
                    isBox: true,
                    hasContents: true,
                  );
                  if (confirmed && context.mounted) {
                    final boxName = box.name;
                    final ok = await provider.deleteBox(box.id, cascade: true);
                    if (!context.mounted) return;
                    if (ok) {
                      Navigator.pop(context);
                      TrashActions.showMoved(context, provider, name: boxName, boxId: box.id);
                    } else {
                      AppFeedback.showError(context, context.l10n.couldNotDeletePleaseTry(boxName));
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
