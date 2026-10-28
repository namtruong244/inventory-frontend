import 'package:flutter/material.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_form_field.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';


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
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: context.colors.fill,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: AppIcon(previewIcon, color: context.colors.textPrimary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.newCategory,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              context.l10n.createACustomCategoryFor,
                              style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppFormField(
                    label: context.l10n.categoryName,
                    hintText: context.l10n.eGPhotographyWatchesBoard,
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
                      style: const TextStyle(color: AppTones.coral, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colors.textPrimary,
                            side: BorderSide(color: context.colors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(context.l10n.commonCancel, style: TextStyle(fontWeight: FontWeight.w600)),
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
                                errorText = context.l10n.pleaseEnterACategoryName;
                              });
                              return;
                            }
                            if (provider.categories.any((c) => c.toLowerCase() == name.toLowerCase())) {
                              setSheetState(() {
                                errorText = context.l10n.categoryAlreadyExists;
                              });
                              return;
                            }
                            provider.addCategory(name);
                            Navigator.pop(sheetContext, name);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(context.l10n.addSelect, style: TextStyle(fontWeight: FontWeight.bold)),
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
    backgroundColor: context.colors.surface,
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
                        color: context.colors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.selectCategory,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onAddNew();
                        },
                        icon: AppIcon(Icons.add, size: 16, color: context.colors.textPrimary),
                        label: Text(
                          context.l10n.newCategory,
                          style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textPrimary, fontSize: 13),
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
                      separatorBuilder: (_, _) => Divider(height: 1, color: context.colors.border),
                      itemBuilder: (context, idx) {
                        final cat = provider.categories[idx];
                        final isSelected = selected == cat;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected ? context.colors.accent : context.colors.fill,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: AppIcon(
                              CategoryHelper.getCategoryIcon(cat),
                              size: 18,
                              color: isSelected ? context.colors.onAccent : context.colors.textPrimary,
                            ),
                          ),
                          title: Text(
                            cat,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          trailing: isSelected
                              ? AppIcon(Icons.check_circle_rounded, color: context.colors.textPrimary, size: 20)
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
