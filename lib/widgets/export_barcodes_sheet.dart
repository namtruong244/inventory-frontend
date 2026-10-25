import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../providers/inventory_provider.dart';
import 'app_feedback.dart';

/// Full-screen sheet that exports QR codes for storage containers / boxes (no items, no IDs).
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

  /// Generates a print-ready multi-page A4 PDF containing only Box QR codes & Box names
  Future<Uint8List> _generatePdf({
    required String title,
    required List<_BoxBarcodeEntry> entries,
  }) async {
    final pdf = pw.Document();

    // Load Unicode Inter font with fallback to standard Helvetica
    pw.Font? regularFont;
    pw.Font? boldFont;
    try {
      regularFont = await PdfGoogleFonts.interRegular();
      boldFont = await PdfGoogleFonts.interBold();
    } catch (_) {
      regularFont = null;
      boldFont = null;
    }

    if (_selectedPrintFormat == 1) {
      // Thermal 50x30mm Single Label Format
      final thermalFormat = PdfPageFormat(
        50 * PdfPageFormat.mm,
        30 * PdfPageFormat.mm,
        marginAll: 2.5 * PdfPageFormat.mm,
      );
      for (final entry in entries) {
        pdf.addPage(
          pw.Page(
            pageFormat: thermalFormat,
            build: (context) {
              return pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                padding: const pw.EdgeInsets.all(3),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: entry.code,
                      width: 22 * PdfPageFormat.mm,
                      height: 22 * PdfPageFormat.mm,
                    ),
                    pw.SizedBox(width: 2.5 * PdfPageFormat.mm),
                    pw.Expanded(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            entry.name,
                            style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                            maxLines: 2,
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Personal Inventory',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 5.5,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
      return pdf.save();
    }

    final dateStr = DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          title,
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey900,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Storage Box Labels - ${entries.length} Containers',
                          style: pw.TextStyle(
                            font: regularFont,
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        '${entries.length} Labels',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey900,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        dateStr,
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 8.5,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 12),
            ],
          );
        },
        footer: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 10),
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Personal Inventory - Storage QR Labels',
                  style: pw.TextStyle(font: regularFont, fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(font: regularFont, fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
        build: (context) {
          return [
            pw.Wrap(
              spacing: 12,
              runSpacing: 12,
              children: entries.map((entry) {
                return pw.Container(
                  width: 172,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                  ),
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Crisp Vector QR Code
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: entry.code,
                        width: 85,
                        height: 85,
                      ),
                      pw.SizedBox(height: 8),

                      // Box Name ONLY
                      pw.Text(
                        entry.name,
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                        maxLines: 2,
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Exports the PDF file and opens system share sheet (Save to Files, AirDrop, etc.)
  Future<void> _exportPdf(String title, List<_BoxBarcodeEntry> entries) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final pdfBytes = await _generatePdf(title: title, entries: entries);
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
  Future<void> _previewAndPrint(String title, List<_BoxBarcodeEntry> entries) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final safeName = title.replaceAll(RegExp(r'[^\w\s-]'), '_').trim();
      final fileName = '${safeName.isEmpty ? 'Boxes' : safeName}_barcodes';

      await Printing.layoutPdf(
        name: fileName,
        onLayout: (PdfPageFormat format) async => await _generatePdf(title: title, entries: entries),
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

  /// Captures on-screen grid as PNG image
  Future<void> _exportAsImage() async {
    setState(() => _isExportingImage = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) {
          AppFeedback.showError(context, 'Failed to capture barcode grid');
        }
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        if (mounted) {
          AppFeedback.showError(context, 'Failed to generate image');
        }
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();

      if (mounted) {
        _showExportedImagePreview(pngBytes);
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Export failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingImage = false);
      }
    }
  }

  void _showExportedImagePreview(Uint8List pngBytes) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Barcode Image Ready',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF18181B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'High-resolution PNG image of the box QR codes.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  pngBytes,
                  fit: BoxFit.contain,
                  height: 280,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    AppFeedback.showSuccess(context, 'Barcode image captured');
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Done'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF18181B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<InventoryProvider>(context);

    // Prepare entries: BOXES ONLY (no items, no IDs on label)
    final List<_BoxBarcodeEntry> entries = [];
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
        entries.add(_BoxBarcodeEntry(name: b.name, code: code));
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
      entries.add(_BoxBarcodeEntry(
        name: targetBox.name,
        code: targetBox.label.isNotEmpty ? targetBox.label : targetBox.id,
      ));

      // Add sub-boxes
      for (final sub in subBoxes) {
        entries.add(_BoxBarcodeEntry(
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

  Widget _buildPrintFormatOption({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPrintFormat == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPrintFormat = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF18181B) : const Color(0xFFE4E4E7),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : const Color(0xFF18181B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF18181B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white70 : const Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodeCard(_BoxBarcodeEntry entry) {
    return Container(
      width: 162,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4D4D8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cut guide indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.content_cut_rounded, size: 10, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                'CUT GUIDE',
                style: TextStyle(
                  fontSize: 8.5,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Crisp QR Code
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: QrImageView(
              data: entry.code,
              version: QrVersions.auto,
              size: 108,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 8),

          // Box Name ONLY (No ID)
          Text(
            entry.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF18181B),
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Internal data class for a single box barcode entry
class _BoxBarcodeEntry {
  final String name; // Box Name
  final String code; // QR Code string

  _BoxBarcodeEntry({
    required this.name,
    required this.code,
  });
}
