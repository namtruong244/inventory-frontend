import 'package:flutter/material.dart';

import '../utils/e2e.dart';

import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/trash_actions.dart';
import '../widgets/box_card.dart';
import '../widgets/box_details_parts.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/soft_ui.dart';
import '../widgets/item_card.dart';
import 'box_create_screen.dart';
import 'item_create_screen.dart';
import 'item_details_screen.dart';
import 'qr_display_screen.dart';
import '../widgets/app_refresh.dart';
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
            appBar: SoftTopAppBar(title: ''),
            body: Center(child: Text(context.l10n.locationNotFound)),
          );
        }

        final c = context.colors;
        final subBoxes = provider.getBoxesIn(box.id);
        final items = provider.getItemsIn(box.id);
        final totalItemsRecursive = provider.countTotalItemsIn(box.id);
        final expiring = items
            .where(
              (i) =>
                  i.isExpired ||
                  (i.daysUntilExpiry != null && i.daysUntilExpiry! <= 30),
            )
            .length;

        return Scaffold(
          backgroundColor: c.background,
          appBar: SoftTopAppBar(
            title: '',
            actions: [
              e2eId(
                'box_options',
                SoftCircleButton(
                  icon: Icons.more_horiz_rounded,
                  tooltip: context.l10n.moreOptions,
                  onTap: () => showBoxOptionsSheet(context, box, provider),
                ),
              ),
            ],
          ),
          body: AppRefresh(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (provider.getBreadcrumb(box.id).length > 1) ...[
                        BreadcrumbBar(locationId: box.id),
                        const SizedBox(height: 18),
                      ],
                      BoxDetailsHeader(
                        box: box,
                        onShowQr: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QRDisplayScreen(box: box),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      BoxSummaryCard(
                        items: totalItemsRecursive,
                        containers: subBoxes.length,
                        expiring: expiring,
                      ),
                      const SizedBox(height: 18),
                      BoxQuickActions(
                        onAddItem: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItemCreateScreen(boxId: box.id),
                          ),
                        ),
                        onAddContainer: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BoxCreateScreen(parentId: box.id),
                          ),
                        ),
                      ),
                      if (subBoxes.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        SoftSectionHeader(context.l10n.sectionNestedContainers),
                        const SizedBox(height: 10),
                        for (final subBox in subBoxes)
                          _buildSubBox(context, provider, subBox),
                      ],
                      const SizedBox(height: 22),
                      SoftSectionHeader(context.l10n.sectionItemsInContainer),
                      const SizedBox(height: 10),
                      if (items.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                AppIcon(
                                  Icons.inbox_outlined,
                                  size: 36,
                                  color: c.textMuted,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  context.l10n.noDirectItemsStoredHere,
                                  style: TextStyle(
                                    color: c.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        for (final item in items)
                          _buildItem(context, provider, item),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubBox(
    BuildContext context,
    InventoryProvider provider,
    Box subBox,
  ) {
    final count = provider.countTotalItemsIn(subBox.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BoxCard(
        id: 'box_card_${subBox.name}',
        name: subBox.name,
        description:
            '${subBox.type.displayName} • ${context.l10n.itemsCountLabel(count)}',
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
              TrashActions.showMoved(
                context,
                provider,
                name: subBox.name,
                boxId: subBox.id,
              );
            } else {
              AppFeedback.showError(
                context,
                context.l10n.couldNotDeletePleaseTry2(subBox.name),
              );
            }
          }
        },
        onEdit: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BoxCreateScreen(existingBox: subBox),
          ),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BoxDetailsScreen(boxId: subBox.id)),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    InventoryProvider provider,
    Item item,
  ) {
    String? expiry;
    if (item.isExpired) {
      expiry = context.l10n.tagExpired;
    } else if (item.daysUntilExpiry != null && item.daysUntilExpiry! <= 30) {
      expiry = context.l10n.expiresInShort(item.daysUntilExpiry!);
    }
    final meta = [
      if (item.purchasePrice != null) provider.formatPrice(item.purchasePrice),
      ?expiry,
    ].join(' • ');
    final desc = [
      if (item.description.isNotEmpty) item.description,
      if (meta.isNotEmpty) meta,
    ].join('\n');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ItemCard(
        id: 'item_card_${item.name}',
        name: item.name,
        description: desc,
        imageUrl: item.imageUrl,
        locationPath: provider.getBreadcrumbString(item.boxId),
        quantityText: provider.formatQty(item.quantity, item.unit),
        status: SoftChip.tone(
          item.status.displayName,
          item.status.color,
          dot: true,
        ),
        onEdit: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ItemCreateScreen(boxId: item.boxId, existingItem: item),
          ),
        ),
        onDelete: () async {
          final confirmed = await TrashActions.confirm(
            context,
            name: item.name,
          );
          if (confirmed && context.mounted) {
            final ok = await provider.deleteItem(item.id);
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
                context.l10n.couldNotDeletePleaseTry2(item.name),
              );
            }
          }
        },
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemDetailsScreen(itemId: item.id)),
        ),
      ),
    );
  }
}
