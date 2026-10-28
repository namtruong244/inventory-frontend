import 'package:flutter/material.dart';
import 'app_form_field.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';

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
        decoration: BoxDecoration(
          color: context.colors.surface,
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
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.editProfile,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.updateYourDisplayNameAnd,
              style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
            ),
            const SizedBox(height: 20),
            AppFormField(
              label: context.l10n.displayName,
              hintText: context.l10n.eGSaraWilson,
              controller: nameController,
            ),
            const SizedBox(height: 14),
            AppFormField(
              label: context.l10n.roleDepartment,
              hintText: context.l10n.eGAssetManagerHome,
              controller: roleController,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.textPrimary,
                      side: BorderSide(color: context.colors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(context.l10n.commonCancel, style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      provider.updateUserProfile(nameController.text, roleController.text);
                      Navigator.pop(sheetContext);
                      AppFeedback.showSuccess(context, context.l10n.profileUpdatedSuccessfully);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(context.l10n.saveChanges, style: TextStyle(fontWeight: FontWeight.bold)),
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
                decoration: BoxDecoration(
                  color: context.colors.surface,
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
                          color: context.colors.border,
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
                            Text(
                              context.l10n.manageCategories,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${provider.categories.length} total categories configured',
                              style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                            ),
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            showAddCategorySubDialog(context, provider, (newCat) {
                              setSheetState(() {});
                            });
                          },
                          icon: const AppIcon(Icons.add, size: 16),
                          label: Text(context.l10n.commonNew, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colors.primary,
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
                        hintText: context.l10n.searchCategories,
                        hintStyle: TextStyle(color: context.colors.textMuted, fontSize: 14),
                        prefixIcon: AppIcon(Icons.search, size: 20, color: context.colors.textSecondary),
                        filled: true,
                        fillColor: context.colors.fill,
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
                              child: Text(context.l10n.noCategoriesMatch(searchQuery), style: TextStyle(color: context.colors.textMuted)),
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
                                      color: context.colors.fill,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: AppIcon(
                                      CategoryHelper.getCategoryIcon(cat),
                                      color: context.colors.textPrimary,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    cat,
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.colors.textPrimary),
                                  ),
                                  subtitle: Text(
                                    '$count ${count == 1 ? "item" : "items"}${isDefault ? " • Built-in" : " • Custom"}',
                                    style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                                  ),
                                  trailing: !isDefault
                                      ? IconButton(
 tooltip: context.l10n.commonDelete,
                                          icon: const AppIcon(Icons.delete_outline, size: 20, color: AppTones.coral),
                                          onPressed: () async {
                                            final confirmed = await AppFeedback.showConfirmDialog(
                                              dialogCtx,
                                              title: context.l10n.deleteCategory,
                                              message: context.l10n.deleteCategoryAnyItemsIn(cat),
                                              confirmLabel: context.l10n.commonDelete,
                                              isDestructive: true,
                                              icon: Icons.delete_outline,
                                            );
                                            if (confirmed && dialogCtx.mounted) {
                                              provider.deleteCategory(cat);
                                              setSheetState(() {});
                                              AppFeedback.showSuccess(dialogCtx, context.l10n.categoryRemoved(cat));
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
              decoration: BoxDecoration(
                color: context.colors.surface,
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
                        color: context.colors.border,
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
                          color: context.colors.fill,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: AppIcon(previewIcon, color: context.colors.textPrimary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.addNewCategory,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                          ),
                          SizedBox(height: 2),
                          Text(
                            context.l10n.enterACategoryNameFor,
                            style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppFormField(
                    label: context.l10n.categoryName,
                    hintText: context.l10n.eGPhotographyBoardGames,
                    controller: textController,
                    onChanged: (_) {
                      setSubState(() => errorText = null);
                    },
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 6),
                    Text(errorText!, style: const TextStyle(color: AppTones.coral, fontSize: 12)),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(subSheetContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colors.textPrimary,
                            side: BorderSide(color: context.colors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(context.l10n.commonCancel, style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final name = textController.text.trim();
                            if (name.isEmpty) {
                              setSubState(() => errorText = context.l10n.pleaseEnterACategoryName);
                              return;
                            }
                            if (provider.categories.any((c) => c.toLowerCase() == name.toLowerCase())) {
                              setSubState(() => errorText = context.l10n.categoryAlreadyExists);
                              return;
                            }
                            provider.addCategory(name);
                            Navigator.pop(subSheetContext);
                            onAdded(name);
                            AppFeedback.showSuccess(context, context.l10n.categoryCreated2(name));
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(context.l10n.addCategory, style: TextStyle(fontWeight: FontWeight.bold)),
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
