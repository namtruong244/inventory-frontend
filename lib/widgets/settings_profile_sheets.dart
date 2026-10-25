import 'package:flutter/material.dart';
import 'app_form_field.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';

void showEditProfileDialog(BuildContext context, InventoryProvider provider) {
  final nameController = TextEditingController(text: provider.userName);
  final roleController = TextEditingController(text: provider.userRole);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
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
            const Text(
              'Edit Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
            ),
            const SizedBox(height: 4),
            Text(
              'Update your display name and inventory role',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            AppFormField(
              label: 'Display Name',
              hintText: 'e.g. Sara Wilson',
              controller: nameController,
            ),
            const SizedBox(height: 14),
            AppFormField(
              label: 'Role / Department',
              hintText: 'e.g. Asset Manager, Home Owner',
              controller: roleController,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF18181B),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      provider.updateUserProfile(nameController.text, roleController.text);
                      Navigator.pop(sheetContext);
                      AppFeedback.showSuccess(context, 'Profile updated successfully');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF18181B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void showCategoryManagementSheet(BuildContext context, InventoryProvider provider) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      String searchQuery = '';
      return StatefulBuilder(
        builder: (dialogCtx, setSheetState) {
          final filteredCategories = provider.categories
              .where((c) => c.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Manage Categories',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${provider.categories.length} total categories configured',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            showAddCategorySubDialog(context, provider, (newCat) {
                              setSheetState(() {});
                            });
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('New', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF18181B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    TextField(
                      onChanged: (val) => setSheetState(() => searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search categories...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFF4F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filteredCategories.isEmpty
                          ? Center(
                              child: Text('No categories match "$searchQuery"', style: TextStyle(color: Colors.grey.shade500)),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              itemCount: filteredCategories.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final cat = filteredCategories[index];
                                final count = provider.getItemCountForCategory(cat);
                                final isDefault = CategoryHelper.defaultCategories.contains(cat);

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F4F6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      CategoryHelper.getCategoryIcon(cat),
                                      color: const Color(0xFF18181B),
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    cat,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF18181B)),
                                  ),
                                  subtitle: Text(
                                    '$count ${count == 1 ? "item" : "items"}${isDefault ? " • Built-in" : " • Custom"}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  trailing: !isDefault
                                      ? IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444)),
                                          onPressed: () async {
                                            final confirmed = await AppFeedback.showConfirmDialog(
                                              dialogCtx,
                                              title: 'Delete Category',
                                              message: 'Delete category "$cat"? Any items in this category will be reassigned to "General".',
                                              confirmLabel: 'Delete',
                                              isDestructive: true,
                                              icon: Icons.delete_outline,
                                            );
                                            if (confirmed && dialogCtx.mounted) {
                                              provider.deleteCategory(cat);
                                              setSheetState(() {});
                                              AppFeedback.showSuccess(dialogCtx, 'Category "$cat" removed');
                                            }
                                          },
                                        )
                                      : null,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}


void showAddCategorySubDialog(BuildContext context, InventoryProvider provider, Function(String) onAdded) {
  final textController = TextEditingController();
  String? errorText;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (subSheetContext) {
      return StatefulBuilder(
        builder: (dialogCtx, setSubState) {
          final catName = textController.text.trim();
          final previewIcon = CategoryHelper.getCategoryIcon(catName.isEmpty ? 'General' : catName);

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(subSheetContext).viewInsets.bottom),
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
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(previewIcon, color: const Color(0xFF18181B), size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Category',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Enter a category name for your catalog',
                            style: TextStyle(fontSize: 12, color: Color(0xFF71717A)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppFormField(
                    label: 'Category Name',
                    hintText: 'e.g. Photography, Board Games, Hardware',
                    controller: textController,
                    onChanged: (_) {
                      setSubState(() => errorText = null);
                    },
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 6),
                    Text(errorText!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(subSheetContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF18181B),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final name = textController.text.trim();
                            if (name.isEmpty) {
                              setSubState(() => errorText = 'Please enter a category name');
                              return;
                            }
                            if (provider.categories.any((c) => c.toLowerCase() == name.toLowerCase())) {
                              setSubState(() => errorText = 'Category already exists');
                              return;
                            }
                            provider.addCategory(name);
                            Navigator.pop(subSheetContext);
                            onAdded(name);
                            AppFeedback.showSuccess(context, 'Category "$name" created');
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF18181B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.bold)),
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
}
