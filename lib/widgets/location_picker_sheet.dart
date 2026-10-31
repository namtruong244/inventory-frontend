import 'package:flutter/material.dart';

import '../utils/e2e.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../utils/text_normalize.dart';
import 'app_feedback.dart';
import 'box_qr_scan_sheet.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';
import 'box_tree.dart' show boxTypeTone;
import 'sheet_search_field.dart';
import 'soft_sheet.dart';
import 'soft_ui.dart';
import 'tappable.dart';

/// Reusable modal sheet to pick a storage location hierarchically
/// (Level-by-level drill down) or by scanning a box QR code directly.
/// Used in:
/// 1. Add Item Form (ItemCreateScreen) for selecting storage container
/// 2. Move Item actions (ItemDetailsScreen, ItemsScreen, BoxDetailsScreen)
part 'location_picker_parts.dart';

class LocationPickerSheet extends StatefulWidget {
  final String? initialBoxId;
  final String? title;
  final String? subtitle;
  final String? confirmButtonText;
  final String? currentBoxId;

  const LocationPickerSheet({
    super.key,
    this.initialBoxId,
    this.title,
    this.subtitle,
    this.confirmButtonText,
    this.currentBoxId,
  });

  static Future<Box?> show(
    BuildContext context, {
    String? initialBoxId,
    String? title,
    String? subtitle,
    String? confirmButtonText,
    String? currentBoxId,
  }) {
    return showModalBottomSheet<Box>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: LocationPickerSheet(
          initialBoxId: initialBoxId,
          title: title,
          subtitle: subtitle,
          confirmButtonText: confirmButtonText,
          currentBoxId: currentBoxId,
        ),
      ),
    );
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  /// setState entry point for the extension in the part file.
  void _update(VoidCallback fn) => setState(fn);

  String? _currentLevelParentId;
  String? _selectedBoxId;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedBoxId = widget.initialBoxId ?? widget.currentBoxId;

    // Start hierarchy at root
    _currentLevelParentId = null;
  }

  void _drillDown(String boxId) {
    setState(() {
      _currentLevelParentId = boxId;
    });
  }

  void _stepUp() {
    if (_currentLevelParentId == null) return;
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final currentBox = provider.getBoxById(_currentLevelParentId!);
    setState(() {
      _currentLevelParentId = currentBox?.parentId;
    });
  }

  /// Asks for a name and creates a location inside the level being browsed, then selects it.
  Future<void> _createHere() async {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(context.l10n.createLocationHere),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: context.l10n.locationNameHint,
            ),
            onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(context.l10n.commonCreate),
            ),
          ],
        );
      },
    );
    if (name == null || !mounted) return;
    if (name.isEmpty) {
      AppFeedback.showError(context, context.l10n.pleaseEnterAValidLocation);
      return;
    }
    final box = Box(
      name: name,
      type: _currentLevelParentId == null ? StorageType.room : StorageType.box,
      label: 'loc_${const Uuid().v4().substring(0, 8)}',
      parentId: _currentLevelParentId,
    );
    final ok = await provider.addBox(box);
    if (!mounted) return;
    if (ok) {
      setState(() => _selectedBoxId = box.id);
    } else {
      AppFeedback.showError(context, context.l10n.somethingWentWrongPleaseTry);
    }
  }

  void _selectBox(String boxId) {
    setState(() {
      _selectedBoxId = boxId;
    });
  }

  Future<void> _openQRScanner() async {
    final scannedBox = await showModalBottomSheet<Box>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const BoxQRScanSheet(),
    );

    if (scannedBox != null && mounted) {
      setState(() {
        _selectedBoxId = scannedBox.id;
        _currentLevelParentId = scannedBox.parentId;
      });

      // Directly select and close
      Navigator.pop(context, scannedBox);
    }
  }

  void _confirmSelection() {
    if (_selectedBoxId == null) return;
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final box = provider.getBoxById(_selectedBoxId!);
    if (box != null) {
      Navigator.pop(context, box);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final c = context.colors;

    final List<Box> visibleBoxes = _currentLevelParentId == null
        ? provider.getRootBoxes()
        : provider.getBoxesIn(_currentLevelParentId!);
    final Box? currentParentBox = _currentLevelParentId != null
        ? provider.getBoxById(_currentLevelParentId!)
        : null;
    final Box? selectedBox = _selectedBoxId != null
        ? provider.getBoxById(_selectedBoxId!)
        : null;
    final searching = _query.trim().isNotEmpty;

    final confirmLabel =
        widget.confirmButtonText ??
        (selectedBox != null
            ? context.l10n.locationUseName(selectedBox.name)
            : context.l10n.selectLocation);

    return SoftSheet(
      title: widget.title ?? context.l10n.locationPickerTitle,
      subtitle: widget.subtitle ?? context.l10n.locationPickerSubtitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          e2eId(
            'location_search',
            SheetSearchField(
              hint: context.l10n.searchLocationsRoomsContainers,
              onChanged: (v) => setState(() => _query = v),
              trailing: Tappable(
                semanticLabel: context.l10n.scanQr,
                onTap: _openQRScanner,
                child: AppIcon(
                  Icons.qr_code_scanner_rounded,
                  size: 20,
                  color: c.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (!searching && _currentLevelParentId != null) ...[
            _buildBreadcrumbBar(provider),
            const SizedBox(height: 14),
          ],
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (searching)
                    ..._searchResults(provider)
                  else ...[
                    if (currentParentBox != null) ...[
                      _buildCurrentParentCard(currentParentBox),
                      const SizedBox(height: 14),
                      Text(
                        context.l10n.locationSubKicker.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: c.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (visibleBoxes.isEmpty)
                      _buildEmptyLevel(currentParentBox)
                    else
                      _buildBoxList(visibleBoxes, provider),
                    const SizedBox(height: 12),
                    _buildCreateHere(currentParentBox),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              e2eId(
                'location_scan',
                SoftButton(
                  label: context.l10n.locationPickerScan,
                  icon: Icons.qr_code_scanner_rounded,
                  style: SoftButtonStyle.secondary,
                  onPressed: _openQRScanner,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: e2eId(
                  'location_confirm',
                  SoftButton(
                    label: confirmLabel,
                    icon: Icons.add_rounded,
                    expand: true,
                    onPressed: _selectedBoxId != null
                        ? _confirmSelection
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
