import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import 'app_feedback.dart';
import 'tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'app_icon.dart';

class ThermalLabelSheet extends StatefulWidget {
  final Box box;

  const ThermalLabelSheet({super.key, required this.box});

  static void show(BuildContext context, Box box) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ThermalLabelSheet(box: box),
    );
  }

  @override
  State<ThermalLabelSheet> createState() => _ThermalLabelSheetState();
}

class _ThermalLabelSheetState extends State<ThermalLabelSheet> {
  // Label size: '50x30' or '40x30'
  String _selectedSize = '50x30';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final breadcrumb = provider.getBreadcrumbString(widget.box.id);
    final theme = Theme.of(context);

    final isWide = _selectedSize == '50x30';
    final labelWidth = isWide ? 310.0 : 260.0;
    final labelHeight = 185.0;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.thermalLabelPrint,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.standardPrintableAdhesiveLabel,
                    style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              IconButton(
 tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.pop(context),
                icon: const AppIcon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Size Selector (40x30mm vs 50x30mm)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.colors.fill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSizeTab('50x30', '50 x 30 mm (Standard)'),
                ),
                Expanded(
                  child: _buildSizeTab('40x30', '40 x 30 mm (Compact)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Thermal Label Preview Mockup
          Center(
            child: Container(
              width: labelWidth,
              height: labelHeight,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: context.colors.cardShadow,
              ),
              child: Row(
                children: [
                  // High-contrast QR code
                  Container(
                    width: 105,
                    height: 105,
                    color: context.colors.surface,
                    child: QrImageView(
                      data: widget.box.label,
                      version: QrVersions.auto,
                      size: 105,
                      padding: const EdgeInsets.all(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Label details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Storage Type tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.box.type.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.box.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            height: 1.15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          breadcrumb,
                          style: TextStyle(
                            fontSize: 10,
                            color: context.colors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          widget.box.label,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Print & Export Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    AppFeedback.showSuccess(context, context.l10n.thermalLabelCopiedToClipboard);
                  },
                  icon: const AppIcon(Icons.copy_rounded, size: 18),
                  label: Text(context.l10n.copyId),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: context.colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    AppFeedback.showSuccess(
                      context,
                      context.l10n.thermalLabelSentToPrinter(_selectedSize),
                    );
                  },
                  icon: const AppIcon(Icons.print_rounded, size: 18),
                  label: Text(context.l10n.printLabel),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeTab(String size, String label) {
    final isSelected = _selectedSize == size;
    return Tappable(
      onTap: () => setState(() => _selectedSize = size),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? context.colors.textPrimary : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
