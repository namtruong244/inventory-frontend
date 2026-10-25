import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../screens/login_screen.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Sends the user to the sign-in screen once when the server rejects the session
/// (expired or revoked token). Queued offline changes stay on the device.
class SessionGuard extends StatefulWidget {
  final Widget child;
  const SessionGuard({super.key, required this.child});

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    final expired = context.select<InventoryProvider, bool>(
      (p) => p.sessionExpired,
    );
    if (!expired) {
      _handled = false;
    } else if (!_handled) {
      _handled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appNavigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      });
    }
    return widget.child;
  }
}
