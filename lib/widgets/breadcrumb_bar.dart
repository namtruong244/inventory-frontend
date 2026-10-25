import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../screens/box_details_screen.dart';

class BreadcrumbBar extends StatelessWidget {
  final String locationId;
  final bool isInteractive;
  final TextStyle? textStyle;

  const BreadcrumbBar({
    super.key,
    required this.locationId,
    this.isInteractive = true,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final path = provider.getBreadcrumb(locationId);

    if (path.length <= 1) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < path.length; i++) ...[
            _buildNode(context, path[i], isLast: i == path.length - 1),
            if (i < path.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildNode(BuildContext context, Box box, {required bool isLast}) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLast ? const Color(0xFF18181B) : const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            box.type.icon,
            size: 13,
            color: isLast ? Colors.white : const Color(0xFF18181B),
          ),
          const SizedBox(width: 5),
          Text(
            box.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
              color: isLast ? Colors.white : const Color(0xFF18181B),
            ),
          ),
        ],
      ),
    );

    if (!isInteractive || isLast) {
      return child;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BoxDetailsScreen(boxId: box.id),
          ),
        );
      },
      child: child,
    );
  }
}
