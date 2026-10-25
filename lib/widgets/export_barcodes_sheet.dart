import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'barcode_pdf_builder.dart';
import 'box_barcode_entry.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../providers/inventory_provider.dart';
import 'app_feedback.dart';

/// Full-screen sheet that exports QR codes for storage containers / boxes (no items, no IDs).
part 'export_barcodes_parts.dart';

class ExportBarcodesSheet extends StatefulWidget {
  /// If [boxId] is null, exports all boxes in the inventory.
  final String? boxId;

  const ExportBarcodesSheet({super.key, this.boxId});

  /// Opens export sheet for a specific box (with toggle to switch to all boxes)
  static void show(BuildContext context, String boxId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExportBarcodesSheet(boxId: boxId),
      ),
    );
  }

  /// Opens export sheet for ALL boxes across the inventory
  static void showAll(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExportBarcodesSheet(boxId: null),
      ),
    );
  }

  @override
  State<ExportBarcodesSheet> createState() => _ExportBarcodesSheetState();
}

class _ExportBarcodesSheetState extends State<ExportBarcodesSheet> {
  /// setState entry point for the extension in the part file.
  void _update(VoidCallback fn) => setState(fn);

  final GlobalKey _repaintKey = GlobalKey();
  bool _isGeneratingPdf = false;
  bool _isExportingImage = false;
  int _selectedPrintFormat = 0; // 0: A4 Tomy Decal, 1: Thermal Single Label (50x30mm)

  // If opened with a specific box, user can toggle between this box and all boxes
  late bool _exportAllBoxes;

  @override
  void initState() {
    super.initState();
    _exportAllBoxes = widget.boxId == null;
  }


  /// Exports the PDF file and opens system share sheet (Save to Files, AirDrop, etc.)
  Future<void> _exportPdf(String title, List<BoxBarcodeEntry> entries) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final pdfBytes = await generateBarcodePdf(title: title, printFormat: _selectedPrintFormat, entries: entries);
      final safeName = title.replaceAll(RegExp(r'[^\w\s-]'), '_').trim();
      final fileName = '${safeName.isEmpty ? 'Boxes' : safeName}_barcodes.pdf';

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
      );

      if (mounted) {
        AppFeedback.showSuccess(context, 'PDF generated. Choose "Save to Files" or share.');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Failed to export PDF: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  /// Opens the print preview sheet
  Future<void> _previewAndPrint(String title, List<BoxBarcodeEntry> entries) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final safeName = title.replaceAll(RegExp(r'[^\w\s-]'), '_').trim();
      final fileName = '${safeName.isEmpty ? 'Boxes' : safeName}_barcodes';

      await Printing.layoutPdf(
        name: fileName,
        onLayout: (PdfPageFormat format) async => await generateBarcodePdf(title: title, printFormat: _selectedPrintFormat, entries: entries),
      );
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Print preview failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<InventoryProvider>(context);

    // Prepare entries: BOXES ONLY (no items, no IDs on label)
    final List<BoxBarcodeEntry> entries = [];
    String screenTitle;
    String headerTitle;
    String headerSubtitle;
    IconData headerIcon;

    if (_exportAllBoxes || widget.boxId == null) {
      // Export ALL boxes
      screenTitle = 'Export All Box Barcodes';
      headerTitle = 'All Storage Locations';
      headerSubtitle = '${provider.boxes.length} container QR codes';
      headerIcon = Icons.inventory_2_outlined;

      for (final b in provider.boxes) {
        final code = b.label.isNotEmpty ? b.label : b.id;
        entries.add(BoxBarcodeEntry(name: b.name, code: code));
      }
    } else {
      // Export specific box & its sub-boxes
      final targetBox = provider.getBoxById(widget.boxId!);
      if (targetBox == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Export Barcodes')),
          body: const Center(child: Text('Box not found')),
        );
      }

      final subBoxes = provider.getBoxesIn(targetBox.id);
      screenTitle = 'Export Box Barcodes';
      headerTitle = targetBox.name;
      headerSubtitle = '${subBoxes.length + 1} container QR codes';
      headerIcon = targetBox.type.icon;

      // Add main box
      entries.add(BoxBarcodeEntry(
        name: targetBox.name,
        code: targetBox.label.isNotEmpty ? targetBox.label : targetBox.id,
      ));

      // Add sub-boxes
      for (final sub in subBoxes) {
        entries.add(BoxBarcodeEntry(
          name: sub.name,
          code: sub.label.isNotEmpty ? sub.label : sub.id,
        ));
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new, size: 18, color: theme.colorScheme.primary),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              screenTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF18181B),
              ),
            ),
            Text(
              '${entries.length} box labels',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Tooltip(
              message: 'Capture and save barcode sheet as image',
              child: OutlinedButton.icon(
                onPressed: _isExportingImage ? null : _exportAsImage,
                icon: _isExportingImage
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF18181B)),
                      )
                    : const Icon(Icons.image_outlined, size: 16, color: Color(0xFF18181B)),
                label: const Text(
                  'Save Image',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF18181B),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE4E4E7)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // If launched from a specific box, show SegmentedControl to toggle between this box and all boxes
          if (widget.boxId != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E4E7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _exportAllBoxes = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_exportAllBoxes ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: !_exportAllBoxes
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'This Container',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: !_exportAllBoxes ? FontWeight.bold : FontWeight.w500,
                                color: !_exportAllBoxes ? const Color(0xFF18181B) : const Color(0xFF71717A),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _exportAllBoxes = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _exportAllBoxes ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: _exportAllBoxes
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'All Containers (${provider.boxes.length})',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _exportAllBoxes ? FontWeight.bold : FontWeight.w500,
                                color: _exportAllBoxes ? const Color(0xFF18181B) : const Color(0xFF71717A),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Print Specs Format Selection (A4 Tomy vs Thermal 50x30mm)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4E4E7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.tune_rounded, size: 16, color: Color(0xFF71717A)),
                            const SizedBox(width: 6),
                            Text(
                              'PRINT SPECS / FORMAT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPrintFormatOption(
                                index: 0,
                                title: 'A4 Tomy Decal',
                                subtitle: 'Standard grid sheet',
                                icon: Icons.grid_view_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildPrintFormatOption(
                                index: 1,
                                title: 'Thermal 50x30mm',
                                subtitle: 'Single roll label',
                                icon: Icons.receipt_long_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 1. Summary Card (Consistent white card with subtle grey border)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE4E4E7)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(headerIcon, color: const Color(0xFF18181B), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                headerTitle,
                                style: const TextStyle(
                                  color: Color(0xFF18181B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                headerSubtitle,
                                style: const TextStyle(
                                  color: Color(0xFF71717A),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Barcode Cards Grid (QR code + Box Name + Cut Guide)
                  RepaintBoundary(
                    key: _repaintKey,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: entries.map((entry) => _buildBarcodeCard(entry)).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar: Export PDF & Print
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Print / Preview button
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: _isGeneratingPdf ? null : () => _previewAndPrint(headerTitle, entries),
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: const Text('Print Preview'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF18181B),
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Primary Export PDF button (Save / Share)
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _isGeneratingPdf ? null : () => _exportPdf(headerTitle, entries),
                    icon: _isGeneratingPdf
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: Text(_isGeneratingPdf ? 'Generating PDF...' : 'Export PDF (Save/Share)'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF18181B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
