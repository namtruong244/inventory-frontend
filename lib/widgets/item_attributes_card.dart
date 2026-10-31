import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_feedback.dart';
import 'app_form_field.dart';
import 'app_icon.dart';
import 'item_card_parts.dart';
import 'soft_sheet.dart';
import 'soft_ui.dart';
import 'tappable.dart';

Widget buildCustomAttributesCard(BuildContext context, Item item) {
  final attributes = item.customAttributes;
  final c = context.colors;
  final l10n = context.l10n;
  final entries = attributes.entries.toList();
  return ItemSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemCardHeader(
          title: l10n.itemSpecifications,
          pillLabel: l10n.commonAdd,
          pillIcon: Icons.add_rounded,
          pillId: 'item_spec_add',
          onPill: () => showManageAttributesSheet(context, item),
        ),
        const SizedBox(height: 14),
        if (entries.isNotEmpty)
          LayoutBuilder(
            builder: (context, box) {
              final w = (box.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final e in entries)
                    SizedBox(
                      width: w,
                      child: Tappable(
                        semanticLabel: e.key,
                        onTap: () => showManageAttributesSheet(
                          context,
                          item,
                          editKey: e.key,
                          editValue: e.value.toString(),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: c.fill,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.key,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: c.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                e.value.toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: c.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: c.fill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  l10n.noSpecificationsAddedYet,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.addCustomDetailsLikeColor,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: c.textSecondary),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

void showManageAttributesSheet(
  BuildContext context,
  Item item, {
  String? editKey,
  String? editValue,
}) {
  final provider = Provider.of<InventoryProvider>(context, listen: false);
  final editing = editKey != null;
  showSoftSheet<void>(
    context,
    title: editing
        ? context.l10n.specSheetEditTitle
        : context.l10n.specSheetAddTitle,
    subtitle: context.l10n.specSheetSubtitle,
    builder: (_) => _AttributesSheetBody(
      host: context,
      provider: provider,
      item: item,
      editKey: editKey,
      editValue: editValue,
    ),
  );
}

class _AttributesSheetBody extends StatefulWidget {
  final BuildContext host;
  final InventoryProvider provider;
  final Item item;
  final String? editKey;
  final String? editValue;

  const _AttributesSheetBody({
    required this.host,
    required this.provider,
    required this.item,
    this.editKey,
    this.editValue,
  });

  @override
  State<_AttributesSheetBody> createState() => _AttributesSheetBodyState();
}

class _AttributesSheetBodyState extends State<_AttributesSheetBody> {
  late final _keyCtrl = TextEditingController(text: widget.editKey ?? '');
  late final _valueCtrl = TextEditingController(text: widget.editValue ?? '');
  bool _showAll = false;

  @override
  void dispose() {
    _keyCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  Item get _latest =>
      widget.provider.getItemById(widget.item.id) ?? widget.item;

  Future<void> _remove(String key) async {
    final attrs = Map<String, dynamic>.from(_latest.customAttributes)
      ..remove(key);
    await widget.provider.updateItem(_latest.copyWith(customAttributes: attrs));
    if (!mounted) return;
    setState(() {});
    if (widget.host.mounted) {
      AppFeedback.showSuccess(widget.host, widget.host.l10n.commonRemoved(key));
    }
  }

  Future<void> _save() async {
    final k = _keyCtrl.text.trim();
    final v = _valueCtrl.text.trim();
    final l10n = context.l10n;
    if (k.isEmpty) {
      AppFeedback.showError(context, l10n.pleaseEnterAnAttributeName);
      return;
    }
    if (v.isEmpty) {
      AppFeedback.showError(context, l10n.pleaseEnterAnAttributeValue);
      return;
    }
    final attrs = Map<String, dynamic>.from(_latest.customAttributes);
    attrs[k] = v;
    await widget.provider.updateItem(_latest.copyWith(customAttributes: attrs));
    if (!mounted) return;
    setState(() {
      _keyCtrl.clear();
      _valueCtrl.clear();
    });
    if (widget.host.mounted) {
      AppFeedback.showSuccess(widget.host, widget.host.l10n.savedAttribute(k));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final current = _latest.customAttributes;
    final suggestions = [
      'Color',
      'Size',
      'Brand',
      'Model',
      'Material',
      'Weight',
      'RAM',
      l10n.commonStorage,
      'Dimensions',
      'Voltage',
    ].where((a) => !current.containsKey(a)).toList();
    final shown = _showAll ? suggestions : suggestions.take(5).toList();
    final labelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5,
      color: c.textSecondary,
    );
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (current.isNotEmpty) ...[
            Text(l10n.currentSpecifications.toUpperCase(), style: labelStyle),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: c.fill,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (final e in current.entries)
                    Row(
                      children: [
                        Expanded(
                          child: Tappable(
                            semanticLabel: e.key,
                            onTap: () => setState(() {
                              _keyCtrl.text = e.key;
                              _valueCtrl.text = e.value.toString();
                            }),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.key,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    e.value.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: c.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Tappable(
                          semanticLabel: l10n.commonRemoved(e.key),
                          onTap: () => _remove(e.key),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: AppIcon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppTones.coral,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (suggestions.isNotEmpty) ...[
            Text(l10n.specSuggestions, style: labelStyle),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, box) {
                final w = (box.maxWidth - 16) / 3;
                Widget chip(String label, bool selected, VoidCallback onTap) =>
                    SizedBox(
                      width: w,
                      child: Tappable(
                        semanticLabel: label,
                        onTap: onTap,
                        child: Container(
                          height: 38,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: selected ? c.primary : c.fill,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : c.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in shown)
                      chip(
                        a,
                        _keyCtrl.text.trim() == a,
                        () => setState(() => _keyCtrl.text = a),
                      ),
                    if (!_showAll && suggestions.length > shown.length)
                      chip(
                        l10n.specMore,
                        false,
                        () => setState(() => _showAll = true),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
          ],
          AppFormField(
            id: 'spec_name',
            label: l10n.specNameLabel,
            hintText: l10n.eGColorRamSize,
            controller: _keyCtrl,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          AppFormField(
            id: 'spec_value',
            label: l10n.specValueLabel,
            hintText: l10n.eGSpaceBlack16gb,
            helperText: l10n.specValueHelper,
            controller: _valueCtrl,
          ),
          const SizedBox(height: 16),
          e2eId(
            'spec_save',
            SoftButton(
              expand: true,
              icon: Icons.add_rounded,
              label: current.containsKey(_keyCtrl.text.trim())
                  ? l10n.saveAttribute
                  : l10n.addSpecification,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}
