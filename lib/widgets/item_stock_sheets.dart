import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_feedback.dart';
import 'app_form_field.dart';
import 'app_icon.dart';
import 'soft_sheet.dart';
import 'soft_ui.dart';
import 'tappable.dart';

String _fmt(double v, {int digits = 1}) =>
    v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(digits);

/// Opens the Use / Restock sheet in "use" mode.
void showConsumeSheet(
  BuildContext context,
  Item item,
  InventoryProvider provider,
) => _showStockSheet(context, item, provider, restock: false);

/// Opens the Use / Restock sheet in "restock" mode.
void showRestockSheet(
  BuildContext context,
  Item item,
  InventoryProvider provider,
) => _showStockSheet(context, item, provider, restock: true);

void _showStockSheet(
  BuildContext context,
  Item item,
  InventoryProvider provider, {
  required bool restock,
}) {
  // The sheet builder shadows `context` with the sheet's own, which is gone
  // once the sheet is popped; feedback after the await must use the host.
  final host = context;
  final threshold = item.minQuantity;
  showSoftSheet<void>(
    context,
    title: item.name,
    subtitle: threshold == null
        ? context.l10n.stockSheetSubtitle(
            _fmt(item.quantity, digits: 2),
            item.unit,
          )
        : context.l10n.stockSheetSubtitleThreshold(
            _fmt(item.quantity, digits: 2),
            item.unit,
            _fmt(threshold, digits: 2),
          ),
    builder: (_) => _StockSheetBody(
      host: host,
      item: item,
      provider: provider,
      initialRestock: restock,
    ),
  );
}

class _StockSheetBody extends StatefulWidget {
  final BuildContext host;
  final Item item;
  final InventoryProvider provider;
  final bool initialRestock;

  const _StockSheetBody({
    required this.host,
    required this.item,
    required this.provider,
    required this.initialRestock,
  });

  @override
  State<_StockSheetBody> createState() => _StockSheetBodyState();
}

class _StockSheetBodyState extends State<_StockSheetBody> {
  late bool _restock = widget.initialRestock || widget.item.quantity <= 0;
  late double _amount = _defaultAmount();
  late final TextEditingController _ctrl = TextEditingController(
    text: _fmt(_amount, digits: 2),
  );

  Item get item => widget.item;

