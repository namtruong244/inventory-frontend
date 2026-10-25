import 'package:flutter/material.dart';

import '../providers/inventory_provider.dart';
import '../services/offline_store.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

/// Lists offline changes the server could not apply (e.g. the item was edited elsewhere)
/// and lets the user keep their version or drop it. Hidden when there is nothing to resolve.
class FailedOpsTile extends StatelessWidget {
  final InventoryProvider provider;
  const FailedOpsTile({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final count = provider.failedOps.length;
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        tileColor: context.colors.warningSoft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const Icon(
          Icons.sync_problem_rounded,
          color: Color(0xFFD97706),
        ),
        title: Text('$count offline change(s) need your attention'),
        subtitle: Text(context.l10n.tapToKeepYourVersion),
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => _FailedOpsDialog(provider: provider),
        ),
      ),
    );
  }
}

class _FailedOpsDialog extends StatelessWidget {
  final InventoryProvider provider;
  const _FailedOpsDialog({required this.provider});

  String _label(PendingOp op) => describePendingOp(op);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final ops = provider.failedOps;
        return AlertDialog(
          title: Text(context.l10n.unresolvedChanges),
          content: SizedBox(
            width: double.maxFinite,
            child: ops.isEmpty
                ? Text(context.l10n.nothingLeftToResolve)
                : ListView(
                    shrinkWrap: true,
                    children: [
                      for (final op in ops)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_label(op)),
                          subtitle: Text(
                            op.error ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Wrap(
                            children: [
                              TextButton(
                                onPressed: () =>
                                    provider.discardFailedOp(op.id),
                                child: Text(context.l10n.commonDiscard),
                              ),
                              TextButton(
                                onPressed: () => provider.retryFailedOp(op.id),
                                child: Text(context.l10n.keepMine),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.commonClose),
            ),
          ],
        );
      },
    );
  }
}
