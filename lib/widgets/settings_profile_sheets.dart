import 'package:flutter/material.dart';

import 'app_form_field.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';
import 'soft_sheet.dart';
import 'soft_ui.dart';
import 'tappable.dart';

void showEditProfileDialog(BuildContext context, InventoryProvider provider) {
  final nameController = TextEditingController(text: provider.userName);
  final roleController = TextEditingController(text: provider.userRole);

  showSoftSheet(
    context,
    title: context.l10n.editProfile,
    subtitle: context.l10n.updateYourDisplayNameAnd,
    builder: (sheetContext) => SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                child: SoftButton(
                  label: context.l10n.commonCancel,
                  style: SoftButtonStyle.secondary,
                  expand: true,
                  onPressed: () => Navigator.pop(sheetContext),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SoftButton(
                  label: context.l10n.saveChanges,
                  expand: true,
                  onPressed: () {
                    provider.updateUserProfile(
                      nameController.text,
                      roleController.text,
                    );
                    Navigator.pop(sheetContext);
                    AppFeedback.showSuccess(
                      context,
                      context.l10n.profileUpdatedSuccessfully,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

void showCategoryManagementSheet(
  BuildContext context,
  InventoryProvider provider,
) {
  var searchQuery = '';
  showSoftSheet(
    context,
    title: context.l10n.manageCategories,
    subtitle: '${provider.categories.length} total categories configured',
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (dialogCtx, setSheetState) {
          final c = dialogCtx.colors;
          final filteredCategories = provider.categories
              .where((c) => c.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();
          final maxListHeight = MediaQuery.sizeOf(dialogCtx).height * 0.45;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SoftButton(
                  label: context.l10n.commonNew,
                  icon: Icons.add,
                  onPressed: () {
                    showAddCategorySubDialog(context, provider, (newCat) {
                      setSheetState(() {});
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              SoftSearchField(
                hint: context.l10n.searchCategories,
                value: searchQuery,
                onChanged: (val) => setSheetState(() => searchQuery = val),
                onClear: () => setSheetState(() => searchQuery = ''),
              ),
              const SizedBox(height: 12),
              if (filteredCategories.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      context.l10n.noCategoriesMatch(searchQuery),
                      style: TextStyle(color: c.textMuted),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxListHeight),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final cat = filteredCategories[index];
                      final count = provider.getItemCountForCategory(cat);
                      final isDefault = CategoryHelper.defaultCategories
                          .contains(cat);
                      return _CategoryRow(
                        name: cat,
                        subtitle:
                            '$count ${count == 1 ? "item" : "items"}${isDefault ? " • Built-in" : " • Custom"}',
                        onDelete: isDefault
                            ? null
                            : () async {
                                final confirmed =
                                    await AppFeedback.showConfirmDialog(
                                      dialogCtx,
                                      title: context.l10n.deleteCategory,
                                      message: context.l10n
                                          .deleteCategoryAnyItemsIn(cat),
                                      confirmLabel: context.l10n.commonDelete,
                                      isDestructive: true,
                                      icon: Icons.delete_outline,
                                    );
                                if (confirmed && dialogCtx.mounted) {
                                  provider.deleteCategory(cat);
                                  setSheetState(() {});
                                  AppFeedback.showSuccess(
                                    dialogCtx,
                                    context.l10n.categoryRemoved(cat),
                                  );
                                }
                              },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      );
    },
  );
}

class _CategoryRow extends StatelessWidget {
  final String name;
  final String subtitle;
  final VoidCallback? onDelete;

  const _CategoryRow({
    required this.name,
    required this.subtitle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SoftIconTile(CategoryHelper.getCategoryIcon(name), size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            Tappable(
              semanticLabel: context.l10n.commonDelete,
              onTap: onDelete,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.dangerSoft,
                  shape: BoxShape.circle,
                ),
                child: AppIcon(
                  Icons.delete_outline,
                  size: 18,
                  color: c.dangerStrong,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void showAddCategorySubDialog(
  BuildContext context,
  InventoryProvider provider,
  Function(String) onAdded,
) {
  final textController = TextEditingController();
  String? errorText;

  showSoftSheet(
    context,
    title: context.l10n.addNewCategory,
    subtitle: context.l10n.enterACategoryNameFor,
    builder: (subSheetContext) {
      return StatefulBuilder(
        builder: (dialogCtx, setSubState) {
          final c = dialogCtx.colors;
          final catName = textController.text.trim();
          final previewIcon = CategoryHelper.getCategoryIcon(
            catName.isEmpty ? 'General' : catName,
          );

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: SoftIconTile(previewIcon, size: 44),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppFormField(
                        label: context.l10n.categoryName,
                        hintText: context.l10n.eGPhotographyBoardGames,
                        controller: textController,
                        onChanged: (_) {
                          setSubState(() => errorText = null);
                        },
                      ),
                    ),
                  ],
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    errorText!,
                    style: TextStyle(color: c.dangerStrong, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SoftButton(
                        label: context.l10n.commonCancel,
                        style: SoftButtonStyle.secondary,
                        expand: true,
                        onPressed: () => Navigator.pop(subSheetContext),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SoftButton(
                        label: context.l10n.addCategory,
                        expand: true,
                        onPressed: () {
                          final name = textController.text.trim();
                          if (name.isEmpty) {
                            setSubState(
                              () => errorText =
                                  context.l10n.pleaseEnterACategoryName,
                            );
                            return;
                          }
                          if (provider.categories.any(
                            (c) => c.toLowerCase() == name.toLowerCase(),
                          )) {
                            setSubState(
                              () => errorText =
                                  context.l10n.categoryAlreadyExists,
                            );
                            return;
                          }
                          provider.addCategory(name);
                          Navigator.pop(subSheetContext);
                          onAdded(name);
                          AppFeedback.showSuccess(
                            context,
                            context.l10n.categoryCreated2(name),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
