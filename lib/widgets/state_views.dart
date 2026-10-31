import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_icon.dart';
import 'soft_ui.dart';
import 'tappable.dart';

/// Generic loading / error building blocks from the design's State frames
/// (Loading `i8QUK`, Error `YaF0C`). Empty states use `EmptyStateCard`.

/// Grey placeholder block. Pulses softly; the pulse is off under E2E so
/// Maestro can reach an idle UI.
class SoftSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const SoftSkeleton({
    super.key,
    this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  State<SoftSkeleton> createState() => _SoftSkeletonState();
}

class _SoftSkeletonState extends State<SoftSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
    lowerBound: 0.55,
    upperBound: 1,
    value: 1,
  );

  @override
  void initState() {
    super.initState();
    if (!kE2E) _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _pulse,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: context.colors.fill,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// White card with an image block and three text lines (the design's Card Skeleton).
class SkeletonItemCard extends StatelessWidget {
  const SkeletonItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SoftCard(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          SoftSkeleton(width: 64, height: 64, radius: 18),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SoftSkeleton(height: 14),
                SizedBox(height: 8),
                SoftSkeleton(width: 140, height: 10),
                SizedBox(height: 8),
                SoftSkeleton(width: 64, height: 20, radius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A column of [count] item-card skeletons, 12 apart. Announces "Loading…".
class SkeletonList extends StatelessWidget {
  final int count;

  const SkeletonList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.commonLoading,
      child: ExcludeSemantics(
        child: Column(
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              const SkeletonItemCard(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Design Error State: coral art tile, title, body and a "Try again" button.
class ErrorStateCard extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final IconData icon;

  const ErrorStateCard({
    super.key,
    required this.title,
    required this.body,
    this.onRetry,
    this.retryLabel,
    this.icon = Icons.cloud_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: c.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SoftIconTile(
            icon,
            size: 72,
            color: c.dangerStrong,
            background: c.dangerSoft,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: c.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            e2eId(
              'state_retry',
              SoftButton(
                label: retryLabel ?? context.l10n.commonTryAgain,
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Coral strip "Can't reach the server" with a white Retry chip.
class ConnectionErrorBanner extends StatelessWidget {
  final VoidCallback onRetry;
  final String? title;
  final String? body;

  const ConnectionErrorBanner({
    super.key,
    required this.onRetry,
    this.title,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: c.dangerSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AppIcon(Icons.cloud_off_rounded, size: 18, color: c.dangerStrong),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? l10n.connectionErrorTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: c.dangerStrong,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  body ?? l10n.connectionErrorBody,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: c.dangerStrong,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Tappable(
            semanticLabel: l10n.commonRetry,
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(
                    Icons.refresh_rounded,
                    size: 14,
                    color: c.textPrimary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    l10n.commonRetry,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
