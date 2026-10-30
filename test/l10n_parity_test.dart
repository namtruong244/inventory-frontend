import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/l10n/app_localizations.dart';
import 'package:inventory/theme/app_theme.dart';

Map<String, dynamic> _arb(String l) =>
    jsonDecode(File('lib/l10n/app_$l.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _ph(String s) =>
    RegExp(r'\{(\w+)\}').allMatches(s).map((m) => m.group(1)!).toSet();

void main() {
  test('en and vi ARB have the same keys and placeholders', () {
    final en = _arb('en'), vi = _arb('vi');
    final enKeys = en.keys.where((k) => !k.startsWith('@')).toSet();
    final viKeys = vi.keys.where((k) => !k.startsWith('@')).toSet();
    expect(viKeys.difference(enKeys), isEmpty, reason: 'extra vi keys');
    expect(enKeys.difference(viKeys), isEmpty, reason: 'untranslated keys');
    for (final k in enKeys) {
      expect(
        _ph(vi[k] as String),
        _ph(en[k] as String),
        reason: 'placeholders of $k',
      );
    }
  });

  test('Vietnamese strings differ from English for core labels', () {
    final vi = lookupAppLocalizations(const Locale('vi'));
    final en = lookupAppLocalizations(const Locale('en'));
    expect(vi.commonCancel, isNot(en.commonCancel));
    expect(vi.statusStored, 'Đang cất');
  });

  test('dark theme exposes AppColors distinct from light', () {
    final light = buildAppTheme(Brightness.light).extension<AppColors>()!;
    final dark = buildAppTheme(Brightness.dark).extension<AppColors>()!;
    expect(dark.background, isNot(light.background));
    expect(dark.textPrimary, isNot(light.textPrimary));
  });
}
