import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// A calendar date in the language the app is showing ("Oct 27, 2026" / "27 thg 10, 2026").
String formatDate(BuildContext context, DateTime date) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date);

/// The same with the long month name ("October 27, 2026").
String formatDateLong(BuildContext context, DateTime date) =>
    DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(date);
