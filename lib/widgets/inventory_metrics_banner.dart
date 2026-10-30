import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';

/// Bento grid of the headline numbers: a tall lime tile for total assets,
/// two stacked tiles for containers and loans, and a wide tile for value.
class InventoryMetricsBanner extends StatelessWidget {
  const InventoryMetricsBanner({super.key});

  static const double _gap = 12;
  static const double _smallTile = 92;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Text(
            l10n.inventoryQuickMetrics,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          height: _smallTile * 2 + _gap,
          child: Row(
            children: [
              Expanded(
                flex: 11,
                child: _tile(
                  context,
                  icon: Icons.category_outlined,
                  label: l10n.totalAssets,
                  value: '${provider.items.length}',
                  background: c.accent,
                  foreground: c.onAccent,
                  big: true,
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                flex: 10,
                child: Column(
                  children: [
                    Expanded(
                      child: _tile(
                        context,
                        icon: Icons.inventory_2_outlined,
                        label: l10n.commonContainers,
                        value: '${provider.boxes.length}',
                        background: AppTones.skySoft,
                        foreground: AppTones.ink,
                      ),
                    ),
                    const SizedBox(height: _gap),
                    Expanded(
                      child: _tile(
                        context,
                        icon: Icons.handshake_outlined,
                        label: l10n.onLoan,
                        value: '${provider.getActiveLoans().length}',
                        background: AppTones.sandSoft,
                        foreground: AppTones.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _gap),
        SizedBox(
          height: _smallTile,
          child: _tile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            label: l10n.estValue,
            value: provider.formatPrice(provider.totalInventoryValue),
            // c.primary is a mid grey in dark mode, so the lime accent pair
            // keeps the figure readable there.
            background: dark ? c.accent : c.primary,
            foreground: dark ? c.onAccent : c.surface,
            wide: true,
          ),
        ),
      ],
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color background,
    required Color foreground,
    bool big = false,
    bool wide = false,
  }) {
    final iconBox = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppIcon(icon, color: foreground, size: 18),
    );
    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: foreground.withValues(alpha: 0.75),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
    final valueText = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        maxLines: 1,
        style: TextStyle(
          color: foreground,
          fontSize: big ? 44 : 24,
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: big ? -1.5 : -0.5,
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: wide
          ? Row(
              children: [
                iconBox,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [labelText, const SizedBox(height: 6), valueText],
                  ),
                ),
              ],
            )
          : big
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconBox,
                const Spacer(),
                valueText,
                const SizedBox(height: 6),
                labelText,
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [valueText, const SizedBox(height: 4), labelText],
                  ),
                ),
                iconBox,
              ],
            ),
    );
  }
}