  double _defaultAmount() {
    if (!_restock && item.quantity < 1.0 && item.quantity > 0) {
      return item.quantity;
    }
    return 1.0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _setAmount(double v) {
    setState(() => _amount = v);
    _ctrl.text = _fmt(v, digits: 2);
  }

  void _setMode(bool restock) {
    if (restock == _restock) return;
    if (!restock && item.quantity <= 0) return;
    setState(() => _restock = restock);
    _setAmount(_defaultAmount());
  }

  double get _after => _restock
      ? item.quantity + _amount
      : (item.quantity - _amount).clamp(0.0, double.infinity);

  bool get _valid =>
      _amount > 0 && (_restock || _amount <= item.quantity + 0.0000001);

  Future<void> _submit() async {
    final host = widget.host;
    final provider = widget.provider;
    final amount = _amount;
    final after = _after;
    Navigator.pop(context);
    final ok = await provider.updateItemQuantity(
      item.id,
      after,
      reason: _restock ? 'restock' : 'consume',
    );
    if (!host.mounted) return;
    if (!ok) {
      AppFeedback.showError(
        host,
        provider.errorMessage ?? host.l10n.syncFailed,
      );
      return;
    }
    if (_restock) {
      AppFeedback.showSuccess(
        host,
        host.l10n.addedTotal(
          _fmt(amount, digits: 2),
          item.unit,
          _fmt(after, digits: 2),
          item.unit,
        ),
      );
      return;
    }
    AppFeedback.showSuccess(
      host,
      host.l10n.usedRemaining(
        _fmt(amount, digits: 2),
        item.unit,
        _fmt(after),
        item.unit,
      ),
    );
    if (item.isLowStockAt(after)) {
      AppFeedback.showWarning(
        host,
        host.l10n.warningQuantityHasDroppedTo(item.minQuantity ?? 0, item.unit),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final qty = item.quantity;
    final quick = _restock
        ? <(String, double)>[('+1', 1), ('+2', 2), ('+5', 5), ('+10', 10)]
        : <(String, double)>[
            if (qty >= 1) ('1', 1),
            if (qty >= 2) ('2', 2),
            if (qty >= 5) ('5', 5),
            (l10n.stockQuickAll, qty),
          ];
    final amountText = _fmt(_amount, digits: 2);
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ModeToggle(restock: _restock, canUse: qty > 0, onChanged: _setMode),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < quick.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _QuickTile(
                    kind: _restock ? l10n.stockQuickAdd : l10n.stockQuickUse,
                    value: quick[i].$1,
                    selected: _amount == quick[i].$2,
                    onTap: quick[i].$2 > 0
                        ? () => _setAmount(quick[i].$2)
                        : null,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          AppFormField(
            id: 'stock_amount',
            label: '${l10n.stockAmountLabel} · ${item.unit}',
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) =>
                setState(() => _amount = double.tryParse(v.trim()) ?? 0),
          ),
          const SizedBox(height: 16),
          _AfterCard(
            item: item,
            restock: _restock,
            amount: _amount,
            after: _after,
          ),
          const SizedBox(height: 16),
          e2eId(
            'stock_save',
            SoftButton(
              expand: true,
              icon: _restock ? Icons.add_rounded : Icons.remove_rounded,
              label: _restock
                  ? l10n.stockRestockAmountButton(amountText, item.unit)
                  : l10n.stockUseAmountButton(amountText, item.unit),
              onPressed: _valid ? _submit : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool restock;
  final bool canUse;
  final ValueChanged<bool> onChanged;

  const _ModeToggle({
    required this.restock,
    required this.canUse,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget seg(String id, String label, IconData icon, bool selected, bool on) {
      return Expanded(
        child: e2eId(
          id,
          Tappable(
            semanticLabel: label,
            onTap: () => onChanged(on),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: selected ? c.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: c.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(
                    icon,
                    size: 15,
                    color: selected ? c.textPrimary : c.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? c.textPrimary : c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          seg(
            'stock_use',
            context.l10n.stockModeUse,
            Icons.remove_rounded,
            !restock,
            false,
          ),
          const SizedBox(width: 4),
          seg(
            'stock_restock',
            context.l10n.commonRestock,
            Icons.add_rounded,
            restock,
            true,
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final String kind;
  final String value;
  final bool selected;
  final VoidCallback? onTap;

  const _QuickTile({
    required this.kind,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? Colors.white : c.textPrimary;
    final sub = selected
        ? Colors.white.withValues(alpha: 0.65)
        : c.textSecondary;
    return Tappable(
      semanticLabel: '$kind $value',
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: selected ? c.primary : c.fill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              kind,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: sub,
              ),
            ),
            Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Remaining after use" / "Total after restock" card with the threshold marker.
class _AfterCard extends StatelessWidget {
  final Item item;
  final bool restock;
  final double amount;
  final double after;

  const _AfterCard({
    required this.item,
    required this.restock,
    required this.amount,
    required this.after,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final threshold = item.minQuantity;
    final isEmpty = !restock && after <= 0;
    final isLow = item.isLowStockAt(after);
    final (bg, strong, fill) = isEmpty
        ? (c.dangerSoft, c.dangerStrong, AppTones.coral)
        : isLow
        ? (c.warningSoft, c.warningStrong, AppTones.amber)
        : (c.successSoft, c.successStrong, AppTones.matcha);
    final scale = [
      item.quantity,
      after,
      if (threshold != null) threshold * 1.25,
      1.0,
    ].reduce((a, b) => a > b ? a : b);
    final String? note = isEmpty
        ? l10n.stockOutAfterUse
        : (isLow
              ? l10n.stockBelowThreshold(_fmt(threshold ?? 0, digits: 2))
              : null);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restock
                          ? l10n.stockTotalAfterRestock
                          : l10n.stockRemainingAfterUse,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: strong,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_fmt(after)} ${item.unit}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: strong,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_fmt(item.quantity)} → ${_fmt(after)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: strong,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              return SizedBox(
                height: 14,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 3,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: c.surface.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 3,
                      child: Container(
                        height: 8,
                        width: w * (after / scale).clamp(0.0, 1.0),
                        decoration: BoxDecoration(
                          color: fill,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    if (threshold != null)
                      Positioned(
                        left: (w * (threshold / scale)).clamp(0.0, w - 2),
                        top: 0,
                        child: Container(width: 2, height: 14, color: strong),
                      ),
                  ],
                ),
              );
            },
          ),
          if (note != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                AppIcon(Icons.warning_amber_rounded, size: 14, color: strong),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    note,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: strong,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
