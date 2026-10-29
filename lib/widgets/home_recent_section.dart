import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_image_view.dart';
import '../screens/item_details_screen.dart';

import 'add_item_flow.dart';
import 'home_sections.dart';
import 'tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';

extension HomeRecentSection on HomeSections {
  Widget buildRecentItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: "Recent Items" & "View all"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                context.l10n.recentItems,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Tappable(
                onTap: () => selectTab(2), // Go to Item tab
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.viewAll,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    AppIcon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: context.colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Vertical Item Cards
        Consumer<InventoryProvider>(
          builder: (context, provider, _) {
            final items = provider.items;
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: context.colors.cardShadow,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        AppIcon(
                          Icons.inventory_2_outlined,
                          size: 36,
                          color: context.colors.textMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.noItemsInInventoryYet,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.tapToAddYourFirst,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textMuted,
                          ),
                        ),
                        if (provider.boxes.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          FilledButton.tonal(
                            onPressed: () => startAddItemFlow(context),
                            child: Text(context.l10n.addFirstItem),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }

            // Show recent items (up to 6)
            final recentItems = items.reversed.take(6).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: recentItems.length,
              itemBuilder: (context, index) {
                final item = recentItems[index];
                final parentBox = provider.getBoxById(item.boxId);

                return buildRecentItemRowCard(
                  item: item,
                  boxName: parentBox?.name ?? context.l10n.storageBox,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget buildRecentItemRowCard({required Item item, required String boxName}) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final qtyText = provider.formatQty(item.quantity, item.unit);

    return Tappable(
      onTap: () => navigate(ItemDetailsScreen(itemId: item.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: context.colors.cardShadow,
        ),
        child: Row(
          children: [
            // Item Visual (Image or Category Icon)
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              AppImageView(
                imageUrlOrPath: item.imageUrl!,
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(14),
                fit: BoxFit.cover,
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.fill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: AppIcon(
                  CategoryHelper.getCategoryIcon(item.categoryId),
                  color: context.colors.textPrimary,
                  size: 22,
                ),
              ),
            const SizedBox(width: 14),

            // Item Content: Name, Storage Box & Category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppIcon(
                        Icons.inventory_2_outlined,
                        size: 13,
                        color: context.colors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          boxName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          '•',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textMuted,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          item.categoryId,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Trailing: Quantity & Status Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  qtyText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (item.isLowStock ? AppTones.amber : item.status.color)
                            .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.isLowStock
                        ? context.l10n.settingsLowStock
                        : item.status.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: item.isLowStock
                          ? AppTones.amber
                          : item.status.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            AppIcon(
              Icons.chevron_right_rounded,
              size: 20,
              color: context.colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
