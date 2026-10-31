import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/scan_result_sheet.dart';
import '../widgets/scan_viewport.dart';
import '../widgets/soft_ui.dart';
import '../utils/e2e.dart';
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

  /// Result docked at the bottom: a matched box/item or an unknown code.
  Box? _foundBox;
  Item? _foundItem;
  String? _unknownCode;

  bool get _hasResult =>
      _foundBox != null || _foundItem != null || _unknownCode != null;

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
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _foundBox = null;
      _foundItem = null;
      _unknownCode = null;
    });
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
      // "Keep scanning": show the result card and let the user decide.
      setState(() {
        _foundBox = box;
        _foundItem = item;
      });
      return;
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

  /// Unknown code: show the "unknown code" card; "Add new item" continues
  /// in [_createFromUnknown], "Scan again" resumes scanning.
  Future<void> _handleUnrecognizedCode(
    String code,
    InventoryProvider provider,
  ) async {
    setState(() => _unknownCode = code);
  }

  void _openFound() {
    final box = _foundBox, item = _foundItem;
    if (box != null) {
      _navigate(BoxDetailsScreen(boxId: box.id));
    } else if (item != null) {
      _navigate(ItemDetailsScreen(itemId: item.id));
    }
  }

  Future<void> _createFromUnknown() async {
    final code = _unknownCode;
    if (code == null) return;
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);
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

  /// E2E-only entry (see `kE2E`): the simulator has no camera to scan with.
  Future<void> _manualEntry() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _ManualCodeDialog(),
    );
    if (code == null || code.isEmpty || !mounted || _isProcessing) return;
    _processCode(code);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final provider = context.watch<InventoryProvider>();
    final canPop = widget.isFullScreen || Navigator.canPop(context);
    final overlay = Theme.of(context).brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        backgroundColor: c.background,
        body: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: !_hasResult,
                child: Column(
                  children: [
                    _buildAppBar(c, l10n, provider, canPop),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ScanViewport(
                              controller: _controller,
                              onDetect: _onDetect,
                              processing: _isProcessing && !_hasResult,
                            ),
                            if (kE2E)
                              Positioned(
                                left: 0,
                                top: 0,
                                child: e2eId(
                                  'scan_manual',
                                  Tappable(
                                    semanticLabel: l10n.scanManualEntry,
                                    onTap: _manualEntry,
                                    behavior: HitTestBehavior.opaque,
                                    child: const SizedBox(
                                      width: 56,
                                      height: 56,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: _buildControls(c, l10n),
                    ),
                  ],
                ),
              ),
            ),
            if (_hasResult) _buildResult(provider, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
    AppColors c,
    AppLocalizations l10n,
    InventoryProvider provider,
    bool canPop,
  ) {
    final keep = !provider.autoOpenOnScan;
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 24,
            child: canPop
                ? e2eId(
                    'scan_close',
                    SoftCircleButton(
                      icon: Icons.close_rounded,
                      tooltip: MaterialLocalizations.of(context)
                          .closeButtonTooltip,
                      onTap: () => Navigator.pop(context),
                    ),
                  )
                : const SizedBox(width: 44, height: 44),
          ),
          Text(
            l10n.scanQr,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          Positioned(
            right: 24,
            child: e2eId(
              'scan_keep',
              Tappable(
                semanticLabel: l10n.scanKeepScanning,
                onTap: () => provider.setAutoOpenOnScan(keep),
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.only(left: 10, right: 6),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: c.cardShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.scanKeepLabel,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IgnorePointer(child: SoftToggle(value: keep)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(AppColors c, AppLocalizations l10n) {
    Widget control(
      String id,
      String label,
      Widget glyph,
      VoidCallback? onTap, {
      Color? bg,
    }) {
      return e2eId(
        id,
        Tappable(
          semanticLabel: label,
          onTap: onTap,
          child: SizedBox(
            width: 72,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: bg ?? c.surface,
                    shape: BoxShape.circle,
                    boxShadow: c.cardShadow,
                  ),
                  child: Center(child: glyph),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<MobileScannerState>(
          valueListenable: _controller,
          builder: (context, state, _) {
            final available = state.torchState != TorchState.unavailable;
            final on = state.torchState == TorchState.on;
            return Opacity(
              opacity: available ? 1 : 0.45,
              child: control(
                'scan_torch',
                l10n.flashlight,
                AppIcon(
                  Icons.flashlight_on_outlined,
                  size: 22,
                  color: on ? c.onAccent : c.textPrimary,
                ),
                available ? _controller.toggleTorch : null,
                bg: on ? c.accent : null,
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        control(
          'scan_gallery',
          l10n.commonGallery,
          AppIcon(Icons.image_outlined, size: 22, color: c.textPrimary),
          _pickFromGallery,
        ),
      ],
    );
  }

  Widget _buildResult(InventoryProvider provider, AppLocalizations l10n) {
    final box = _foundBox, item = _foundItem;
    if (box != null || item != null) {
      final isBox = box != null;
      return ScanResultSheet(
        icon: isBox ? box.type.icon : Icons.inventory_2_outlined,
        chipLabel: isBox ? l10n.scanChipFoundContainer : l10n.scanChipFoundItem,
        chipIcon: Icons.check_circle_rounded,
        found: true,
        title: isBox ? box.name : item!.name,
        subtitle: provider.getBreadcrumbString(isBox ? box.id : item!.boxId),
        primaryLabel: l10n.scanOpen,
        primaryIcon: Icons.arrow_forward_rounded,
        primaryId: 'scan_open',
        onPrimary: _openFound,
        onScanAgain: _rescan,
      );
    }
    return ScanResultSheet(
      icon: Icons.qr_code_scanner_rounded,
      chipLabel: l10n.scanChipUnknown,
      chipIcon: Icons.help_outline_rounded,
      found: false,
      title: _unknownCode!,
      monoTitle: true,
      subtitle: l10n.scanUnknownHint,
      primaryLabel: l10n.addItem,
      primaryIcon: Icons.add_rounded,
      primaryId: 'scan_unknown_create',
      onPrimary: _createFromUnknown,
      onScanAgain: _rescan,
    );
  }
}

class _ManualCodeDialog extends StatefulWidget {
  const _ManualCodeDialog();

  @override
  State<_ManualCodeDialog> createState() => _ManualCodeDialogState();
}

class _ManualCodeDialogState extends State<_ManualCodeDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.scanManualTitle),
    content: e2eId(
      'scan_manual_input',
      TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: InputDecoration(labelText: context.l10n.scanManualLabel),
      ),
    ),
    actions: [
      e2eId(
        'scan_manual_submit',
        FilledButton(
          onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
          child: Text(context.l10n.commonSubmit),
        ),
      ),
    ],
  );
}
