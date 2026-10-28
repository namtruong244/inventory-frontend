import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'scan_glyphs.dart';
import 'tappable.dart';
import 'app_icon.dart';
import 'soft_ui.dart';

/// Specialized QR Scanner bottom sheet to scan box labels directly
class BoxQRScanSheet extends StatefulWidget {
  final Item? item;

  const BoxQRScanSheet({super.key, this.item});

  @override
  State<BoxQRScanSheet> createState() => _BoxQRScanSheetState();
}

class _BoxQRScanSheetState extends State<BoxQRScanSheet> {
  final MobileScannerController _controller = MobileScannerController();
  final TextEditingController _manualInputController = TextEditingController();
  bool _isProcessing = false;
  Box? _detectedBox;

  @override
  void dispose() {
    _controller.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || _detectedBox != null) return;

    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null) {
        _processScannedCode(code);
      }
    }
  }

  void _processScannedCode(String rawCode) {
    setState(() => _isProcessing = true);
    final code = rawCode.trim();
    final provider = Provider.of<InventoryProvider>(context, listen: false);

    // Look up Box by QR label or UUID
    final box = provider.getBoxByLabel(code) ?? provider.getBoxById(code);

    if (box != null) {
      setState(() {
        _detectedBox = box;
        _isProcessing = false;
      });
    } else {
      setState(() => _isProcessing = false);
      AppFeedback.showError(
        context,
        context.l10n.noStorageBoxFoundWith(code),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;
    final capture = await _controller.analyzeImage(image.path);
    if (!mounted) return;
    final code = capture?.barcodes.firstOrNull?.rawValue;
    if (code == null) {
      AppFeedback.showError(context, context.l10n.noQrInImage);
    } else {
      _processScannedCode(code);
    }
  }

  void _showTestPresetsModal(InventoryProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.selectTestBoxQrCode,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.simulateScanningAPhysicalBox,
                style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.boxes.length,
                  itemBuilder: (context, idx) {
                    final b = provider.boxes[idx];
                    final breadcrumb = provider.getBreadcrumbString(b.id);
                    return ListTile(
                      dense: true,
                      leading: AppIcon(b.type.icon, size: 20, color: context.colors.textPrimary),
                      title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('$breadcrumb (${b.label})', style: const TextStyle(fontSize: 11)),
                      trailing: const AppIcon(Icons.qr_code_2_rounded, size: 20),
                      onTap: () {
                        Navigator.pop(ctx);
                        _processScannedCode(b.label);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showManualInputDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(context.l10n.enterBoxLabelQr, style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _manualInputController,
            autofocus: true,
            decoration: InputDecoration(hintText: context.l10n.eGLocElectronicsBox),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.accent,
                foregroundColor: context.colors.onAccent,
                minimumSize: const Size(0, 44),
              ),
              onPressed: () {
                final text = _manualInputController.text.trim();
                Navigator.pop(ctx);
                if (text.isNotEmpty) {
                  _processScannedCode(text);
                }
              },
              child: Text(context.l10n.commonSubmit),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final c = context.colors;

    return Material(
      color: c.background,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              _buildHeader(provider),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: _buildViewfinder(),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: _detectedBox == null
                    ? _buildHint()
                    : _buildResult(provider),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: _detectedBox == null ? _buildControls() : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(InventoryProvider provider) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Row(
        children: [
          _GlyphButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onTap: () => Navigator.pop(context),
            child: ScanGlyph(ScanGlyphType.back, color: c.textPrimary),
          ),
          Expanded(
            child: Text(
              context.l10n.boxScanTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _GlyphButton(
            tooltip: MaterialLocalizations.of(context).showMenuTooltip,
            onTap: () => _showTestPresetsModal(provider),
            child: ScanGlyph(ScanGlyphType.more, color: c.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildViewfinder() {
    final c = context.colors;
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(controller: _controller, onDetect: _onDetect),
                if (_isProcessing)
                  ColoredBox(
                    color: c.background.withValues(alpha: 0.6),
                    child: Center(
                      child: CircularProgressIndicator(color: c.textPrimary, strokeWidth: 2.5),
                    ),
                  ),
              ],
            ),
          ),
        ),
        IgnorePointer(child: ScanFrameBrackets(color: c.textPrimary)),
      ],
    );
  }

  Widget _buildHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 8, 40, 8),
      child: Text(
        context.l10n.boxScanHint,
        textAlign: TextAlign.center,
        style: TextStyle(color: context.colors.textSecondary, fontSize: 14, height: 1.4),
      ),
    );
  }

  Widget _buildControls() {
    final c = context.colors;
    return Row(
      children: [
        _RoundButton(
          tooltip: context.l10n.pickFromGallery,
          onTap: _pickFromGallery,
          color: c.surface,
          child: ScanGlyph(ScanGlyphType.gallery, color: c.textPrimary),
        ),
        const SizedBox(width: 12),
        ValueListenableBuilder<MobileScannerState>(
          valueListenable: _controller,
          builder: (context, state, _) {
            final on = state.torchState == TorchState.on;
            return _RoundButton(
              tooltip: context.l10n.toggleFlash,
              onTap: _controller.toggleTorch,
              color: on ? c.accent : c.surface,
              child: ScanGlyph(
                on ? ScanGlyphType.flashOn : ScanGlyphType.flashOff,
                color: on ? c.onAccent : c.textPrimary,
              ),
            );
          },
        ),
        const Spacer(),
        _RoundButton(
          tooltip: context.l10n.enterCode,
          onTap: _showManualInputDialog,
          color: c.accent,
          diameter: 76,
          child: ScanGlyph(ScanGlyphType.scan, color: c.onAccent, size: 30),
        ),
      ],
    );
  }

  Widget _buildResult(InventoryProvider provider) {
    final c = context.colors;
    final box = _detectedBox!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SoftCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                SoftIconTile(box.type.icon, color: c.textPrimary, background: c.accent.withValues(alpha: 0.45)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        box.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Text(
                        provider.getBreadcrumbString(box.id),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: c.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                AppIcon(Icons.check_circle_rounded, size: 24, color: AppTones.matcha),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: c.fill,
                    foregroundColor: c.textPrimary,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => setState(() => _detectedBox = null),
                  child: Text(context.l10n.scanAgain),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: c.accent,
                    foregroundColor: c.onAccent,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Navigator.pop(context, box),
                  child: Text(
                    context.l10n.moveToThisBox,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlyphButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onTap;
  final Widget child;

  const _GlyphButton({required this.tooltip, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) => Tappable(
        behavior: HitTestBehavior.opaque,
        semanticLabel: tooltip,
        onTap: onTap,
        child: SizedBox(width: 48, height: 48, child: Center(child: child)),
      );
}

class _RoundButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onTap;
  final Color color;
  final double diameter;
  final Widget child;

  const _RoundButton({
    required this.tooltip,
    required this.onTap,
    required this.color,
    required this.child,
    this.diameter = 56,
  });

  @override
  Widget build(BuildContext context) => Tappable(
        semanticLabel: tooltip,
        onTap: onTap,
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(child: child),
        ),
      );
}
