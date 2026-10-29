part of 'export_barcodes_sheet.dart';

/// Format option, barcode card and image export helpers.
extension _ExportBarcodesParts on _ExportBarcodesSheetState {
  Widget _buildPrintFormatOption({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedPrintFormat == index;
    return Tappable(
      onTap: () => _update(() => _selectedPrintFormat = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.accent : context.colors.fill,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            AppIcon(
              icon,
              size: 20,
              color: isSelected
                  ? context.colors.onAccent
                  : context.colors.textPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? context.colors.onAccent
                      : context.colors.textPrimary,
                ),
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crisp QR Code
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.colors.surface,
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
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
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
              Text(
                context.l10n.barcodeImageReady,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.highResolutionPngImageOf,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(pngBytes, fit: BoxFit.contain, height: 280),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    AppFeedback.showSuccess(
                      context,
                      context.l10n.barcodeImageCaptured,
                    );
                  },
                  icon: const AppIcon(Icons.check_rounded, size: 18),
                  label: Text(context.l10n.commonDone),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) {
          AppFeedback.showError(
            context,
            context.l10n.failedToCaptureBarcodeGrid,
          );
        }
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        if (mounted) {
          AppFeedback.showError(context, context.l10n.failedToGenerateImage);
        }
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();

      if (mounted) {
        _showExportedImagePreview(pngBytes);
      }
    } catch (e) {
      debugPrint('export_barcodes_parts.dart error: $e');
      if (mounted) {
        AppFeedback.showError(context, context.l10n.couldnTExportTheLabels);
      }
    } finally {
      if (mounted) {
        _update(() => _isExportingImage = false);
      }
    }
  }
}
