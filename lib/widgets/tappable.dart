import 'package:flutter/material.dart';

/// A tappable area that screen readers announce as a button.
///
/// Use instead of a bare `GestureDetector` for anything the user taps.
/// [semanticLabel] is needed for icon-only content; text children are read as is.
class Tappable extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final HitTestBehavior? behavior;
  final String? semanticLabel;
  final Widget? child;

  const Tappable({
    super.key,
    this.onTap,
    this.onLongPress,
    this.behavior,
    this.semanticLabel,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: onTap != null,
        label: semanticLabel,
        child: GestureDetector(
          behavior: behavior,
          onTap: onTap,
          onLongPress: onLongPress,
          child: child,
        ),
      ),
    );
  }
}
