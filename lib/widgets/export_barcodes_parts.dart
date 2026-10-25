part of 'export_barcodes_sheet.dart';

/// Format option, barcode card and image export helpers.
extension _ExportBarcodesParts on _ExportBarcodesSheetState {

  Widget _buildPrintFormatOption({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPrintFormat == index;
    return GestureDetector(
      onTap: () => _update(() => _selectedPrintFormat = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF18181B) : const Color(0xFFE4E4E7),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : const Color(0xFF18181B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF18181B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white70 : const Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBarcodeCard(BoxBarcodeEntry entry) {
    return Container(
      width: 162,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4D4D8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cut guide indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.content_cut_rounded, size: 10, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                'CUT GUIDE',
                style: TextStyle(
                  fontSize: 8.5,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Crisp QR Code
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: QrImageView(
              data: entry.code,
              version: QrVersions.auto,
              size: 108,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 8),

          // Box Name ONLY (No ID)
          Text(
            entry.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF18181B),
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  void _showExportedImagePreview(Uint8List pngBytes) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Barcode Image Ready',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF18181B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'High-resolution PNG image of the box QR codes.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  pngBytes,
                  fit: BoxFit.contain,
                  height: 280,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    AppFeedback.showSuccess(context, 'Barcode image captured');
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Done'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF18181B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Captures on-screen grid as PNG image
  Future<void> _exportAsImage() async {
    _update(() => _isExportingImage = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) {
          AppFeedback.showError(context, 'Failed to capture barcode grid');
        }
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        if (mounted) {
          AppFeedback.showError(context, 'Failed to generate image');
        }
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();

      if (mounted) {
        _showExportedImagePreview(pngBytes);
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Export failed: $e');
      }
    } finally {
      if (mounted) {
        _update(() => _isExportingImage = false);
      }
    }
  }
}
