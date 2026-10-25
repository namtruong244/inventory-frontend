import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';

/// Pull-to-refresh for a scrollable: pushes queued offline changes, then reloads.
class AppRefresh extends StatelessWidget {
  final Widget child;
  const AppRefresh({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    return RefreshIndicator(
      onRefresh: provider.fetchAllData,
      color: Theme.of(context).colorScheme.primary,
      child: child,
    );
  }
}
