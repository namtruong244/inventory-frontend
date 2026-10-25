import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// The strings of the language currently shown, for code that has no [BuildContext]
/// (providers, models, error mapping). Kept in sync by `MaterialApp.builder`.
class AppL10n {
  AppL10n._();

  static AppLocalizations current = lookupAppLocalizations(const Locale('en'));

  static void sync(BuildContext context) {
    current = AppLocalizations.of(context);
  }
}
