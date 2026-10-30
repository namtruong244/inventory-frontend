import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../screens/box_create_screen.dart';
import '../theme/app_theme.dart';
import 'app_feedback.dart';

/// First-run step on Home: tick the rooms you have and create them all at once.
class FirstRoomsCard extends StatefulWidget {
  const FirstRoomsCard({super.key});

  @override
  State<FirstRoomsCard> createState() => _FirstRoomsCardState();
}

class _FirstRoomsCardState extends State<FirstRoomsCard> {
  final Set<int> _selected = {};
  bool _creating = false;

  static List<String> roomNames(AppLocalizations l) => [
    l.roomLivingRoom,
    l.roomKitchen,
    l.roomBedroom,
    l.roomBathroom,
    l.roomGarage,
    l.roomOffice,
    l.roomStorage,
  ];

  Future<void> _create(List<String> names) async {
    setState(() => _creating = true);
    final provider = context.read<InventoryProvider>();
    var created = 0;
    for (final i in _selected.toList()..sort()) {
      final ok = await provider.addBox(
        Box(
          name: names[i],
          type: StorageType.room,
          label: 'loc_${const Uuid().v4().substring(0, 8)}',
        ),
      );
      if (ok) created++;
    }
    if (!mounted) return;
    setState(() {
      _creating = false;
      _selected.clear();
    });
    if (created > 0) {
      AppFeedback.showSuccess(
        context,
        context.l10n.locationsCreatedCount(created),
      );
    } else {
      AppFeedback.showError(context, context.l10n.somethingWentWrongPleaseTry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final names = roomNames(context.l10n);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: context.colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.firstRoomsTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.firstRoomsSubtitle,
            style: TextStyle(fontSize: 13, color: c.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < names.length; i++)
                FilterChip(
                  label: Text(names[i]),
                  selected: _selected.contains(i),
                  onSelected: _creating
                      ? null
                      : (on) => setState(
                          () => on ? _selected.add(i) : _selected.remove(i),
                        ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selected.isEmpty || _creating
                  ? null
                  : () => _create(names),
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _creating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.l10n.createSelectedRooms(_selected.length)),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: _creating
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BoxCreateScreen(),
                      ),
                    ),
              child: Text(context.l10n.addMyOwnLocation),
            ),
          ),
        ],
      ),
    );
  }
}
