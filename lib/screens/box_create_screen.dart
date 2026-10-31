import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/trash_actions.dart';
import '../widgets/app_form_field.dart';
import '../widgets/box_form_widgets.dart';
import '../widgets/soft_ui.dart';
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
      _selectedType = widget.parentId == null
          ? StorageType.room
          : StorageType.box;
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
        isEditing
            ? context.l10n.locationUpdatedSuccessfully(boxName)
            : context.l10n.locationCreatedSuccessfully(boxName),
      );
    } else {
      setState(() => _saving = false);
      AppFeedback.showError(context, context.l10n.somethingWentWrongPleaseTry);
    }
  }

  Future<void> _deleteBox(InventoryProvider provider) async {
    final box = widget.existingBox!;
    final confirmed = await TrashActions.confirm(
      context,
      name: box.name,
      isBox: true,
      hasContents: true,
    );
    if (!confirmed || !mounted) return;
    final ok = await provider.deleteBox(box.id, cascade: true);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      TrashActions.showMoved(context, provider, name: box.name, boxId: box.id);
    } else {
      AppFeedback.showError(
        context,
        context.l10n.couldNotDeletePleaseTry(box.name),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingBox != null;
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final parentId = isEditing ? widget.existingBox!.parentId : widget.parentId;
    final parentBox = parentId != null ? provider.getBoxById(parentId) : null;
    final c = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: c.background,
        appBar: SoftTopAppBar(
          title: isEditing
              ? context.l10n.editLocation
              : (widget.parentId == null
                    ? context.l10n.createRootLocation
                    : context.l10n.createNestedContainer),
          leadingIcon: isEditing
              ? Icons.arrow_back_rounded
              : Icons.close_rounded,
        ),
        bottomNavigationBar: BoxFormSaveBar(
          saveLabel: isEditing
              ? context.l10n.saveChanges
              : context.l10n.saveLocation,
          onSave: _saving ? null : _saveBox,
          onDelete: isEditing ? () => _deleteBox(provider) : null,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            children: [
              BoxLabelPreview(
                nameController: _nameController,
                type: _selectedType,
                parentName: parentBox?.name,
                label: _label,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: c.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFormField(
                      id: 'box_name',
                      label: context.l10n.commonName,
                      hintText: context.l10n.eGLivingRoomOak,
                      controller: _nameController,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? context.l10n.pleaseEnterAName
                          : null,
                    ),
                    const SizedBox(height: 18),
                    StorageTypeGrid(
                      selected: _selectedType,
                      onChanged: (t) => setState(() => _selectedType = t),
                    ),
                    const SizedBox(height: 18),
                    BoxReadonlyField(
                      label: context.l10n.parentContainer,
                      value: parentBox?.name ?? context.l10n.parentNoneTopLevel,
                      icon: parentBox?.type.icon ?? Icons.home_outlined,
                      helper: parentBox == null
                          ? context.l10n.parentHelperTopLevel
                          : null,
                    ),
                    const SizedBox(height: 18),
                    AppFormField(
                      id: 'box_description',
                      label: context.l10n.commonDescription,
                      hintText: context.l10n.eGUpperShelfLeft,
                      controller: _descriptionController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 18),
                    BoxReadonlyField(
                      label: context.l10n.qrLabelId,
                      value: _label,
                      icon: Icons.qr_code_2_rounded,
                      helper: context.l10n.qrLabelHelper,
                      mono: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
