import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';

/// Keeps the offline queue moving without user action: syncs when the app returns to the
/// foreground and re-checks the server periodically while offline or with queued changes.
class AutoSync extends StatefulWidget {
  final Widget child;
  const AutoSync({super.key, required this.child});

  @override
  State<AutoSync> createState() => _AutoSyncState();
}

class _AutoSyncState extends State<AutoSync> {
  late final AppLifecycleListener _lifecycle;
  late final InventoryProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<InventoryProvider>();
    _provider.startAutoSync();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _provider.startAutoSync();
        _provider.onAppResumed();
      },
      onPause: _provider.stopAutoSync,
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _provider.stopAutoSync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
