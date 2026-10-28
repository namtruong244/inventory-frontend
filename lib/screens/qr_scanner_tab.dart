import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
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
import '../widgets/scan_glyphs.dart';
import '../widgets/tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../widgets/app_icon.dart';

class QRScannerTab extends StatefulWidget {
  final bool isFullScreen;

  const QRScannerTab({super.key, this.isFullScreen = false});

  @override
  State<QRScannerTab> createState() => _QRScannerTabState();
}

class _QRScannerTabState extends State<QRScannerTab> {
  final MobileScannerController _controller = MobileScannerController();
  final TextEditingController _manualController = TextEditingController();
  bool _isProcessing = false;
  bool _isBarcodeMode = false; // false = QR Location mode, true = Product Barcode mode

  @override
  void dispose() {
    _controller.dispose();
    _manualController.dispose();
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
        .where((c) => c != _lastCode || now.difference(_lastSeenAt) >= _rescanGap)
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
        final box = provider.getBoxById(lookup.id) ??
            provider.getBoxByLabel(code) ??
            Box.fromJson(lookup.payload);
        return _openResult(provider, box: box);
      } else if (lookup.isItem) {
        final item = provider.getItemById(lookup.id) ??
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
  Future<void> _openResult(InventoryProvider provider, {Box? box, Item? item}) async {
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
        title: box != null ? l10n.scanFoundContainer(name) : l10n.scanFoundItem(name),
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

  Future<void> _handleUnrecognizedCode(String code, InventoryProvider provider) async {
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
    final suggested = _lastBoxId != null && provider.getBoxById(_lastBoxId!) != null
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

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final canPop = widget.isFullScreen || Navigator.canPop(context);
    final reticleW = _isBarcodeMode ? 280.0 : 230.0;
    final reticleH = _isBarcodeMode ? 150.0 : 230.0;

    // Camera fills the screen; controls float on top and the bottom card holds
    // the mode switch and manual entry, within thumb reach.
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Soft shade behind the top controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.35),
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: reticleW,
                height: reticleH,
                child: CustomPaint(painter: _ReticlePainter(c.accent)),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  if (canPop)
                    _glassButton(
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      onTap: () => Navigator.pop(context),
                      child: const ScanGlyph(ScanGlyphType.back, color: Colors.white),
                    )
                  else
                    const SizedBox(width: 44),
                  Expanded(
                    child: Text(
                      l10n.scanTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  ValueListenableBuilder<MobileScannerState>(
                    valueListenable: _controller,
                    builder: (context, state, _) {
                      if (state.torchState == TorchState.unavailable) return const SizedBox(width: 44);
                      final on = state.torchState == TorchState.on;
                      return _glassButton(
                        tooltip: context.l10n.flashlight,
                        onTap: _controller.toggleTorch,
                        highlighted: on,
                        child: ScanGlyph(
                          on ? ScanGlyphType.flashOn : ScanGlyphType.flashOff,
                          color: on ? c.onAccent : Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              reverse: true,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).padding.bottom),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: c.cardShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: c.fill, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModeTab(
                              isBarcode: false,
                              icon: Icons.qr_code_2_rounded,
                              label: l10n.scanModeLocation,
                            ),
                          ),
                          Expanded(
                            child: _buildModeTab(
                              isBarcode: true,
                              icon: Icons.barcode_reader,
                              label: l10n.scanModeProduct,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isBarcodeMode ? l10n.scanHintProduct : l10n.scanHintLocation,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    // Manual entry is secondary, so it sits behind a drill-down row.
                    Tappable(
                      semanticLabel: l10n.scanManualTitle,
                      onTap: () => setState(() => _manualOpen = !_manualOpen),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(color: c.fill, borderRadius: BorderRadius.circular(18)),
                        child: Row(
                          children: [
                            AppIcon(Icons.keyboard_outlined, size: 20, color: c.textPrimary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.scanManualTitle,
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: c.textPrimary),
                              ),
                            ),
                            AppIcon(
                              _manualOpen ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded,
                              size: 22,
                              color: c.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_manualOpen) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _manualController,
                              autofocus: true,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary),
                              decoration: InputDecoration(
                                hintText: l10n.scanManualLabel,
                                fillColor: c.fill,
                              ),
                              onSubmitted: (val) {
                                if (val.trim().isNotEmpty) _processCode(val.trim());
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Tappable(
                            semanticLabel: context.l10n.commonSearch,
                            onTap: () {
                              if (_manualController.text.trim().isNotEmpty) {
                                _processCode(_manualController.text.trim());
                              }
                            },
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(18)),
                              child: AppIcon(Icons.search_rounded, size: 22, color: c.onAccent),
                            ),
                          ),
                        ],
                      ),
                      // Sample codes for development only; they mean nothing to real users.
                      if (kDebugMode) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildQuickChip('elec_001', 'elec_001 (Box)'),
                            _buildQuickChip('box_game_01', 'box_game_01 (Drawer)'),
                            _buildQuickChip('194253714201', '194253714201 (MacBook UPC)'),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _manualOpen = false;

  Widget _glassButton({
    required String tooltip,
    required VoidCallback onTap,
    required Widget child,
    bool highlighted = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Tappable(
        semanticLabel: tooltip,
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: highlighted ? context.colors.accent : Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildModeTab({required bool isBarcode, required IconData icon, required String label}) {
    final isSelected = _isBarcodeMode == isBarcode;
    final c = context.colors;

    return Tappable(
      semanticLabel: label,
      onTap: () => setState(() => _isBarcodeMode = isBarcode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? c.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 18, color: isSelected ? c.onAccent : c.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? c.onAccent : c.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String code, String label) {
    return ActionChip(
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      backgroundColor: context.colors.fill,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () {
        _manualController.text = code;
        _processCode(code);
      },
    );
  }
}

/// Four rounded corner brackets in the accent color.
class _ReticlePainter extends CustomPainter {
  final Color color;
  _ReticlePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const len = 34.0, r = 18.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(0, len)..lineTo(0, r)..quadraticBezierTo(0, 0, r, 0)..lineTo(len, 0)
      ..moveTo(w - len, 0)..lineTo(w - r, 0)..quadraticBezierTo(w, 0, w, r)..lineTo(w, len)
      ..moveTo(w, h - len)..lineTo(w, h - r)..quadraticBezierTo(w, h, w - r, h)..lineTo(w - len, h)
      ..moveTo(len, h)..lineTo(r, h)..quadraticBezierTo(0, h, 0, h - r)..lineTo(0, h - len);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ReticlePainter old) => old.color != color;
}
