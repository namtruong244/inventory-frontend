import 'package:flutter/material.dart';

import 'app_feedback.dart';
import 'app_form_field.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';

Widget buildCustomAttributesSection(
  BuildContext context, {
  required Map<String, String> attributes,
  required void Function(String key, String value, String? replacedKey) onSave,
  required ValueChanged<String> onRemove,
}) {
  final suggestedAttributes = [
    'Color',
    'Size',
    'Brand',
    'Model',
    'Material',
    'Weight',
    'RAM',
    context.l10n.commonStorage,
    'Dimensions',
    'Voltage',
  ].where((attr) => !attributes.containsKey(attr)).toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: _SectionTitle(context.l10n.specificationsAttributes),
                ),
                if (attributes.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${attributes.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => showAddEditAttributeSheet(context, onSave: onSave),
            icon: const AppIcon(Icons.add_rounded, size: 16),
            label: Text(context.l10n.addAttribute2),
            style: TextButton.styleFrom(
              foregroundColor: AppTones.sky,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),

      // Quick suggestions chips
      if (suggestedAttributes.isNotEmpty) ...[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: suggestedAttributes.take(6).map((attr) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: context.colors.fill,
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  avatar: AppIcon(
                    Icons.add,
                    size: 14,
                    color: context.colors.textSecondary,
                  ),
                  label: Text(
                    attr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  onPressed: () => showAddEditAttributeSheet(
                    context,
                    onSave: onSave,
                    initialKey: attr,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
      ],

      // Attributes List or Empty State
      if (attributes.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: context.colors.fill,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.fill,
                  shape: BoxShape.circle,
                ),
                child: AppIcon(
                  Icons.tune_rounded,
                  size: 20,
                  color: context.colors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.noSpecificationsAddedYet,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.addCustomAttributesLikeColor,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    showAddEditAttributeSheet(context, onSave: onSave),
                icon: const AppIcon(Icons.add, size: 16),
                label: Text(context.l10n.addSpecification),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.textPrimary,
                  side: BorderSide(color: context.colors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        )
      else
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: context.colors.cardShadow,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: attributes.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: context.colors.border,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final entry = attributes.entries.elementAt(index);
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                dense: true,
                title: Text(
                  entry.key.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                subtitle: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: AppIcon(
                        Icons.edit_outlined,
                        size: 18,
                        color: context.colors.textSecondary,
                      ),
                      tooltip: context.l10n.commonEdit,
                      onPressed: () => showAddEditAttributeSheet(
                        context,
                        onSave: onSave,
                        existingKey: entry.key,
                        existingValue: entry.value,
                      ),
                    ),
                    IconButton(
                      icon: const AppIcon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppTones.coral,
                      ),
                      tooltip: context.l10n.commonRemove,
                      onPressed: () {
                        onRemove(entry.key);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
    ],
  );
}

void showAddEditAttributeSheet(
  BuildContext context, {
  required void Function(String key, String value, String? replacedKey) onSave,
  String? existingKey,
  String? existingValue,
  String? initialKey,
}) {
  final keyController = TextEditingController(
    text: existingKey ?? initialKey ?? '',
  );
  final valueController = TextEditingController(text: existingValue ?? '');
  final isEditing = existingKey != null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    isEditing
                        ? context.l10n.editSpecification
                        : context.l10n.addSpecification,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context)
                        .closeButtonTooltip,
                    icon: const AppIcon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppFormField(
                label: context.l10n.attributeName,
                hintText: context.l10n.eGColorRamSize2,
                controller: keyController,
              ),
              const SizedBox(height: 14),
              AppFormField(
                label: context.l10n.attributeValue,
                hintText: context.l10n.eGSpaceBlack16gb2,
                controller: valueController,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    final k = keyController.text.trim();
                    final v = valueController.text.trim();
                    if (k.isEmpty) {
                      AppFeedback.showError(
                        ctx,
                        context.l10n.pleaseEnterAnAttributeName,
                      );
                      return;
                    }
                    if (v.isEmpty) {
                      AppFeedback.showError(
                        ctx,
                        context.l10n.pleaseEnterAnAttributeValue,
                      );
                      return;
                    }
                    onSave(
                      k,
                      v,
                      isEditing && existingKey != k ? existingKey : null,
                    );
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isEditing
                        ? context.l10n.saveSpecification
                        : context.l10n.addSpecification,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: context.colors.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }
}
