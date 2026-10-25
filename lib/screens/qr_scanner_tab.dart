import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import 'box_details_screen.dart';
import 'item_create_screen.dart';
import 'item_details_screen.dart';

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

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? label = barcodes.first.rawValue;
      if (label != null) {
        _processCode(label);
      }
    }
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
        if (provider.vibrateOnScan) HapticFeedback.mediumImpact();
        AppFeedback.showSuccess(context, 'Container found: "${box.name}"');
        _navigateToBox(box);
        return;
      } else if (lookup.isItem) {
        final item = provider.getItemById(lookup.id) ??
            provider.getItemByBarcode(code) ??
            Item.fromJson(lookup.payload);
        if (provider.vibrateOnScan) HapticFeedback.mediumImpact();
        AppFeedback.showSuccess(context, 'Item found: "${item.name}"');
        _navigateToItem(item);
        return;
      }
    }

    // 2. Local fallback check
    final box = provider.getBoxByLabel(code);
    if (box != null) {
      if (provider.vibrateOnScan) HapticFeedback.mediumImpact();
      AppFeedback.showSuccess(context, 'Container found: "${box.name}"');
      _navigateToBox(box);
      return;
    }

    final item = provider.getItemByBarcode(code) ?? provider.getItemById(code);
    if (item != null) {
      if (provider.vibrateOnScan) HapticFeedback.mediumImpact();
      AppFeedback.showSuccess(context, 'Item found: "${item.name}"');
      _navigateToItem(item);
      return;
    }

    // 3. Not found: Offer to create item with this barcode
    _handleUnrecognizedCode(code, provider);
  }

  void _navigateToBox(Box box) {
    if (widget.isFullScreen || Navigator.canPop(context)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BoxDetailsScreen(boxId: box.id),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BoxDetailsScreen(boxId: box.id),
        ),
      ).then((_) {
        if (mounted) setState(() => _isProcessing = false);
      });
    }
  }

  void _navigateToItem(Item item) {
    if (widget.isFullScreen || Navigator.canPop(context)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ItemDetailsScreen(itemId: item.id),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItemDetailsScreen(itemId: item.id),
        ),
      ).then((_) {
        if (mounted) setState(() => _isProcessing = false);
      });
    }
  }

  void _handleUnrecognizedCode(String code, InventoryProvider provider) async {
    final rootBoxes = provider.boxes;
    final defaultBoxId = rootBoxes.isNotEmpty ? rootBoxes.first.id : '';

    final shouldCreate = await AppFeedback.showConfirmDialog(
      context,
      title: 'Scanned Code: $code',
      message: 'No storage box or item currently matches this code. Would you like to create a new item with this barcode?',
      confirmLabel: 'Add New Item',
      cancelLabel: 'Keep Scanning',
      icon: Icons.qr_code_scanner_rounded,
    );

    if (shouldCreate && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItemCreateScreen(
            boxId: defaultBoxId,
            initialBarcode: code,
          ),
        ),
      ).then((_) {
        if (mounted) setState(() => _isProcessing = false);
      });
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _isProcessing = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = widget.isFullScreen || Navigator.canPop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: canPop
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF18181B)),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Scan QR & Barcode',
                style: TextStyle(
                  color: Color(0xFF18181B),
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
                'Scan QR & Barcode',
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeTab(
                      isBarcode: false,
                      icon: Icons.qr_code_2_rounded,
                      label: 'Location QR',
                    ),
                  ),
                  Expanded(
                    child: _buildModeTab(
                      isBarcode: true,
                      icon: Icons.barcode_reader,
                      label: 'Product Barcode',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Text(
              _isBarcodeMode
                  ? 'Scan product barcode (UPC/EAN) to auto-fill or search in inventory'
                  : 'Point camera at container QR code to open details and view all contents',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
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
                color: Colors.white,
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
                        'Enter Code Manually',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Label ID or Barcode',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF18181B),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualController,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF18181B),
                          ),
                          decoration: InputDecoration(
                            hintText: _isBarcodeMode ? 'e.g. 194253714201' : 'e.g. elec_001, loc_floor_1',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA1A1AA),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF4F4F6),
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
                          backgroundColor: const Color(0xFF18181B),
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

                  // Quick test chips
                  Consumer<InventoryProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Sample Codes (Tap to Test):',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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

    return GestureDetector(
      onTap: () => setState(() => _isBarcodeMode = isBarcode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF18181B) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade600,
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
      backgroundColor: const Color(0xFFF4F4F6),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () {
        _manualController.text = code;
        _processCode(code);
      },
    );
  }
}
