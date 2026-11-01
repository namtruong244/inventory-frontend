import 'package:flutter/material.dart';

import '../models/inventory_models.dart';
import 'storage_actions_sheet.dart';

/// The same menu for a location; see [showStorageActionsSheet].
Future<void> showBoxActionsSheet(BuildContext context, Box box) =>
    showStorageActionsSheet(context, box);
