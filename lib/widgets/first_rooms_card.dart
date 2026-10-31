import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../utils/e2e.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_ext.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../screens/box_create_screen.dart';
import '../theme/app_theme.dart';
import 'app_feedback.dart';
import 'app_icon.dart';
import 'soft_ui.dart';
import 'tappable.dart';

/// First-run step on Home: tick the rooms you have and create them all at once.
class FirstRoomsCard extends StatefulWidget {
  /// Called when the user taps "Skip - I'll do it later".
  final VoidCallback? onSkip;

  const FirstRoomsCard({super.key, this.onSkip});

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

  static const _icons = [
    Icons.weekend_outlined,
    Icons.kitchen_outlined,
    Icons.bed_outlined,
    Icons.bathtub_outlined,
    Icons.directions_car_outlined,
    Icons.desktop_windows_outlined,
    Icons.warehouse_outlined,
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

  Widget _tile(
    BuildContext context, {
    required String id,
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    final c = context.colors;
    return e2eId(
      id,
      Tappable(
        semanticLabel: label,
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? c.infoSoft : c.fill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? c.infoStrong : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              AppIcon(
                icon,
                size: 18,
                color: selected ? c.infoStrong : c.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? c.infoStrong : c.textPrimary,
                  ),
                ),
              ),
              if (selected)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: c.infoStrong,
                    shape: BoxShape.circle,
                  ),
                  child: const AppIcon(
                    Icons.check_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final names = roomNames(l10n);
    final tiles = <Widget>[
      for (var i = 0; i < names.length; i++)
        _tile(
          context,
          id: 'first_room_$i',
          label: names[i],
          icon: _icons[i],
          selected: _selected.contains(i),
          onTap: _creating
              ? null
              : () => setState(
                  () => _selected.contains(i)
                      ? _selected.remove(i)
                      : _selected.add(i),
                ),
        ),
      _tile(
        context,
        id: 'first_rooms_custom',
        label: l10n.addMyOwnLocation,
        icon: Icons.add_rounded,
        selected: false,
        onTap: _creating
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BoxCreateScreen()),
              ),
      ),
    ];
    return SoftCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.primary,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.firstRoomsStepLabel.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.firstRoomsTitle,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.firstRoomsSubtitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: c.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          for (var r = 0; r < tiles.length; r += 2) ...[
            if (r > 0) const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tiles[r]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: r + 1 < tiles.length
                        ? tiles[r + 1]
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          e2eId(
            'first_rooms_create',
            SoftButton(
              label: _creating
                  ? l10n.commonLoading
                  : l10n.createSelectedRooms(_selected.length),
              icon: _creating ? null : Icons.add_rounded,
              expand: true,
              onPressed: _selected.isEmpty || _creating
                  ? null
                  : () => _create(names),
            ),
          ),
          const SizedBox(height: 4),
          e2eId(
            'first_rooms_skip',
            Tappable(
              semanticLabel: l10n.firstRoomsSkip,
              onTap: _creating ? null : widget.onSkip,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.firstRoomsSkip,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Locked "Step 2" teaser under the first-rooms card.
class FirstRoomsNextStep extends StatelessWidget {
  const FirstRoomsNextStep({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Opacity(
      opacity: 0.7,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.fill,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            SoftIconTile(
              Icons.add_box_outlined,
              size: 36,
              color: c.textSecondary,
              background: c.surface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.firstRoomsNextTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.firstRoomsNextSub,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AppIcon(Icons.lock_outline_rounded, size: 16, color: c.textMuted),
          ],
        ),
      ),
    );
  }
}
