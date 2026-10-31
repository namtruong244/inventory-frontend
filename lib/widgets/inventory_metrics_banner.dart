import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import 'soft_ui.dart';

/// Home "Inventory Metrics" card: total assets and value, a status health bar
/// with legend, then loans and containers.
class InventoryMetricsBanner extends StatelessWidget {
  const InventoryMetricsBanner({super.key});

  static const _order = [
    ItemStatus.stored,
    ItemStatus.inUse,
    ItemStatus.lent,
    ItemStatus.broken,
    ItemStatus.lost,
    ItemStatus.disposed,
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final c = context.colors;
    final l10n = context.l10n;
    final counts = {for (final s in _order) s: 0};
    for (final i in provider.items) {
      counts[i.status] = (counts[i.status] ?? 0) + 1;
    }
    final present = [
      for (final s in _order)
        if (counts[s]! > 0) s,
    ];
    final labelStyle = TextStyle(
      color: c.textSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    return SoftCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.totalAssets, style: labelStyle),
                    const SizedBox(height: 2),
                    Text(
                      '${provider.items.length}',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 170),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(l10n.estValue, style: labelStyle),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        provider.formatPrice(provider.totalInventoryValue),
                        maxLines: 1,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 10,
            child: present.isEmpty
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.fill,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const SizedBox.expand(),
                  )
                : Row(
                    children: [
                      for (var i = 0; i < present.length; i++) ...[
                        if (i > 0) const SizedBox(width: 3),
                        Expanded(
                          flex: counts[present[i]]!,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: present[i].color,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          if (present.isNotEmpty) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                for (final s in present)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: s.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${s.displayName} ${counts[s]}',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          Container(height: 1, color: c.border),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _stat(
                  context,
                  Icons.handshake_outlined,
                  '${provider.getActiveLoans().length}',
                  l10n.onLoan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _stat(
                  context,
                  Icons.archive_outlined,
                  '${provider.boxes.length}',
                  l10n.commonContainers,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, IconData icon, String num, String label) {
    final c = context.colors;
    return Row(
      children: [
        SoftIconTile(icon, size: 36),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                num,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
