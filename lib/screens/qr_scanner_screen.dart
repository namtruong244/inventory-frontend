import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../widgets/app_feedback.dart';
import 'box_details_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? label = barcodes.first.rawValue;
      if (label != null) {
        _processScannedLabel(label);
      }
    }
  }

  void _processScannedLabel(String label) {
    setState(() {
      _isProcessing = true;
    });

    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final box = provider.getBoxByLabel(label);

    if (box != null) {
      _controller.stop();
      AppFeedback.showSuccess(context, 'Box found: "${box.name}"');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BoxDetailsScreen(boxId: box.id),
        ),
      );
    } else {
      AppFeedback.showError(context, 'Box not found for QR code: "$label"');
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Box QR'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
