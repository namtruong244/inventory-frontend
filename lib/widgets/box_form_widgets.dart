import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_icon.dart';
import 'box_tree.dart' show boxTypeTone;
import 'soft_ui.dart';
import 'tappable.dart';

/// Dark summary card at the top of the storage form: type tag, live name,
/// parent path and the QR tile of the label.
class BoxLabelPreview extends StatelessWidget {
  final TextEditingController nameController;
  final StorageType type;
  final String? parentName;
  final String label;

  const BoxLabelPreview({
    super.key,
    required this.nameController,
    required this.type,
    required this.parentName,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(type.icon, size: 13, color: c.onAccent),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _shortLabel(context, type),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: c.onAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ListenableBuilder(
                  listenable: nameController,
                  builder: (context, _) {
                    final name = nameController.text.trim();
                    return Text(
                      name.isEmpty
                          ? context.l10n.labelPreviewPlaceholder
                          : name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: name.isEmpty
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.white,
                      ),
                    );
                  },
                ),
                if (parentName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      AppIcon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          context.l10n.insideParent(parentName!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 76,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: label,
                  size: 56,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF18181B),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF18181B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Color(0xFF18181B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 3 x 2 grid of storage types. Selected tile: soft tone fill + 2px tone stroke.
/// Each tile keeps the `box_type_<type>` E2E id.
class StorageTypeGrid extends StatelessWidget {
  final StorageType selected;
  final ValueChanged<StorageType> onChanged;

  const StorageTypeGrid({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const types = StorageType.values;
    final rows = <Widget>[];
    for (var i = 0; i < types.length; i += 3) {
      rows.add(
        Row(
          children: [
            for (var j = i; j < i + 3; j++) ...[
              if (j > i) const SizedBox(width: 8),
              Expanded(
                child: j < types.length
                    ? _TypeTile(
                        type: types[j],
                        selected: types[j] == selected,
                        onTap: () => onChanged(types[j]),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      );
      if (i + 3 < types.length) rows.add(const SizedBox(height: 8));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.storageType,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }
}

class _TypeTile extends StatelessWidget {
  final StorageType type;
  final bool selected;
  final VoidCallback onTap;

  const _TypeTile({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = boxTypeTone(type);
    return e2eId(
      'box_type_${type.name}',
      Tappable(
        semanticLabel: type.displayName,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? tone.bg : c.fill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? tone.fg : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                type.icon,
                size: 22,
                color: selected ? tone.fg : c.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                _shortLabel(context, type),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? c.textPrimary : c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Non-editable form row that looks like an [AppFormField] (label, 52px fill
/// input with a leading icon, helper line).
class BoxReadonlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? helper;
  final bool mono;

  const BoxReadonlyField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.helper,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: c.fill,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              AppIcon(icon, size: 18, color: c.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mono ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: mono ? 'monospace' : null,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(
            helper!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: c.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

/// Bottom bar of the storage form: optional delete button + primary save button.
class BoxFormSaveBar extends StatelessWidget {
  final String saveLabel;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;

  const BoxFormSaveBar({
    super.key,
    required this.saveLabel,
    required this.onSave,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      color: c.background,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Row(
            children: [
              if (onDelete != null) ...[
                e2eId(
                  'box_delete',
                  Tooltip(
                    message: context.l10n.commonDelete,
                    child: Tappable(
                      semanticLabel: context.l10n.commonDelete,
                      onTap: onDelete,
                      child: Container(
                        width: 56,
                        height: 52,
                        decoration: BoxDecoration(
                          color: c.dangerSoft,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: AppIcon(
                          Icons.delete_outline,
                          size: 20,
                          color: c.dangerStrong,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: e2eId(
                  'box_save',
                  SoftButton(label: saveLabel, onPressed: onSave, expand: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Short type name for tight spots (type grid, label tag).
String _shortLabel(BuildContext context, StorageType type) {
  final l = context.l10n;
  switch (type) {
    case StorageType.room:
      return l.storageShortRoom;
    case StorageType.cabinet:
      return l.storageShortCabinet;
    case StorageType.shelf:
      return l.storageShortShelf;
    case StorageType.box:
      return l.storageShortBox;
    case StorageType.drawer:
      return l.storageShortDrawer;
    case StorageType.other:
      return l.storageShortOther;
  }
}
