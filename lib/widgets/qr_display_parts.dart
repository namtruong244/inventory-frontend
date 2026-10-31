import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_feedback.dart';
import 'app_icon.dart';
import 'box_tree.dart' show boxTypeTone;
import 'tappable.dart';

const _qrInk = Color(0xFF18181B);

QrImageView _qr(String data, double size) => QrImageView(
  data: data,
  version: QrVersions.auto,
  size: size,
  padding: EdgeInsets.zero,
  backgroundColor: Colors.white,
  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: _qrInk),
  dataModuleStyle: const QrDataModuleStyle(
    dataModuleShape: QrDataModuleShape.square,
    color: _qrInk,
  ),
);

/// Big white card: QR in a bordered frame, type + path chip, name, copyable id.
class QrDisplayCard extends StatelessWidget {
  final Box box;
  final String? parentName;

  const QrDisplayCard({super.key, required this.box, this.parentName});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = boxTypeTone(box.type);
    final chipText = parentName == null
        ? box.type.displayName
        : '${box.type.displayName} · $parentName';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: c.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.border),
            ),
            child: _qr(
              box.label,
              MediaQuery.sizeOf(context).width < 360 ? 160 : 200,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: tone.bg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(box.type.icon, size: 13, color: tone.fg),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    chipText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: tone.fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            box.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          e2eId(
            'qr_copy',
            Tappable(
              semanticLabel: context.l10n.commonCopy,
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: box.label));
                if (context.mounted) {
                  AppFeedback.showSuccess(
                    context,
                    context.l10n.copiedToClipboard(box.label),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: c.fill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        box.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppIcon(
                      Icons.content_copy_rounded,
                      size: 15,
                      color: c.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Thermal label preview": a 50x30 label on a soft stage.
class ThermalLabelPreview extends StatelessWidget {
  final Box box;
  final String? parentName;

  const ThermalLabelPreview({super.key, required this.box, this.parentName});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                context.l10n.thermalLabelPreview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.labelSizeMm,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.fill,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Container(
              width: 250,
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _qr(box.label, 110),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          box.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        if (parentName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            parentName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Container(height: 1, color: Colors.black),
                        const SizedBox(height: 4),
                        Text(
                          box.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
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
        ),
      ],
    );
  }
}
