import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../providers/inventory_provider.dart';
import '../screens/item_details_screen.dart';
import '../theme/app_theme.dart';
import 'add_item_flow.dart';
import 'empty_state_card.dart';
import 'home_sections.dart';
import 'item_card.dart';
import 'soft_ui.dart';
import 'state_views.dart';

extension HomeRecentSection on HomeSections {
  /// "Recent items" header plus up to 6 newest items as [ItemCard]s.
  Widget buildRecentItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SoftSectionHeader(
          context.l10n.recentItems,
          actionLabel: context.l10n.viewAll,
          onAction: () => selectTab(2, reset: true),
        ),
        const SizedBox(height: 16),
        Consumer<InventoryProvider>(
          builder: (context, provider, _) {
            final items = provider.items;
            if (items.isEmpty) {
              if (provider.isLoading || provider.isSyncing) {
                return const SkeletonList(count: 3);
              }
              return EmptyStateCard(
                icon: Icons.inventory_2_outlined,
                title: context.l10n.noItemsInInventoryYet,
                subtitle: context.l10n.tapToAddYourFirst,
                actionLabel: provider.boxes.isNotEmpty
                    ? context.l10n.addFirstItem
                    : null,
                onAction: provider.boxes.isNotEmpty
                    ? () => startAddItemFlow(context)
                    : null,
              );
            }
            final recent = items.reversed.take(6).toList();
            return Column(
              children: [
                for (final item in recent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ItemCard(
                      name: item.name,
                      description: '',
                      locationPath: provider.getBreadcrumbString(item.boxId),
                      quantityText: provider.formatQty(
                        item.quantity,
                        item.unit,
                      ),
                      imageUrl: item.imageUrl,
                      status: SoftChip.tone(
                        item.status.displayName,
                        item.status.color,
                        dot: true,
                      ),
                      tags: [
                        if (item.isLowStock)
                          SoftChip.tone(
                            context.l10n.tagLowStock,
                            AppTones.amber,
                            icon: Icons.production_quantity_limits_rounded,
                          ),
                        if (item.isExpired)
                          SoftChip.tone(
                            context.l10n.tagExpired,
                            AppTones.coral,
                            icon: Icons.event_busy_outlined,
                          )
                        else if (item.daysUntilExpiry != null &&
                            item.daysUntilExpiry! <= 30)
                          SoftChip.tone(
                            context.l10n.expiresInShort(item.daysUntilExpiry!),
                            AppTones.amber,
                            icon: Icons.event_outlined,
                          ),
                      ],
                      stockRatio: item.stockRatio,
                      stockColor: item.isLowStock
                          ? AppTones.amber
                          : context.colors.successStrong,
                      onTap: () => navigate(ItemDetailsScreen(itemId: item.id)),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
