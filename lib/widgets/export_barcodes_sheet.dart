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
import 'tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';

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
        AppFeedback.showSuccess(context, context.l10n.pdfGeneratedChooseSaveTo);
      }
    } catch (e) {
      debugPrint('export_barcodes_sheet.dart error: $e');
      if (mounted) {
        AppFeedback.showError(context, context.l10n.couldnTExportThePdf);
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
      debugPrint('export_barcodes_sheet.dart error: $e');
      if (mounted) {
        AppFeedback.showError(context, context.l10n.couldnTOpenThePrint);
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
      screenTitle = context.l10n.exportAllBoxBarcodes;
      headerTitle = context.l10n.allStorageLocations;
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
          appBar: AppBar(title: Text(context.l10n.exportBarcodes)),
          body: Center(child: Text(context.l10n.boxNotFound)),
        );
      }

      final subBoxes = provider.getBoxesIn(targetBox.id);
      screenTitle = context.l10n.exportBoxBarcodes;
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
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        surfaceTintColor: Colors.transparent,
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
                boxShadow: context.colors.cardShadow,
              ),
              child: AppIcon(Icons.arrow_back_ios_new, size: 18, color: theme.colorScheme.primary),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              screenTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: context.colors.textPrimary,
              ),
            ),
            Text(
              '${entries.length} box labels',
              style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Tooltip(
              message: context.l10n.captureAndSaveBarcodeSheet,
              child: FilledButton.icon(
                onPressed: _isExportingImage ? null : _exportAsImage,
                icon: _isExportingImage
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.textPrimary),
                      )
                    : AppIcon(Icons.image_outlined, size: 16, color: context.colors.textPrimary),
                label: Text(context.l10n.saveImage),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.surface,
                  foregroundColor: context.colors.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: const Size(0, 40),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: context.colors.fill,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    for (final all in const [false, true])
                      Expanded(
                        child: Tappable(
                          semanticLabel: all ? context.l10n.allContainers(provider.boxes.length) : context.l10n.thisContainer,
                          onTap: () => setState(() => _exportAllBoxes = all),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: _exportAllBoxes == all ? context.colors.accent : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                all ? context.l10n.allContainers(provider.boxes.length) : context.l10n.thisContainer,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _exportAllBoxes == all ? FontWeight.w800 : FontWeight.w600,
                                  color: _exportAllBoxes == all ? context.colors.onAccent : context.colors.textSecondary,
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: context.colors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppIcon(Icons.tune_rounded, size: 16, color: context.colors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              context.l10n.printSpecsFormat,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: context.colors.textSecondary,
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
                                title: context.l10n.a4TomyDecal,
                                subtitle: context.l10n.standardGridSheet,
                                icon: Icons.grid_view_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildPrintFormatOption(
                                index: 1,
                                title: context.l10n.thermal50x30mm,
                                subtitle: context.l10n.singleRollLabel,
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
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: context.colors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: context.colors.accent.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: AppIcon(headerIcon, color: context.colors.textPrimary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                headerTitle,
                                style: TextStyle(
                                  color: context.colors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                headerSubtitle,
                                style: TextStyle(
                                  color: context.colors.textSecondary,
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
              color: context.colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: context.colors.cardShadow,
            ),
            child: Row(
              children: [
                // Print / Preview button
                Expanded(
                  flex: 1,
                  child: FilledButton.icon(
                    onPressed: _isGeneratingPdf ? null : () => _previewAndPrint(headerTitle, entries),
                    icon: const AppIcon(Icons.print_outlined, size: 18),
                    label: Text(context.l10n.printPreview),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.fill,
                      foregroundColor: context.colors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                          )
                        : const AppIcon(Icons.picture_as_pdf_rounded, size: 18),
                    label: Text(_isGeneratingPdf ? context.l10n.generatingPdf : context.l10n.exportPdfSaveShare),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.accent,
                      foregroundColor: context.colors.onAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
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
