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
import '../widgets/app_icon.dart';

/// The box screens currently on the navigator, by box id. A breadcrumb uses it to go back
/// to a screen that is already open instead of stacking a second copy on top.
class OpenBoxRoutes {
  OpenBoxRoutes._();
  static final Map<String, List<Route<dynamic>>> _routes = {};

  /// The newest open route showing [boxId], if any.
  static Route<dynamic>? of(String boxId) {
    final list = _routes[boxId];
    return list == null || list.isEmpty ? null : list.last;
  }

  static void _add(String boxId, Route<dynamic> route) =>
      (_routes[boxId] ??= []).add(route);

  static void _remove(String boxId, Route<dynamic> route) {
    _routes[boxId]?.remove(route);
    if (_routes[boxId]?.isEmpty ?? false) _routes.remove(boxId);
  }
}

class _OpenBoxRoute extends StatefulWidget {
  final String boxId;
  final Widget child;
  const _OpenBoxRoute({required this.boxId, required this.child});

  @override
  State<_OpenBoxRoute> createState() => _OpenBoxRouteState();
}

class _OpenBoxRouteState extends State<_OpenBoxRoute> {
  Route<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_route == null) {
      _route = ModalRoute.of(context);
      if (_route != null) OpenBoxRoutes._add(widget.boxId, _route!);
    }
  }

  @override
  void dispose() {
    if (_route != null) OpenBoxRoutes._remove(widget.boxId, _route!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class BoxDetailsScreen extends StatelessWidget {
  final String boxId;

  const BoxDetailsScreen({super.key, required this.boxId});

  @override
  Widget build(BuildContext context) {
    return _OpenBoxRoute(boxId: boxId, child: _buildScreen(context));
  }

  Widget _buildScreen(BuildContext context) {
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
          body: AppRefresh(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: context.colors.background,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: false,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      tooltip: MaterialLocalizations.of(context)
                          .backButtonTooltip,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          shape: BoxShape.circle,
                          boxShadow: context.colors.cardShadow,
                        ),
                        child: AppIcon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
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
                            boxShadow: context.colors.cardShadow,
                          ),
                          child: AppIcon(
                            Icons.qr_code_2_rounded,
                            size: 20,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        onPressed: () =>
                            ExportBarcodesSheet.show(context, box.id),
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
                            boxShadow: context.colors.cardShadow,
                          ),
                          child: AppIcon(
                            Icons.more_horiz_rounded,
                            size: 20,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        onPressed: () =>
                            _showBoxOptionsMenu(context, box, provider),
                      ),
                    ),
                  ],
                  title: Text(
                    box.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: context.colors.cardShadow,
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
                                child: AppIcon(
                                  box.type.icon,
                                  color: Colors.white,
                                  size: 24,
                                ),
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
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: context.colors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (!box.label.startsWith('loc_') &&
                                            box.label.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: context.colors.fill,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              box.label,
                                              style: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.l10n.boxSummary(totalItemsRecursive, subBoxes.length),
                                      style: TextStyle(
                                        color: context.colors.textSecondary,
                                        fontSize: 13,
                                      ),
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
                                icon: const AppIcon(Icons.qr_code, size: 24),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (box.description.isNotEmpty) ...[
                          Text(
                            context.l10n.commonOverview,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
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
                          const SizedBox(height: 20),
                        ],

                        // Nested Boxes / Containers Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.nestedContainers(subBoxes.length),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Tappable(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BoxCreateScreen(parentId: box.id),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  AppIcon(
                                    Icons.add_rounded,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.l10n.addContainer,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (subBoxes.isNotEmpty) ...[
                          ...subBoxes.map((subBox) {
                            final count = provider.countTotalItemsIn(subBox.id);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: BoxCard(
                                name: subBox.name,
                                description:
                                    '${subBox.type.displayName} • $count items',
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
                                    final ok = await provider.deleteBox(
                                      subBox.id,
                                      cascade: true,
                                    );
                                    if (!context.mounted) return;
                                    if (ok) {
                                      TrashActions.showMoved(
                                        context,
                                        provider,
                                        name: subBox.name,
                                        boxId: subBox.id,
                                      );
                                    } else {
                                      AppFeedback.showError(
                                        context,
                                        context.l10n.couldNotDeletePleaseTry2(
                                          subBox.name,
                                        ),
                                      );
                                    }
                                  }
                                },
                                onEdit: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BoxCreateScreen(existingBox: subBox),
                                    ),
                                  );
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BoxDetailsScreen(boxId: subBox.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                          const SizedBox(height: 24),
                        ] else
                          const SizedBox(height: 10),

                        // Items Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.itemsInThisContainer(items.length),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Tappable(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ItemCreateScreen(boxId: box.id),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  AppIcon(
                                    Icons.add,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.l10n.addItem,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
                              child: Column(
                                children: [
                                  AppIcon(
                                    Icons.inbox_outlined,
                                    size: 36,
                                    color: context.colors.textMuted,
                                  ),
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
                            String meta =
                                '${provider.formatQty(item.quantity, item.unit)} • ${item.status.displayName}';
                            if (item.purchasePrice != null) {
                              meta +=
                                  ' • ${provider.formatPrice(item.purchasePrice)}';
                            }
                            if (item.isExpired) {
                              meta += ' • ${context.l10n.tagExpired}';
                            } else if (item.daysUntilExpiry != null &&
                                item.daysUntilExpiry! <= 30) {
                              meta +=
                                  ' • ${context.l10n.expiresInShort(item.daysUntilExpiry!)}';
                            }

                            final fullDesc = desc.isNotEmpty
                                ? '$desc\n$meta'
                                : meta;

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
                                      builder: (_) => ItemCreateScreen(
                                        boxId: item.boxId,
                                        existingItem: item,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  final confirmed = await TrashActions.confirm(
                                    context,
                                    name: item.name,
                                  );
                                  if (confirmed && context.mounted) {
                                    final ok = await provider.deleteItem(
                                      item.id,
                                    );
                                    if (!context.mounted) return;
                                    if (ok) {
                                      TrashActions.showMoved(
                                        context,
                                        provider,
                                        name: item.name,
                                        itemId: item.id,
                                      );
                                    } else {
                                      AppFeedback.showError(
                                        context,
                                        context.l10n.couldNotDeletePleaseTry2(
                                          item.name,
                                        ),
                                      );
                                    }
                                  }
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ItemDetailsScreen(itemId: item.id),
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
          ),
        );
      },
    );
  }

  void _showBoxOptionsMenu(
    BuildContext context,
    Box box,
    InventoryProvider provider,
  ) {
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
                      child: AppIcon(
                        box.type.icon,
                        size: 22,
                        color: context.colors.textPrimary,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            box.type.displayName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: context.colors.textSecondary,
                            ),
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
                leading: AppIcon(
                  Icons.edit_outlined,
                  color: context.colors.textPrimary,
                ),
                title: Text(
                  context.l10n.editLocation,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
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
                leading: AppIcon(
                  Icons.drive_file_move_outlined,
                  color: context.colors.textPrimary,
                ),
                title: Text(
                  context.l10n.moveLocation,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  MoveLocationDialog.show(context, box);
                },
              ),
              ListTile(
                leading: AppIcon(
                  Icons.print_outlined,
                  color: context.colors.textPrimary,
                ),
                title: Text(
                  context.l10n.printThermalLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  ThermalLabelSheet.show(context, box);
                },
              ),
              ListTile(
                leading: AppIcon(
                  Icons.qr_code_rounded,
                  color: context.colors.textPrimary,
                ),
                title: Text(
                  context.l10n.viewFullQrCode,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
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
                leading: const AppIcon(
                  Icons.delete_outline_rounded,
                  color: AppTones.coral,
                ),
                title: Text(
                  context.l10n.deleteLocation,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTones.coral,
                  ),
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
                      TrashActions.showMoved(
                        context,
                        provider,
                        name: boxName,
                        boxId: box.id,
                      );
                    } else {
                      AppFeedback.showError(
                        context,
                        context.l10n.couldNotDeletePleaseTry(boxName),
                      );
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
