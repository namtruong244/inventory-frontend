import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_form_field.dart';

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

  void _saveBox() {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.existingBox != null;
      final boxName = _nameController.text.trim();
      if (isEditing) {
        final updatedBox = widget.existingBox!.copyWith(
          name: boxName,
          type: _selectedType,
          description: _descriptionController.text.trim(),
          label: _label,
        );
        Provider.of<InventoryProvider>(context, listen: false).updateBox(updatedBox);
      } else {
        final newBox = Box(
          name: boxName,
          type: _selectedType,
          description: _descriptionController.text.trim(),
          label: _label,
          parentId: widget.parentId,
        );
        Provider.of<InventoryProvider>(context, listen: false).addBox(newBox);
      }
      Navigator.pop(context);
      AppFeedback.showSuccess(
        context,
        isEditing ? 'Location "$boxName" updated successfully' : 'Location "$boxName" created successfully',
      );
    } else {
      AppFeedback.showError(context, 'Please enter a valid location name');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingBox != null;
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final parentBox = widget.parentId != null ? provider.getBoxById(widget.parentId!) : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF18181B)),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          isEditing
              ? 'Edit Location'
              : (widget.parentId == null ? 'Create Root Location' : 'Create Nested Container'),
          style: const TextStyle(
            color: Color(0xFF18181B),
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
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFDC2626)),
                ),
                onPressed: () async {
                  final confirmed = await AppFeedback.showConfirmDialog(
                    context,
                    title: 'Delete this location',
                    message: 'Are you sure you want to delete "${widget.existingBox!.name}"?',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                    icon: Icons.delete_outline,
                  );
                  if (confirmed && context.mounted) {
                    final boxName = widget.existingBox!.name;
                    final ok = await provider.deleteBox(widget.existingBox!.id, cascade: true);
                    if (!context.mounted) return;
                    if (ok) {
                      Navigator.pop(context);
                      AppFeedback.showSuccess(context, 'Location "$boxName" deleted successfully');
                    } else {
                      AppFeedback.showError(context, 'Could not delete "$boxName". Please try again.');
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
            const Text(
              'Storage Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF18181B),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: StorageType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF18181B) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF18181B) : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            type.icon,
                            size: 16,
                            color: isSelected ? Colors.white : const Color(0xFF18181B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            type.displayName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF18181B),
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
              label: 'Name',
              hintText: 'e.g. Living Room, Oak Bookshelf, Electronics Box',
              controller: _nameController,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 20),

            // Description
            AppFormField(
              label: 'Description',
              hintText: 'e.g. Upper shelf, left side near window (Optional)',
              controller: _descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Parent Location Info if nested
            if (parentBox != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Parent Container',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF18181B),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(parentBox.type.icon, size: 20, color: const Color(0xFF18181B)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            parentBox.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF18181B),
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
                const Text(
                  'QR Label ID',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF18181B),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.qr_code_2_rounded,
                        size: 24,
                        color: Color(0xFF18181B),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _label,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF18181B),
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
                onPressed: _saveBox,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF18181B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Save Location',
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
