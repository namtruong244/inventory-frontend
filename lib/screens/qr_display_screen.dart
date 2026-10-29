import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/inventory_models.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../widgets/app_icon.dart';

class QRDisplayScreen extends StatelessWidget {
  final Box box;

  const QRDisplayScreen({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: context.colors.textPrimary,
              ),
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        title: Text(context.l10n.boxQrCode),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              box.name,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.commonLabel(box.label),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: context.colors.cardShadow,
              ),
              child: QrImageView(
                data: box.label,
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: context.colors.surface,
              ),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.accent,
                foregroundColor: context.colors.onAccent,
                padding: const EdgeInsets.symmetric(horizontal: 28),
              ),
              onPressed: () {
                // TODO: Implement printing or sharing
              },
              icon: AppIcon(Icons.print, color: context.colors.onAccent),
              label: Text(context.l10n.printLabel),
            ),
          ],
        ),
      ),
    );
  }
}
