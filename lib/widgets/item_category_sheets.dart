import 'package:flutter/material.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_form_field.dart';


Future<String?> showAddCategoryDialog(BuildContext context, InventoryProvider provider) async {
  final textController = TextEditingController();
  String? errorText;

  final newCategory = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (dialogCtx, setSheetState) {
          final categoryName = textController.text.trim();
          final previewIcon = CategoryHelper.getCategoryIcon(categoryName.isEmpty ? 'General' : categoryName);

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(previewIcon, color: const Color(0xFF18181B), size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Category',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF18181B),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Create a custom category for your assets',
                              style: TextStyle(fontSize: 12, color: Color(0xFF71717A)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppFormField(
                    label: 'Category Name',
                    hintText: 'e.g. Photography, Watches, Board Games',
                    controller: textController,
                    onChanged: (_) {
                      setSheetState(() {
                        errorText = null;
                      });
                    },
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      errorText!,
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF18181B),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () {
                            final name = textController.text.trim();
                            if (name.isEmpty) {
                              setSheetState(() {
                                errorText = 'Please enter a category name';
                              });
                              return;
                            }
                            if (provider.categories.any((c) => c.toLowerCase() == name.toLowerCase())) {
                              setSheetState(() {
                                errorText = 'Category already exists';
                              });
                              return;
                            }
                            provider.addCategory(name);
                            Navigator.pop(sheetContext, name);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF18181B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Add & Select', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  return newCategory;
}


void showCategoryPickerSheet(
  BuildContext context,
  InventoryProvider provider, {
  required String selected,
  required ValueChanged<String> onSelected,
  required VoidCallback onAddNew,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Colors.white,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Category',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onAddNew();
                        },
                        icon: const Icon(Icons.add, size: 16, color: Color(0xFF18181B)),
                        label: const Text(
                          'New Category',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF18181B), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: provider.categories.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF4F4F6)),
                      itemBuilder: (context, idx) {
                        final cat = provider.categories[idx];
                        final isSelected = selected == cat;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              CategoryHelper.getCategoryIcon(cat),
                              size: 18,
                              color: isSelected ? Colors.white : const Color(0xFF18181B),
                            ),
                          ),
                          title: Text(
                            cat,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                              color: const Color(0xFF18181B),
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF18181B), size: 20)
                              : null,
                          onTap: () {
                            onSelected(cat);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
