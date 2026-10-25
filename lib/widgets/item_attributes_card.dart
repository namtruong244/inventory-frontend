import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';


Widget buildCustomAttributesCard(BuildContext context, Item item) {
  final attributes = item.customAttributes;
  final hasAttributes = attributes.isNotEmpty;

  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 20, color: Color(0xFF18181B)),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Specifications & Attributes',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasAttributes) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${attributes.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => showManageAttributesSheet(context, item),
              icon: Icon(hasAttributes ? Icons.edit_outlined : Icons.add_rounded, size: 15),
              label: Text(hasAttributes ? 'Manage' : 'Add'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (hasAttributes)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: attributes.entries.map((entry) {
              return InkWell(
                onTap: () => showManageAttributesSheet(
                  context,
                  item,
                  editKey: entry.key,
                  editValue: entry.value.toString(),
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.key.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.value.toString(),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE4E4E7)),
            ),
            child: Column(
              children: [
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
                  'Add custom details like Color, Size, Brand, or Specs.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF71717A),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => showManageAttributesSheet(context, item),
                  icon: const Icon(Icons.add, size: 15),
                  label: const Text('Add Specification'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF18181B),
                    side: const BorderSide(color: Color(0xFFD4D4D8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
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
  final keyController = TextEditingController(text: editKey ?? '');
  final valueController = TextEditingController(text: editValue ?? '');
  final provider = Provider.of<InventoryProvider>(context, listen: false);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          final latestItem = provider.getItemById(item.id) ?? item;
          final currentAttributes = Map<String, dynamic>.from(latestItem.customAttributes);
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
          ].where((attr) => !currentAttributes.containsKey(attr)).toList();

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
              child: SingleChildScrollView(
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
                        const Icon(Icons.tune_rounded, size: 22, color: Color(0xFF18181B)),
                        const SizedBox(width: 8),
                        const Text(
                          'Specifications & Attributes',
                          style: TextStyle(
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
                    const SizedBox(height: 8),
                    const Text(
                      'Customize attributes and metadata for this item.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF71717A)),
                    ),
                    const SizedBox(height: 16),

                    // Existing attributes list in sheet
                    if (currentAttributes.isNotEmpty) ...[
                      const Text(
                        'CURRENT SPECIFICATIONS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF71717A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE4E4E7)),
                        ),
                        child: Column(
                          children: currentAttributes.entries.map((entry) {
                            return ListTile(
                              dense: true,
                              title: Text(
                                entry.key.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              subtitle: Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF18181B),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF71717A)),
                                    onPressed: () {
                                      setSheetState(() {
                                        keyController.text = entry.key;
                                        valueController.text = entry.value.toString();
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFFEF4444)),
                                    onPressed: () async {
                                      final newAttrs = Map<String, dynamic>.from(latestItem.customAttributes)
                                        ..remove(entry.key);
                                      final updated = latestItem.copyWith(customAttributes: newAttrs);
                                      await provider.updateItem(updated);
                                      setSheetState(() {});
                                      if (context.mounted) {
                                        AppFeedback.showSuccess(context, 'Removed "${entry.key}"');
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Quick suggestion chips
                    if (suggestedAttributes.isNotEmpty) ...[
                      const Text(
                        'SUGGESTED ATTRIBUTES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF71717A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                                onPressed: () {
                                  setSheetState(() {
                                    keyController.text = attr;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Input section for adding/editing an attribute
                    Text(
                      keyController.text.isNotEmpty && currentAttributes.containsKey(keyController.text)
                          ? 'EDIT ATTRIBUTE'
                          : 'ADD ATTRIBUTE',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF71717A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: keyController,
                      decoration: InputDecoration(
                        labelText: 'Attribute Name',
                        hintText: 'e.g. Color, RAM, Size, Material',
                        filled: true,
                        fillColor: const Color(0xFFF4F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: valueController,
                      decoration: InputDecoration(
                        labelText: 'Attribute Value',
                        hintText: 'e.g. Space Black, 16GB, XL',
                        filled: true,
                        fillColor: const Color(0xFFF4F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        onPressed: () async {
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

                          final newAttrs = Map<String, dynamic>.from(latestItem.customAttributes);
                          newAttrs[k] = v;
                          final updated = latestItem.copyWith(customAttributes: newAttrs);
                          await provider.updateItem(updated);

                          setSheetState(() {
                            keyController.clear();
                            valueController.clear();
                          });

                          if (context.mounted) {
                            AppFeedback.showSuccess(context, 'Saved attribute "$k"');
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF18181B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Save Attribute', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
