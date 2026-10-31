import 'package:flutter/material.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../utils/e2e.dart';
import '../utils/text_normalize.dart';
import 'app_form_field.dart';
import 'sheet_search_field.dart';
import 'soft_sheet.dart';
import 'soft_ui.dart';
import 'tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';

Future<String?> showAddCategoryDialog(
  BuildContext context,
  InventoryProvider provider,
) async {
  final textController = TextEditingController();
  String? errorText;

  final newCategory = await showSoftSheet<String>(
    context,
    title: context.l10n.newCategory,
    subtitle: context.l10n.createACustomCategoryFor,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (dialogCtx, setSheetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppFormField(
                id: 'category_name',
                label: context.l10n.categoryName,
                hintText: context.l10n.eGPhotographyWatchesBoard,
                controller: textController,
                onChanged: (_) => setSheetState(() => errorText = null),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 6),
                Text(
                  errorText!,
                  style: TextStyle(
                    color: context.colors.dangerStrong,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 18),
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
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: e2eId(
                      'category_add_confirm',
                      SoftButton(
                        label: context.l10n.addSelect,
                        expand: true,
                        onPressed: () {
                          final name = textController.text.trim();
                          if (name.isEmpty) {
                            setSheetState(() {
                              errorText = context.l10n.pleaseEnterACategoryName;
                            });
                            return;
                          }
                          if (provider.categories.any(
                            (c) => c.toLowerCase() == name.toLowerCase(),
                          )) {
                            setSheetState(() {
                              errorText = context.l10n.categoryAlreadyExists;
                            });
                            return;
                          }
                          provider.addCategory(name);
                          Navigator.pop(sheetContext, name);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
  showSoftSheet<void>(
    context,
    title: context.l10n.commonCategory,
    subtitle: context.l10n.categorySheetSubtitle,
    builder: (ctx) => _CategoryPickerBody(
      categories: provider.categories,
      selected: selected,
      onSelected: (cat) {
        onSelected(cat);
        Navigator.pop(ctx);
      },
      onAddNew: () {
        Navigator.pop(ctx);
        onAddNew();
      },
    ),
  );
}

class _CategoryPickerBody extends StatefulWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onAddNew;

  const _CategoryPickerBody({
    required this.categories,
    required this.selected,
    required this.onSelected,
    required this.onAddNew,
  });

  @override
  State<_CategoryPickerBody> createState() => _CategoryPickerBodyState();
}

class _CategoryPickerBodyState extends State<_CategoryPickerBody> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final q = normalizeVi(_query.trim());
    final list = widget.categories
        .where((cat) => q.isEmpty || containsNormalized(cat, q))
        .toList();
    const cols = 3;
    final rows = <List<String>>[
      for (var i = 0; i < list.length; i += cols)
        list.sublist(i, i + cols > list.length ? list.length : i + cols),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        e2eId(
          'category_search',
          SheetSearchField(
            hint: context.l10n.categorySearchHint,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        const SizedBox(height: 14),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final row in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < cols; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            Expanded(
                              child: i < row.length
                                  ? _CategoryTile(
                                      name: row[i],
                                      selected: row[i] == widget.selected,
                                      onTap: () => widget.onSelected(row[i]),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        e2eId(
          'category_new',
          Tappable(
            onTap: widget.onAddNew,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.border, width: 1.5),
              ),
              child: Row(
                children: [
                  AppIcon(Icons.add_rounded, size: 18, color: c.textPrimary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.l10n.newCategory,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      context.l10n.categoryIconHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.onAccent : c.textPrimary;
    return e2eId(
      'category_$name',
      Tappable(
        semanticLabel: name,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? c.accent : c.fill,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(
                CategoryHelper.getCategoryIcon(name),
                size: 20,
                color: fg,
              ),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
