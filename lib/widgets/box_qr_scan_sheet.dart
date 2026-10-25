import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';

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
        'No storage box found with code "$code". Please scan a valid box QR label.',
      );
    }
  }

  void _showTestPresetsModal(InventoryProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Test Box QR Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Simulate scanning a physical box QR sticker:',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
                      leading: Icon(b.type.icon, size: 20, color: const Color(0xFF18181B)),
                      title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('$breadcrumb (${b.label})', style: const TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.qr_code_2_rounded, size: 20),
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
          title: const Text('Enter Box Label / QR', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _manualInputController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. loc_electronics_box',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF18181B),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final text = _manualInputController.text.trim();
                Navigator.pop(ctx);
                if (text.isNotEmpty) {
                  _processScannedCode(text);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    return Material(
      color: Colors.black,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.82,
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Box QR Code',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Point camera at target box sticker',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Torch toggle
                    IconButton(
                      icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                      onPressed: () => _controller.toggleTorch(),
                    ),
                  ],
                ),
              ),

              // Camera Viewport & Overlay
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                    ),

                    // Viewfinder styling
                    Center(
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            // Corner markers
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF10B981), width: 4),
                                    left: BorderSide(color: Color(0xFF10B981), width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF10B981), width: 4),
                                    right: BorderSide(color: Color(0xFF10B981), width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFF10B981), width: 4),
                                    left: BorderSide(color: Color(0xFF10B981), width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFF10B981), width: 4),
                                    right: BorderSide(color: Color(0xFF10B981), width: 4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Processing overlay
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

              // Bottom control & result panel
              Container(
                color: const Color(0xFF18181B),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_detectedBox != null) ...[
                      // Detected box card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27272A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _detectedBox!.type.icon,
                                color: const Color(0xFF10B981),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _detectedBox!.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    provider.getBreadcrumbString(_detectedBox!.id),
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Confirm button
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () => setState(() => _detectedBox = null),
                              child: const Text('Scan Again'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () => Navigator.pop(context, _detectedBox),
                              child: const Text('Move to this Box', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Helper text & test presets buttons
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.white70),
                            onPressed: () => _showTestPresetsModal(provider),
                            icon: const Icon(Icons.science_outlined, size: 16),
                            label: const Text('Test with Presets', style: TextStyle(fontSize: 12)),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.white70),
                            onPressed: _showManualInputDialog,
                            icon: const Icon(Icons.keyboard_outlined, size: 16),
                            label: const Text('Enter Code', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
