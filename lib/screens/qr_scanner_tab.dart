import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/location_picker_sheet.dart';
import 'box_details_screen.dart';
import 'item_create_screen.dart';
import 'item_details_screen.dart';
import '../widgets/app_icon.dart';
import '../widgets/scan_glyphs.dart';
import '../widgets/tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

class QRScannerTab extends StatefulWidget {
  final bool isFullScreen;

  const QRScannerTab({super.key, this.isFullScreen = false});

  @override
  State<QRScannerTab> createState() => _QRScannerTabState();
}

class _QRScannerTabState extends State<QRScannerTab> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// A code that is still in front of the camera is ignored until the camera
  /// has not seen it for this long (or sees a different code).
  static const _rescanGap = Duration(seconds: 3);

  /// Last location the user scanned or picked; suggested for unknown codes.
  static String? _lastBoxId;

  String? _lastCode;
  DateTime _lastSeenAt = DateTime.fromMillisecondsSinceEpoch(0);

  void _onDetect(BarcodeCapture capture) {
    final now = DateTime.now();
    final codes = capture.barcodes
        .map((b) => b.rawValue?.trim())
        .whereType<String>()
        .where((c) => c.isNotEmpty)
        .toList();
    if (codes.isEmpty) return;

    final fresh = codes
        .where(
          (c) => c != _lastCode || now.difference(_lastSeenAt) >= _rescanGap,
        )
        .toList();
    if (codes.contains(_lastCode)) _lastSeenAt = now;
    if (_isProcessing || fresh.isEmpty) return;

    _lastCode = fresh.first;
    _lastSeenAt = now;
    _processCode(fresh.first);
  }

  void _resume() {
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _processCode(String rawCode) async {
    setState(() => _isProcessing = true);
    final code = rawCode.trim();
    final provider = Provider.of<InventoryProvider>(context, listen: false);

    // 1. Try smart backend lookup /api/v1/scan/lookup
    final lookup = await provider.lookupScanCode(code);
    if (!mounted) return;

    if (lookup != null) {
      if (lookup.isBox) {
        final box =
            provider.getBoxById(lookup.id) ??
            provider.getBoxByLabel(code) ??
            Box.fromJson(lookup.payload);
        return _openResult(provider, box: box);
      } else if (lookup.isItem) {
        final item =
            provider.getItemById(lookup.id) ??
            provider.getItemByBarcode(code) ??
            Item.fromJson(lookup.payload);
        return _openResult(provider, item: item);
      }
    }

    // 2. Local fallback check
    final box = provider.getBoxByLabel(code);
    if (box != null) return _openResult(provider, box: box);

    final item = provider.getItemByBarcode(code) ?? provider.getItemById(code);
    if (item != null) return _openResult(provider, item: item);

    // 3. Not found: Offer to create item with this barcode
    await _handleUnrecognizedCode(code, provider);
  }

  /// Shows a matched box/item, honouring the "Auto-Open Details" setting.
  Future<void> _openResult(
    InventoryProvider provider, {
    Box? box,
    Item? item,
  }) async {
    final l10n = AppLocalizations.of(context);
    final name = box?.name ?? item!.name;
    provider.playScanFeedback();
    _lastBoxId = box?.id ?? item!.boxId;

    if (provider.autoOpenOnScan) {
      AppFeedback.showSuccess(
        context,
        box != null ? l10n.scanFoundContainer(name) : l10n.scanFoundItem(name),
      );
    } else {
      final open = await AppFeedback.showConfirmDialog(
        context,
        title: box != null
            ? l10n.scanFoundContainer(name)
            : l10n.scanFoundItem(name),
        message: l10n.scanOpenDetailsPrompt,
        confirmLabel: l10n.scanOpen,
        cancelLabel: l10n.scanKeepScanning,
        icon: Icons.qr_code_scanner_rounded,
      );
      if (!open || !mounted) return _resume();
    }
    if (box != null) {
      _navigate(BoxDetailsScreen(boxId: box.id));
    } else {
      _navigate(ItemDetailsScreen(itemId: item!.id));
    }
  }

  void _navigate(Widget screen) {
    final route = MaterialPageRoute(builder: (_) => screen);
    if (widget.isFullScreen || Navigator.canPop(context)) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.push(context, route).then((_) => _resume());
    }
  }

  Future<void> _handleUnrecognizedCode(
    String code,
    InventoryProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context);
    final shouldCreate = await AppFeedback.showConfirmDialog(
      context,
      title: l10n.scanUnknownTitle(code),
      message: l10n.scanUnknownMessage,
      confirmLabel: l10n.scanAddNewItem,
      cancelLabel: l10n.scanKeepScanning,
      icon: Icons.qr_code_scanner_rounded,
    );
    if (!shouldCreate || !mounted) return _resume();

    // Never guess a location: the user picks it, starting from the last one used.
    final suggested =
        _lastBoxId != null && provider.getBoxById(_lastBoxId!) != null
        ? _lastBoxId
        : null;
    final box = await LocationPickerSheet.show(
      context,
      initialBoxId: suggested,
      title: l10n.scanPickLocationTitle,
      subtitle: l10n.scanPickLocationSubtitle,
      confirmButtonText: l10n.scanPickLocationConfirm,
    );
    if (box == null || !mounted) return _resume();
    _lastBoxId = box.id;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemCreateScreen(boxId: box.id, initialBarcode: code),
      ),
    );
    _resume();
  }

  static const _blobSize = 150.0;
  static const _blobCenterX = 62.0;

  /// Forgets the last code so the code in front of the camera is read again.
  void _rescan() {
    _lastCode = null;
    _resume();
  }

  Future<void> _pickFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;
    final capture = await _controller.analyzeImage(image.path);
    if (!mounted) return;
    final code = capture?.barcodes
        .map((b) => b.rawValue?.trim())
        .whereType<String>()
        .firstOrNull;
    if (code == null || code.isEmpty) {
      AppFeedback.showError(context, context.l10n.noQrInImage);
    } else if (!_isProcessing) {
      _processCode(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final canPop = widget.isFullScreen || Navigator.canPop(context);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  _iconButton(
                    tooltip: MaterialLocalizations.of(context)
                        .backButtonTooltip,
                    onTap: canPop ? () => Navigator.pop(context) : null,
                    child: canPop
                        ? ScanGlyph(ScanGlyphType.back, color: c.textPrimary)
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      l10n.boxScanTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(52, 36, 52, 36),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            MobileScanner(
                              controller: _controller,
                              onDetect: _onDetect,
                            ),
                            if (_isProcessing)
                              const ColoredBox(
                                color: Colors.black45,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: ScanFrameBrackets(color: c.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                l10n.boxScanHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 18,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(
              height: _blobSize,
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: _blobSize,
                    child: Tappable(
                      semanticLabel: l10n.scanAgain,
                      onTap: _rescan,
                      child: CustomPaint(
                        painter: _ScanBlobPainter(
                          accent: c.primary,
                          inner: c.surface,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: _blobSize - 2 * _blobCenterX,
                          ),
                          child: Center(
                            child: AppIcon(
                              Icons.qr_code_scanner_rounded,
                              color: c.primary,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    top: 0,
                    bottom: 0,
                    child: Row(
                      children: [
                        _roundButton(
                          tooltip: l10n.commonGallery,
                          onTap: _pickFromGallery,
                          child: ScanGlyph(
                            ScanGlyphType.gallery,
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ValueListenableBuilder<MobileScannerState>(
                          valueListenable: _controller,
                          builder: (context, state, _) {
                            if (state.torchState == TorchState.unavailable) {
                              return const SizedBox.shrink();
                            }
                            final on = state.torchState == TorchState.on;
                            return _roundButton(
                              tooltip: l10n.flashlight,
                              onTap: _controller.toggleTorch,
                              child: ScanGlyph(
                                on
                                    ? ScanGlyphType.flashOn
                                    : ScanGlyphType.flashOff,
                                color: c.textPrimary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 0 : 8),
          ],
        ),
      ),
    );
  }

  Widget _iconButton({
    required String tooltip,
    required VoidCallback? onTap,
    required Widget? child,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: child == null
          ? null
          : Tooltip(
              message: tooltip,
              child: Tappable(
                semanticLabel: tooltip,
                onTap: onTap!,
                child: Center(child: child),
              ),
            ),
    );
  }

  Widget _roundButton({
    required String tooltip,
    required VoidCallback onTap,
    required Widget child,
  }) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Tappable(
        semanticLabel: tooltip,
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: c.surface,
            shape: BoxShape.circle,
            boxShadow: c.cardShadow,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Accent disc that flows into the right screen edge, with a surface-colored
/// disc inside it that holds the scan icon.
class _ScanBlobPainter extends CustomPainter {
  final Color accent;
  final Color inner;
  _ScanBlobPainter({required this.accent, required this.inner});

  @override
  void paint(Canvas canvas, Size size) {
    // Ring (r - ri = 12) whose outline eases out of the circle with a slight
    // curve that keeps bending until it meets the screen edge (no straight run).
    const cx = 62.0, r = 56.0, ri = 44.0;
    const joinDy = 48.0; // where the ring outline starts easing into the neck
    final w = size.width, h = size.height, cy = h / 2;
    final joinDx = math.sqrt(r * r - joinDy * joinDy);
    final blob = Path()
      ..moveTo(cx + joinDx, cy - joinDy)
      ..arcToPoint(
        Offset(cx + joinDx, cy + joinDy),
        radius: const Radius.circular(r),
        largeArc: true,
        clockwise: false,
      )
      ..cubicTo(cx + 46, cy + 40.5, cx + 78, cy + 50, w, h)
      ..lineTo(w, 0)
      ..cubicTo(cx + 78, cy - 50, cx + 46, cy - 40.5, cx + joinDx, cy - joinDy)
      ..close();
    canvas.drawPath(blob, Paint()..color = accent);
    canvas.drawCircle(Offset(cx, cy), ri, Paint()..color = inner);
  }

  @override
  bool shouldRepaint(_ScanBlobPainter old) =>
      old.accent != accent || old.inner != inner;
}
