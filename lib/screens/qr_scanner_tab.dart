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
    final theme = Theme.of(context);
    final canPop = widget.isFullScreen || Navigator.canPop(context);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: canPop
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
 tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: ScanGlyph(ScanGlyphType.back, color: context.colors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                AppLocalizations.of(context).scanTitle,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, canPop ? 8 : 16, 20, canPop ? 40 : 120),
          children: [
            if (!canPop) ...[
              Text(
                AppLocalizations.of(context).scanTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
            ],

            // Scanner mode toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeTab(
                      isBarcode: false,
                      icon: Icons.qr_code_2_rounded,
                      label: AppLocalizations.of(context).scanModeLocation,
                    ),
                  ),
                  Expanded(
                    child: _buildModeTab(
                      isBarcode: true,
                      icon: Icons.barcode_reader,
                      label: AppLocalizations.of(context).scanModeProduct,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Text(
              _isBarcodeMode
                  ? AppLocalizations.of(context).scanHintProduct
                  : AppLocalizations.of(context).scanHintLocation,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),

            // Scanner Viewfinder
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                height: 290,
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                    ),
                    // Flashlight, for dark garages and cupboards
                    Positioned(
                      top: 8,
                      right: 8,
                      child: ValueListenableBuilder<MobileScannerState>(
                        valueListenable: _controller,
                        builder: (context, state, _) {
                          if (state.torchState == TorchState.unavailable) return const SizedBox.shrink();
                          final on = state.torchState == TorchState.on;
                          return IconButton.filledTonal(
                            tooltip: context.l10n.flashlight,
                            onPressed: _controller.toggleTorch,
                            icon: ScanGlyph(
                              on ? ScanGlyphType.flashOn : ScanGlyphType.flashOff,
                              color: context.colors.textPrimary,
                            ),
                          );
                        },
                      ),
                    ),
                    // Reticle
                    Center(
                      child: Container(
                        width: _isBarcodeMode ? 260 : 210,
                        height: _isBarcodeMode ? 140 : 210,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    if (_isProcessing)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Manual Input Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.keyboard_outlined, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context).scanManualTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppLocalizations.of(context).scanManualLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualController,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: _isBarcodeMode ? 'e.g. 194253714201' : 'e.g. elec_001, loc_floor_1',
                            hintStyle: TextStyle(
                              color: context.colors.textMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            filled: true,
                            fillColor: context.colors.fill,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) _processCode(val.trim());
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          if (_manualController.text.trim().isNotEmpty) {
                            _processCode(_manualController.text.trim());
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Icon(Icons.search, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sample codes for development only; they mean nothing to real users.
                  if (kDebugMode)
                  Consumer<InventoryProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Sample Codes (Tap to Test):',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildQuickChip('elec_001', 'elec_001 (Box)'),
                              _buildQuickChip('box_game_01', 'box_game_01 (Drawer)'),
                              _buildQuickChip('194253714201', '194253714201 (MacBook UPC)'),
                              _buildQuickChip('300810733877', '300810733877 (Meds Barcode)'),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab({required bool isBarcode, required IconData icon, required String label}) {
    final isSelected = _isBarcodeMode == isBarcode;

    return Tappable(
      onTap: () => setState(() => _isBarcodeMode = isBarcode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : context.colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : context.colors.textSecondary,
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
