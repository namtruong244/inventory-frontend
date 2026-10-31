import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../screens/box_create_screen.dart';
import '../screens/qr_display_screen.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_feedback.dart';
import 'app_icon.dart';
import 'box_tree.dart' show boxTypeTone;
import 'export_barcodes_sheet.dart';
import 'move_location_dialog.dart';
import 'soft_sheet.dart';
import 'soft_ui.dart';
import 'tappable.dart';
import 'thermal_label_sheet.dart';
import 'trash_actions.dart';

/// Type tile + type caption + name + description + "Show QR" button.
class BoxDetailsHeader extends StatelessWidget {
  final Box box;
  final VoidCallback onShowQr;

  const BoxDetailsHeader({
    super.key,
    required this.box,
    required this.onShowQr,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = boxTypeTone(box.type);
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: tone.bg,
            borderRadius: BorderRadius.circular(22),
          ),
          child: AppIcon(box.type.icon, size: 30, color: tone.fg),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                box.type.displayName.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                box.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: c.textPrimary,
                ),
              ),
              if (box.description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  box.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        e2eId(
          'box_qr',
          Tappable(
            semanticLabel: context.l10n.showQrCode,
            onTap: onShowQr,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: c.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const AppIcon(
                Icons.qr_code_2_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Three-column summary card: items, containers, expiring.
class BoxSummaryCard extends StatelessWidget {
  final int items;
  final int containers;
  final int expiring;

  const BoxSummaryCard({
    super.key,
    required this.items,
    required this.containers,
    required this.expiring,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    Widget cell(int value, String label, {Color? color}) => Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color ?? c.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
    Widget sep() => Container(width: 1, height: 36, color: c.border);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: c.cardShadow,
      ),
      child: Row(
        children: [
          cell(items, l10n.statItems),
          sep(),
          cell(containers, l10n.commonContainers),
          sep(),
          cell(
            expiring,
            l10n.statExpiring,
            color: expiring > 0 ? c.warningStrong : null,
          ),
        ],
      ),
    );
  }
}

/// "Add item" (accent) + "Add container" (white) buttons.
class BoxQuickActions extends StatelessWidget {
  final VoidCallback onAddItem;
  final VoidCallback onAddContainer;

  const BoxQuickActions({
    super.key,
    required this.onAddItem,
    required this.onAddContainer,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Expanded(
          child: e2eId(
            'box_add_item',
            SoftButton(
              label: context.l10n.addItem,
              icon: Icons.add_rounded,
              expand: true,
              onPressed: onAddItem,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: e2eId(
            'box_add_child',
            Tappable(
              semanticLabel: context.l10n.addContainer,
              onTap: onAddContainer,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: c.cardShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcon(
                      Icons.create_new_folder_outlined,
                      size: 18,
                      color: c.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        context.l10n.addContainer,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String id;
  final IconData icon;
  final String label;
  final bool danger;
  final VoidCallback onTap;

  const _OptionRow({
    required this.id,
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = danger ? c.dangerStrong : c.textPrimary;
    return e2eId(
      id,
      Tappable(
        semanticLabel: label,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          height: 52,
          decoration: BoxDecoration(
            color: danger ? c.dangerSoft : c.fill,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              AppIcon(icon, size: 20, color: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Options bottom sheet for a box: edit, move, thermal label, full QR, delete.
void showBoxOptionsSheet(
  BuildContext context,
  Box box,
  InventoryProvider provider,
) {
  final l10n = context.l10n;
  showSoftSheet<void>(
    context,
    title: box.name,
    subtitle: box.type.displayName,
    builder: (sheetContext) {
      void close() => Navigator.pop(sheetContext);
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OptionRow(
              id: 'box_menu_edit',
              icon: Icons.edit_outlined,
              label: l10n.editLocation,
              onTap: () {
                close();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BoxCreateScreen(existingBox: box),
                  ),
                );
              },
            ),
            _OptionRow(
              id: 'box_menu_move',
              icon: Icons.drive_file_move_outlined,
              label: l10n.moveLocation,
              onTap: () {
                close();
                MoveLocationDialog.show(context, box);
              },
            ),
            _OptionRow(
              id: 'box_menu_label',
              icon: Icons.print_outlined,
              label: l10n.printThermalLabel,
              onTap: () {
                close();
                ThermalLabelSheet.show(context, box);
              },
            ),
            _OptionRow(
              id: 'box_menu_qr',
              icon: Icons.qr_code_rounded,
              label: l10n.viewFullQrCode,
              onTap: () {
                close();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QRDisplayScreen(box: box)),
                );
              },
            ),
            _OptionRow(
              id: 'box_menu_export',
              icon: Icons.ios_share_rounded,
              label: l10n.exportBarcodes,
              onTap: () {
                close();
                ExportBarcodesSheet.show(context, box.id);
              },
            ),
            _OptionRow(
              id: 'box_menu_delete',
              icon: Icons.delete_outline_rounded,
              label: l10n.deleteLocation,
              danger: true,
              onTap: () async {
                close();
                final confirmed = await TrashActions.confirm(
                  context,
                  name: box.name,
                  isBox: true,
                  hasContents: true,
                );
                if (confirmed && context.mounted) {
                  final boxName = box.name;
                  final ok = await provider.deleteBox(box.id, cascade: true);
                  if (!context.mounted) return;
                  if (ok) {
                    Navigator.pop(context);
                    TrashActions.showMoved(
                      context,
                      provider,
                      name: boxName,
                      boxId: box.id,
                    );
                  } else {
                    AppFeedback.showError(
                      context,
                      l10n.couldNotDeletePleaseTry(boxName),
                    );
                  }
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
