import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../providers/inventory_provider.dart';
import '../utils/e2e.dart';
import 'app_feedback.dart';
import 'barcode_pdf_builder.dart';
import 'box_barcode_entry.dart';
import 'export_barcodes_parts.dart';
import 'soft_sheet.dart';
import 'soft_ui.dart';

/// Bottom sheet that exports QR labels for storage containers (no items, no IDs).
class ExportBarcodesSheet extends StatefulWidget {
  /// If [boxId] is null, exports all boxes in the inventory.
  final String? boxId;

  const ExportBarcodesSheet({super.key, this.boxId});

  /// Opens the sheet for a specific box (with a scope toggle for all boxes).
  static Future<void> show(BuildContext context, String boxId) =>
      _open(context, boxId);

  /// Opens the sheet for ALL boxes across the inventory.
  static Future<void> showAll(BuildContext context) => _open(context, null);

  static Future<void> _open(BuildContext context, String? boxId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => ExportBarcodesSheet(boxId: boxId),
    );
  }

  @override
  State<ExportBarcodesSheet> createState() => _ExportBarcodesSheetState();
}

class _ExportBarcodesSheetState extends State<ExportBarcodesSheet> {
  bool _busy = false;
  int _format = 0; // 0: A4 decal sheet, 1: thermal 50x30 label
  late bool _exportAll;

  @override
  void initState() {
    super.initState();
    _exportAll = widget.boxId == null;
  }

  String _safe(String title) {
    final s = title.replaceAll(RegExp(r'[^\w\s-]'), '_').trim();
    return s.isEmpty ? 'Boxes' : s;
  }

  Future<void> _exportPdf(String title, List<BoxBarcodeEntry> entries) async {
    setState(() => _busy = true);
    try {
      final bytes = await generateBarcodePdf(
        title: title,
        printFormat: _format,
        entries: entries,
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${_safe(title)}_barcodes.pdf',
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
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _preview(String title, List<BoxBarcodeEntry> entries) async {
    setState(() => _busy = true);
    try {
      await Printing.layoutPdf(
        name: '${_safe(title)}_barcodes',
        onLayout: (PdfPageFormat format) async => await generateBarcodePdf(
          title: title,
          printFormat: _format,
          entries: entries,
        ),
      );
    } catch (e) {
      debugPrint('export_barcodes_sheet.dart error: $e');
      if (mounted) {
        AppFeedback.showError(context, context.l10n.couldnTOpenThePrint);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = Provider.of<InventoryProvider>(context);

    final allEntries = [
      for (final b in provider.boxes)
        BoxBarcodeEntry(
          name: b.name,
          code: b.label.isNotEmpty ? b.label : b.id,
        ),
    ];
    final entries = <BoxBarcodeEntry>[];
    String headerTitle;
    String? boxName;
    int insideCount = 0;

    if (_exportAll || widget.boxId == null) {
      headerTitle = l10n.allStorageLocations;
      entries.addAll(allEntries);
    } else {
      final target = provider.getBoxById(widget.boxId!);
      if (target == null) {
        return SoftSheet(
          title: l10n.exportBarcodes,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(child: Text(l10n.boxNotFound)),
          ),
        );
      }
      headerTitle = target.name;
      boxName = target.name;
      entries.add(
        BoxBarcodeEntry(
          name: target.name,
          code: target.label.isNotEmpty ? target.label : target.id,
        ),
      );
      for (final sub in provider.getBoxesIn(target.id)) {
        insideCount++;
        entries.add(
          BoxBarcodeEntry(
            name: sub.name,
            code: sub.label.isNotEmpty ? sub.label : sub.id,
          ),
        );
      }
    }

    // Box name for the scope card even when currently showing "all".
    if (widget.boxId != null && boxName == null) {
      final t = provider.getBoxById(widget.boxId!);
      boxName = t?.name;
      if (t != null) insideCount = provider.getBoxesIn(t.id).length;
    }

    return Material(
      type: MaterialType.transparency,
      child: SoftSheet(
        title: l10n.exportSheetTitle,
        subtitle: l10n.exportSheetSubtitle,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.boxId != null) ...[
                ExportSectionLabel(l10n.exportWhatToExport),
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: e2eId(
                          'export_scope_all',
                          ExportOptionCard(
                            title: l10n.exportAllLocations,
                            subtitle: l10n.exportLabelsCount(allEntries.length),
                            selected: _exportAll,
                            onTap: () => setState(() => _exportAll = true),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: e2eId(
                          'export_scope_box',
                          ExportOptionCard(
                            title: boxName ?? l10n.thisContainer,
                            subtitle: l10n.exportInsideLabels(
                              insideCount,
                              insideCount + 1,
                            ),
                            selected: !_exportAll,
                            onTap: () => setState(() => _exportAll = false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ExportSectionLabel(l10n.exportFormat),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: e2eId(
                        'export_format_a4',
                        ExportOptionCard(
                          leading: const A4Thumb(),
                          title: l10n.exportA4Sheet,
                          subtitle: l10n.exportA4PerPage,
                          selected: _format == 0,
                          onTap: () => setState(() => _format = 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: e2eId(
                        'export_format_thermal',
                        ExportOptionCard(
                          leading: const ThermalThumb(),
                          title: l10n.exportThermalTitle,
                          subtitle: l10n.exportThermalPer,
                          selected: _format == 1,
                          onTap: () => setState(() => _format = 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_busy) ...[
                const SizedBox(height: 16),
                ExportProgressCard(label: l10n.generatingPdf),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: e2eId(
                      'export_barcodes_preview',
                      SoftButton(
                        label: l10n.exportPrintPreview,
                        icon: Icons.print_outlined,
                        style: SoftButtonStyle.secondary,
                        expand: true,
                        onPressed: _busy
                            ? null
                            : () => _preview(headerTitle, entries),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: e2eId(
                      'export_barcodes_submit',
                      SoftButton(
                        label: l10n.exportSaveShare,
                        icon: Icons.add_rounded,
                        expand: true,
                        onPressed: _busy
                            ? null
                            : () => _exportPdf(headerTitle, entries),
                      ),
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
}
