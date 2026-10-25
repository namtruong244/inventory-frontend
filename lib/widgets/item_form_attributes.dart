import 'package:flutter/material.dart';

import 'app_feedback.dart';
import 'app_form_field.dart';


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
    'Storage',
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
                  child: _SectionTitle('Specifications & Attributes'),
                ),
                if (attributes.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF18181B),
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
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add Attribute'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF3B82F6),
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
                  backgroundColor: const Color(0xFFF4F4F6),
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  avatar: const Icon(Icons.add, size: 14, color: Color(0xFF71717A)),
                  label: Text(
                    attr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3F3F46),
                    ),
                  ),
                  onPressed: () => showAddEditAttributeSheet(context, onSave: onSave, initialKey: attr),
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
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E4E7)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: Color(0xFFA1A1AA),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No specifications added yet',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3F3F46),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Add custom attributes like Color, Size, RAM, or Brand',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => showAddEditAttributeSheet(context, onSave: onSave),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Specification'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF18181B),
                  side: const BorderSide(color: Color(0xFFD4D4D8)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        )
      else
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E4E7)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: attributes.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Color(0xFFF4F4F6),
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final entry = attributes.entries.elementAt(index);
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                dense: true,
                title: Text(
                  entry.key.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                subtitle: Text(
                  entry.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF18181B),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF71717A)),
                      tooltip: 'Edit',
                      onPressed: () => showAddEditAttributeSheet(context, onSave: onSave, 
                        existingKey: entry.key,
                        existingValue: entry.value,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFFEF4444)),
                      tooltip: 'Remove',
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
  final keyController = TextEditingController(text: existingKey ?? initialKey ?? '');
  final valueController = TextEditingController(text: existingValue ?? '');
  final isEditing = existingKey != null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
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
                    color: const Color(0xFFE4E4E7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    isEditing ? 'Edit Specification' : 'Add Specification',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF18181B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppFormField(
                label: 'Attribute Name',
                hintText: 'e.g. Color, RAM, Size, Material, Weight',
                controller: keyController,
              ),
              const SizedBox(height: 14),
              AppFormField(
                label: 'Attribute Value',
                hintText: 'e.g. Space Black, 16GB, XL, Leather',
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
                      AppFeedback.showError(ctx, 'Please enter an attribute name');
                      return;
                    }
                    if (v.isEmpty) {
                      AppFeedback.showError(ctx, 'Please enter an attribute value');
                      return;
                    }
                    onSave(k, v, isEditing && existingKey != k ? existingKey : null);
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF18181B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Save Specification' : 'Add Specification',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF18181B),
        letterSpacing: -0.3,
      ),
    );
  }
}
