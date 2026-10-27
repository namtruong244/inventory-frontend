import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/trash_actions.dart';
import '../widgets/app_form_field.dart';
import '../widgets/tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

class BoxCreateScreen extends StatefulWidget {
  final String? parentId;
  final Box? existingBox;

  const BoxCreateScreen({super.key, this.parentId, this.existingBox});

  @override
  State<BoxCreateScreen> createState() => _BoxCreateScreenState();
}

class _BoxCreateScreenState extends State<BoxCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late String _label;
  late StorageType _selectedType;

  @override
  void initState() {
    super.initState();
    if (widget.existingBox != null) {
      _nameController.text = widget.existingBox!.name;
      _descriptionController.text = widget.existingBox!.description;
      _label = widget.existingBox!.label;
      _selectedType = widget.existingBox!.type;
    } else {
      _label = 'loc_${const Uuid().v4().substring(0, 8)}';
      _selectedType = widget.parentId == null ? StorageType.room : StorageType.box;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _saving = false;

  Future<void> _saveBox() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) {
      AppFeedback.showError(context, context.l10n.pleaseEnterAValidLocation);
      return;
    }
    setState(() => _saving = true);
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final isEditing = widget.existingBox != null;
    final boxName = _nameController.text.trim();
    final bool ok;
    if (isEditing) {
      ok = await provider.updateBox(
        widget.existingBox!.copyWith(
          name: boxName,
          type: _selectedType,
          description: _descriptionController.text.trim(),
          label: _label,
        ),
      );
    } else {
      ok = await provider.addBox(
        Box(
          name: boxName,
          type: _selectedType,
          description: _descriptionController.text.trim(),
          label: _label,
          parentId: widget.parentId,
        ),
      );
    }
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      AppFeedback.showSuccess(
        context,
        isEditing ? context.l10n.locationUpdatedSuccessfully(boxName) : context.l10n.locationCreatedSuccessfully(boxName),
      );
    } else {
      setState(() => _saving = false);
      AppFeedback.showError(context, context.l10n.somethingWentWrongPleaseTry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingBox != null;
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final parentBox = widget.parentId != null ? provider.getBoxById(widget.parentId!) : null;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
 tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: context.colors.textPrimary),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          isEditing
              ? context.l10n.editLocation
              : (widget.parentId == null ? context.l10n.createRootLocation : context.l10n.createNestedContainer),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
 tooltip: context.l10n.commonDelete,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFDC2626)),
                ),
                onPressed: () async {
                  final confirmed = await TrashActions.confirm(
                    context,
                    name: widget.existingBox!.name,
                    isBox: true,
                    hasContents: true,
                  );
                  if (confirmed && context.mounted) {
                    final boxName = widget.existingBox!.name;
                    final boxId = widget.existingBox!.id;
                    final ok = await provider.deleteBox(widget.existingBox!.id, cascade: true);
                    if (!context.mounted) return;
                    if (ok) {
                      Navigator.pop(context);
                      TrashActions.showMoved(context, provider, name: boxName, boxId: boxId);
                    } else {
                      AppFeedback.showError(context, context.l10n.couldNotDeletePleaseTry(boxName));
                    }
                  }
                },
              ),
            ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            // Storage Type Selector
            Text(
              context.l10n.storageType,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: StorageType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return Tappable(
                    onTap: () => setState(() => _selectedType = type),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? context.colors.primary : context.colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? context.colors.primary : context.colors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            type.icon,
                            size: 16,
                            color: isSelected ? Colors.white : context.colors.textPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            type.displayName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : context.colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Location Name
            AppFormField(
              label: context.l10n.commonName,
              hintText: context.l10n.eGLivingRoomOak,
              controller: _nameController,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? context.l10n.pleaseEnterAName : null,
            ),
            const SizedBox(height: 20),

            // Description
            AppFormField(
              label: context.l10n.commonDescription,
              hintText: context.l10n.eGUpperShelfLeft,
              controller: _descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Parent Location Info if nested
            if (parentBox != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.parentContainer,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: context.colors.fill,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(parentBox.type.icon, size: 20, color: context.colors.textPrimary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            parentBox.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Label ID section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.qrLabelId,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  decoration: BoxDecoration(
                    color: context.colors.fill,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 24,
                        color: context.colors.textPrimary,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _label,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _saveBox,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isEditing ? context.l10n.saveChanges : context.l10n.saveLocation,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
