import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';
import 'app_image_view.dart';
import 'item_detail_cards.dart';
import 'tappable.dart';

/// Photo carousel (or a placeholder) at the top of the item detail page.
/// The back / "more" buttons are drawn by the screen on top of it.
class ItemHeroHeader extends StatefulWidget {
  final Item item;

  const ItemHeroHeader({super.key, required this.item});

  @override
  State<ItemHeroHeader> createState() => _ItemHeroHeaderState();
}

class _ItemHeroHeaderState extends State<ItemHeroHeader> {
  int _index = 0;
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final photos = widget.item.photos;
    if (photos.isEmpty) {
      return Container(
        height: 240,
        color: c.fill,
        alignment: Alignment.center,
        child: AppIcon(
          CategoryHelper.getCategoryIcon(widget.item.categoryId),
          size: 72,
          color: c.textMuted,
        ),
      );
    }
    return SizedBox(
      height: 330,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: photos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Tappable(
              semanticLabel: context.l10n.productPhotos,
              onTap: () => showFullScreenImage(context, photos[i]),
              child: AppImageView(
                imageUrlOrPath: photos[i],
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: c.fill,
                  child: Center(
                    child: AppIcon(
                      Icons.broken_image_outlined,
                      color: c.textMuted,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (photos.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < photos.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _index == i ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: _index == i ? 1 : 0.55,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
