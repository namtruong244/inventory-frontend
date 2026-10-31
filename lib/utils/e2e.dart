import 'package:flutter/material.dart';

/// True when built with `--dart-define=E2E=true`; turns off looping animations
/// so Maestro does not wait for the UI to go idle.
const bool kE2E = bool.fromEnvironment('E2E');

/// Tags [child] with a stable id that Maestro selects with `id:`.
///
/// Text differs between vi/en, so E2E flows never match on text.
Widget e2eId(String id, Widget child) =>
    Semantics(identifier: id, child: child);
