import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../screens/box_details_screen.dart';

import 'home_sections.dart';
import 'tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';

extension HomeStorageSection on HomeSections {

  Widget buildStorageSpacesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: "Storage Spaces" & "View all"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                context.l10n.storageSpaces,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Tappable(
                onTap: () => selectTab(1), // Go to Box tab
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

        // Horizontal Storage Spaces Carousel
        SizedBox(
          height: 232,
          child: Consumer<InventoryProvider>(
            builder: (context, provider, _) {
              final boxes = provider.boxes;
              if (boxes.isEmpty) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.colors.fill,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon(
                          Icons.inventory_2_outlined,
                          size: 36,
                          color: context.colors.textMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.noStorageSpacesYet,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: boxes.length,
                itemBuilder: (context, index) {
                  final box = boxes[index];
                  final itemCount = provider.countTotalItemsIn(box.id);
                  final subBoxCount = provider.getBoxesIn(box.id).length;

                  return buildStorageSpaceCard(
                    box: box,
                    itemCount: itemCount,
                    subBoxCount: subBoxCount,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }


  Widget buildStorageSpaceCard({
    required Box box,
    required int itemCount,
    required int subBoxCount,
  }) {
    IconData boxIcon;
    final nameLower = box.name.toLowerCase();
    if (nameLower.contains('game')) {
      boxIcon = Icons.sports_esports_outlined;
    } else if (nameLower.contains('elec') ||
        nameLower.contains('tech') ||
        nameLower.contains('gadget')) {
      boxIcon = Icons.devices_outlined;
    } else if (nameLower.contains('cloth') || nameLower.contains('wardrobe')) {
      boxIcon = Icons.checkroom_outlined;
    } else if (nameLower.contains('tool') ||
        nameLower.contains('garage') ||
        nameLower.contains('hardware')) {
      boxIcon = Icons.handyman_outlined;
    } else if (nameLower.contains('kitchen') ||
        nameLower.contains('pantry') ||
        nameLower.contains('food')) {
      boxIcon = Icons.restaurant_outlined;
    } else if (nameLower.contains('book') ||
        nameLower.contains('doc') ||
        nameLower.contains('office')) {
      boxIcon = Icons.menu_book_outlined;
    } else {
      boxIcon = box.type.icon;
    }

    return Tappable(
      onTap: () => navigate(BoxDetailsScreen(boxId: box.id)),
      child: Container(
        width: 215,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: context.colors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon circle + Storage Type pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.colors.accent.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    boxIcon,
                    color: context.colors.textPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.fill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      box.type.displayName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              box.name,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Description / Location
            Text(
              box.description.isNotEmpty
                  ? box.description
                  : (box.parentId != null
                        ? context.l10n.subContainerInLocation
                        : context.l10n.primaryStorageSpace),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Bottom Row: Item count & Nested containers badge + Arrow button
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.fill,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          Icons.inventory_2_outlined,
                          size: 13,
                          color: context.colors.textPrimary,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '${context.l10n.itemsCountLabel(itemCount)}${subBoxCount > 0 ? " • ${context.l10n.nestedCountLabel(subBoxCount)}" : ""}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.colors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: context.colors.onAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
