import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../screens/box_details_screen.dart';

import 'home_sections.dart';

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
              const Text(
                'Storage Spaces',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18181B),
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () => selectTab(1), // Go to Box tab
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: Colors.grey.shade600,
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
                    color: const Color(0xFFF4F4F6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 36,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No storage spaces yet',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
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

    return GestureDetector(
      onTap: () => navigate(BoxDetailsScreen(boxId: box.id)),
      child: Container(
        width: 215,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE4E4E7), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    boxIcon,
                    color: const Color(0xFF18181B),
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
                      color: const Color(0xFFF4F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      box.type.displayName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Color(0xFF52525B),
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
              style: const TextStyle(
                color: Color(0xFF18181B),
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
                        ? 'Sub-container in location'
                        : 'Primary storage space'),
              style: const TextStyle(
                color: Color(0xFF71717A),
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
                      color: const Color(0xFFF4F4F6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE4E4E7)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 13,
                          color: Color(0xFF18181B),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '$itemCount ${itemCount == 1 ? "item" : "items"}${subBoxCount > 0 ? " • $subBoxCount ${subBoxCount == 1 ? (box.type == StorageType.room ? "box" : "container") : (box.type == StorageType.room ? "boxes" : "containers")}" : ""}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF18181B),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFF18181B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.white,
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
