import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/theme/app_theme.dart';

double _luminance(Color c) {
  double channel(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  final hi = math.max(la, lb), lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final brightness in Brightness.values) {
    test('secondary and muted text meet WCAG AA on every surface (${brightness.name})', () {
      final c = buildAppTheme(brightness).extension<AppColors>()!;
      for (final surface in {'background': c.background, 'surface': c.surface, 'fill': c.fill}.entries) {
        for (final text in {'textPrimary': c.textPrimary, 'textSecondary': c.textSecondary, 'textMuted': c.textMuted}.entries) {
          expect(
            contrast(text.value, surface.value),
            greaterThanOrEqualTo(4.5),
            reason: '${text.key} on ${surface.key} in ${brightness.name}',
          );
        }
      }
    });
  }
}
