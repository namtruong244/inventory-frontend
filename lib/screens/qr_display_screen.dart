import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../utils/e2e.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_icon.dart';
import '../widgets/barcode_pdf_builder.dart';
import '../widgets/box_barcode_entry.dart';
import '../widgets/qr_display_parts.dart';
import '../widgets/soft_ui.dart';

class QRDisplayScreen extends StatefulWidget {
  final Box box;

  const QRDisplayScreen({super.key, required this.box});

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  bool _busy = false;

  List<BoxBarcodeEntry> get _entries => [
    BoxBarcodeEntry(name: widget.box.name, code: widget.box.label),
  ];

  String get _safeName {
    final s = widget.box.name.replaceAll(RegExp(r'[^\w\s-]'), '_').trim();
    return s.isEmpty ? 'Box' : s;
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await generateBarcodePdf(
        title: widget.box.name,
        printFormat: 1,
        entries: _entries,
      );
      await Printing.sharePdf(bytes: bytes, filename: '${_safeName}_label.pdf');
    } catch (e) {
      debugPrint('qr_display_screen.dart share error: $e');
      if (mounted) {
        AppFeedback.showError(context, context.l10n.couldnTExportThePdf);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _print() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await Printing.layoutPdf(
        name: '${_safeName}_label',
        onLayout: (PdfPageFormat format) => generateBarcodePdf(
          title: widget.box.name,
          printFormat: 1,
          entries: _entries,
        ),
      );
    } catch (e) {
      debugPrint('qr_display_screen.dart print error: $e');
      if (mounted) {
        AppFeedback.showError(context, context.l10n.couldnTOpenThePrint);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final box = widget.box;
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final parent = box.parentId == null
        ? null
        : provider.getBoxById(box.parentId!);
    return Scaffold(
      backgroundColor: c.background,
      appBar: SoftTopAppBar(
        title: context.l10n.boxQrCode,
        actions: [
          e2eId(
            'qr_share',
            SoftCircleButton(
              icon: Icons.share_outlined,
              tooltip: context.l10n.qrShare,
              onTap: _busy ? null : _share,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: c.background,
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Row(
              children: [
                Expanded(
                  child: e2eId(
                    'qr_save_pdf',
                    _CardButton(
                      label: context.l10n.savePdf,
                      icon: Icons.picture_as_pdf_rounded,
                      onPressed: _busy ? null : _share,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: e2eId(
                    'qr_print',
                    SoftButton(
                      label: context.l10n.printLabel,
                      icon: Icons.print_outlined,
                      expand: true,
                      loading: _busy,
                      onPressed: _busy ? null : _print,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        children: [
          QrDisplayCard(box: box, parentName: parent?.name),
          const SizedBox(height: 18),
          ThermalLabelPreview(box: box, parentName: parent?.name),
        ],
      ),
    );
  }
}

/// White shadowed secondary button (design "Save PDF").
class _CardButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _CardButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: c.cardShadow,
        ),
        child: Material(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              height: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(icon, size: 18, color: c.textPrimary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
