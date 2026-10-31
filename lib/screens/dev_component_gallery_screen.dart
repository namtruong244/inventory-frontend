// Dev-only screen (reachable when kE2E): shows every shared component in all
// of its variants for visual comparison with the design. Strings are English
// on purpose; this screen is not shipped UI.
import 'package:flutter/material.dart';

import '../models/inventory_models.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_form_field.dart';
import '../widgets/app_icon.dart';
import '../widgets/box_card.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/item_card.dart';
import '../widgets/settings_common.dart';
import '../widgets/soft_sheet.dart';
import '../widgets/soft_ui.dart';
import '../widgets/sync_status_bar.dart';

class DevComponentGalleryScreen extends StatefulWidget {
  const DevComponentGalleryScreen({super.key});

  @override
  State<DevComponentGalleryScreen> createState() =>
      _DevComponentGalleryScreenState();
}

class _DevComponentGalleryScreenState extends State<DevComponentGalleryScreen> {
  bool _toggle = true;
  String _filter = 'All';
  String _query = '';
  final _filled = TextEditingController(text: 'Bosch GSR 18V-55');
  final _error = TextEditingController(text: '');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _filled.dispose();
    _error.dispose();
    super.dispose();
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 10),
    child: Text(
      t,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: context.colors.textMuted,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return e2eId(
      'dev_gallery',
      Scaffold(
        appBar: SoftTopAppBar(
          title: 'Component gallery',
          actions: [
            SoftCircleButton(
              icon: Icons.search_rounded,
              tooltip: 'Search',
              onTap: () {},
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
          children: [
            _label('OVERLAYS'),
            Row(
              children: [
                Expanded(
                  child: e2eId(
                    'gallery_sheet',
                    SoftButton(
                      label: 'Sheet',
                      style: SoftButtonStyle.secondary,
                      expand: true,
                      onPressed: () => showSoftSheet<void>(
                        context,
                        title: 'Sheet title',
                        subtitle: 'Supporting text',
                        builder: (_) => Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: c.fill,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: e2eId(
                    'gallery_dialog',
                    SoftButton(
                      label: 'Dialog',
                      style: SoftButtonStyle.secondary,
                      expand: true,
                      onPressed: () => AppFeedback.showConfirmDialog(
                        context,
                        title: 'Discard changes?',
                        message:
                            'You have unsaved edits on this item. They will be lost if you leave now.',
                        confirmLabel: 'Discard',
                        cancelLabel: 'Keep editing',
                        isDestructive: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: e2eId(
                    'gallery_toast',
                    SoftButton(
                      label: 'Toast',
                      style: SoftButtonStyle.secondary,
                      expand: true,
                      onPressed: () => AppFeedback.showSuccess(
                        context,
                        'Item moved to trash',
                        actionLabel: 'Undo',
                        onAction: () {},
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _label('TOASTS'),
            Row(
              children: [
                Expanded(
                  child: SoftButton(
                    label: 'Error',
                    style: SoftButtonStyle.secondary,
                    expand: true,
                    onPressed: () =>
                        AppFeedback.showError(context, 'Something went wrong'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SoftButton(
                    label: 'Info',
                    style: SoftButtonStyle.secondary,
                    expand: true,
                    onPressed: () =>
                        AppFeedback.showInfo(context, 'Heads up'),
                  ),
                ),
              ],
            ),
            _label('SOFT CHIP'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SoftChip(
                  label: 'Stored',
                  background: AppTones.matchaSoft,
                  foreground: AppTones.matcha,
                  icon: Icons.inventory_2_outlined,
                ),
                SoftChip(
                  label: 'Low stock',
                  background: AppTones.amberSoft,
                  foreground: AppTones.amber,
                  dot: true,
                ),
                SoftChip(
                  label: 'Lent',
                  background: AppTones.skySoft,
                  foreground: AppTones.sky,
                ),
                SoftChip.tone('Broken', AppTones.coral),
              ],
            ),
            _label('SOFT FILTER CHIP (selected / off)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in ['All', 'Stored', 'Lent'])
                  SoftFilterChip(
                    label: f,
                    selected: _filter == f,
                    onTap: () => setState(() => _filter = f),
                  ),
              ],
            ),
            _label('SOFT SEARCH FIELD (empty / filled)'),
            SoftSearchField(
              hint: 'Search items, barcode, serial…',
              value: '',
              onChanged: (_) {},
              onClear: () {},
              trailing: AppIcon(
                Icons.close_rounded,
                size: 20,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SoftSearchField(
              hint: 'Search',
              value: _query,
              onChanged: (v) => setState(() => _query = v),
              onClear: () => setState(() => _query = ''),
            ),
            _label('BUTTON (accent / secondary / primary / danger / disabled)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SoftButton(label: 'Add item', icon: Icons.add, onPressed: () {}),
                SoftButton(
                  label: 'Cancel',
                  style: SoftButtonStyle.secondary,
                  onPressed: () {},
                ),
                SoftButton(
                  label: 'Save',
                  style: SoftButtonStyle.primary,
                  onPressed: () {},
                ),
                SoftButton(
                  label: 'Delete',
                  style: SoftButtonStyle.danger,
                  onPressed: () {},
                ),
                const SoftButton(label: 'Disabled', onPressed: null),
              ],
            ),
            _label('SOFT ICON TILE'),
            Row(
              children: [
                const SoftIconTile(Icons.inventory_2_outlined),
                const SizedBox(width: 12),
                SoftIconTile(
                  Icons.warning_amber_rounded,
                  color: AppTones.amber,
                  background: AppTones.amberSoft,
                ),
                const SizedBox(width: 12),
                const SoftIconTile(Icons.settings_outlined, size: 36),
              ],
            ),
            _label('TOGGLE (on / off)'),
            Row(
              children: [
                SoftToggle(
                  value: _toggle,
                  onChanged: (v) => setState(() => _toggle = v),
                ),
                const SizedBox(width: 16),
                const SoftToggle(value: false, onChanged: null),
              ],
            ),
            _label('SECTION HEADER'),
            SoftSectionHeader(
              'Recent items',
              actionLabel: 'View all',
              onAction: () {},
            ),
            _label('ITEM CARD (normal / low stock / lent)'),
            const ItemCard(
              name: 'Sony WH-1000XM5',
              description: '',
              quantityText: '1 pc',
              locationPath: 'Bedroom › Desk drawer',
              status: _Chip('Stored', 0),
              tags: [_Chip('Low stock', 1)],
            ),
            const SizedBox(height: 12),
            const ItemCard(
              name: 'Bosch GSR 18V-55 cordless drill with a very long name',
              description: '',
              quantityText: '2 pcs',
              locationPath: 'Garage › Shelf 2 › Blue box',
              status: _Chip('Lent', 2),
              stockRatio: 0.4,
            ),
            _label('BOX ROW'),
            BoxCard(
              name: 'Living room',
              description: '48 items · 6 containers',
              type: StorageType.room,
              onTap: () {},
            ),
            _label('SETTINGS ROW (value / toggle / plain)'),
            SoftCard(
              child: Column(
                children: [
                  SettingsRow(
                    icon: Icons.palette_outlined,
                    label: 'Theme',
                    value: 'System',
                    onTap: () {},
                  ),
                  SettingsRow(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    trailing: SoftToggle(
                      value: _toggle,
                      onChanged: (v) => setState(() => _toggle = v),
                    ),
                  ),
                  SettingsRow(
                    icon: Icons.delete_outline,
                    label: 'Trash',
                    iconColor: AppTones.coral,
                    iconBackground: AppTones.coralSoft,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            _label('APP FORM FIELD (empty / filled / error)'),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                children: [
                  const AppFormField(
                    label: 'Item name',
                    hintText: 'e.g. Cordless drill',
                    helperText: 'Required',
                  ),
                  const SizedBox(height: 14),
                  AppFormField(
                    label: 'Item name',
                    controller: _filled,
                    prefixIcon: AppIcon(
                      Icons.search_rounded,
                      size: 18,
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppFormField(
                    label: 'Quantity',
                    controller: _error,
                    validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
            _label('EMPTY STATE CARD'),
            EmptyStateCard(
              icon: Icons.inventory_2_outlined,
              title: 'No items yet',
              subtitle:
                  'Add your first item to start tracking where things live.',
              actionLabel: 'Add your first item',
              actionIcon: Icons.add,
              onAction: () {},
            ),
            _label('SYNC STATUS BAR (offline / needs attention)'),
            SyncStatusPill(
              text: 'Offline · 3 changes pending',
              icon: Icons.cloud_off_rounded,
              actionLabel: 'Sync now',
              onAction: () {},
            ),
            const SizedBox(height: 12),
            SyncStatusPill(
              text: 'Sync failed · 2 need attention',
              icon: Icons.sync_problem_rounded,
              danger: true,
              actionLabel: 'Sync now',
              onAction: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int tone;
  const _Chip(this.label, this.tone);

  @override
  Widget build(BuildContext context) => switch (tone) {
    0 => SoftChip(
      label: label,
      background: AppTones.matchaSoft,
      foreground: AppTones.matcha,
      icon: Icons.inventory_2_outlined,
    ),
    1 => SoftChip(
      label: label,
      background: AppTones.amberSoft,
      foreground: AppTones.amber,
      icon: Icons.warning_amber_rounded,
    ),
    _ => SoftChip(
      label: label,
      background: AppTones.skySoft,
      foreground: AppTones.sky,
    ),
  };
}
