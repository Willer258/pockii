import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/streak_celebration_tracker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/services/streak_service.dart';
import '../providers/streak_provider.dart';

/// Badge displaying the user's current streak.
///
/// Shows "🔥 X jours" with a pulse animation when streak > 0.
/// When streak is 0, shows muted styling with a helpful tooltip.
/// Tapping the badge shows streak details dialog.
/// Also checks for pending milestone celebrations and shows celebration dialog.
///
/// Covers: FR53 (view current streak count), FR54 (streak celebration), UX-8
class StreakBadge extends ConsumerStatefulWidget {
  const StreakBadge({super.key});

  @override
  ConsumerState<StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends ConsumerState<StreakBadge> {
  bool _celebrationShown = false;

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(streakStatusProvider);
    final pendingCelebrationAsync = ref.watch(pendingCelebrationProvider);

    // Check for pending celebration
    pendingCelebrationAsync.whenData((milestone) {
      if (milestone != null && !_celebrationShown && mounted) {
        _celebrationShown = true;
        // Show celebration dialog after the frame is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showCelebrationDialog(context, milestone);
          }
        });
      }
    });

    return statusAsync.when(
      data: (status) => _StreakBadgeContent(status: status),
      loading: () => const _StreakBadgePlaceholder(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showCelebrationDialog(BuildContext context, int milestone) {
    final clearCelebration = ref.read(clearPendingCelebrationProvider);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _StreakCelebrationDialog(
        milestone: milestone,
        onDismiss: () {
          Navigator.of(context).pop();
          clearCelebration();
        },
      ),
    );
  }
}

/// Content of the streak badge when data is available.
class _StreakBadgeContent extends StatefulWidget {
  const _StreakBadgeContent({required this.status});

  final StreakStatus status;

  @override
  State<_StreakBadgeContent> createState() => _StreakBadgeContentState();
}

class _StreakBadgeContentState extends State<_StreakBadgeContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Only animate when streak > 0
    if (widget.status.currentStreak > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_StreakBadgeContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation state when streak changes
    if (widget.status.currentStreak > 0 && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.status.currentStreak == 0 &&
        _pulseController.isAnimating) {
      _pulseController
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasStreak = widget.status.currentStreak > 0;
    final streakText = widget.status.currentStreak == 1
        ? '🔥 1 jour'
        : '🔥 ${widget.status.currentStreak} jours';

    Widget badge = GestureDetector(
      onTap: () => _showStreakDetails(context),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: hasStreak ? _pulseAnimation.value : 1.0,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: hasStreak
                ? const Color(0xFFFFF3E0) // Orange[50] for active streak
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasStreak
                  ? const Color(0xFFFFCC80) // Orange[200]
                  : AppColors.outlineVariant,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                streakText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasStreak
                      ? const Color(0xFFE65100) // Orange[900]
                      : AppColors.onSurfaceVariant,
                ),
              ),
              if (!hasStreak) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // Add tooltip for zero streak
    if (!hasStreak) {
      badge = Tooltip(
        message: 'Ajoute une dépense pour démarrer',
        child: badge,
      );
    }

    return badge;
  }

  void _showStreakDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => StreakDetailsDialog(status: widget.status),
    );
  }
}

/// Placeholder shown while loading streak data.
class _StreakBadgePlaceholder extends StatelessWidget {
  const _StreakBadgePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            height: 14,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog showing streak details.
class StreakDetailsDialog extends StatelessWidget {
  const StreakDetailsDialog({
    required this.status,
    super.key,
  });

  final StreakStatus status;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Text('🔥', style: TextStyle(fontSize: 28)),
          SizedBox(width: AppSpacing.sm),
          Text('Ta série'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DetailRow(
            label: 'Série actuelle',
            value: _formatDays(status.currentStreak),
            isHighlighted: true,
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            label: 'Meilleure série',
            value: _formatDays(status.longestStreak),
            isHighlighted: false,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (status.currentStreak == 0)
            const _InfoCard(
              icon: Icons.lightbulb_outline,
              message: 'Ajoute une transaction aujourd\'hui pour commencer une nouvelle série!',
              color: AppColors.primary,
            )
          else if (!status.hasActivityToday && status.streakIsActive)
            const _InfoCard(
              icon: Icons.warning_amber_outlined,
              message: 'N\'oublie pas de logger une transaction aujourd\'hui pour maintenir ta série!',
              color: Color(0xFFFF9800),
            )
          else if (status.hasActivityToday)
            const _InfoCard(
              icon: Icons.check_circle_outline,
              message: 'Super! Tu as déjà logé une transaction aujourd\'hui. Reviens demain!',
              color: AppColors.success,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }

  String _formatDays(int days) {
    if (days == 0) return '0 jour';
    if (days == 1) return '1 jour';
    return '$days jours';
  }
}

/// Row displaying a streak statistic.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.isHighlighted,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Info card with icon and message.
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog celebrating a streak milestone.
///
/// Shows a celebratory message with emoji and animation.
/// Covers: FR54 (visual celebration), Story 4.6
class _StreakCelebrationDialog extends StatefulWidget {
  const _StreakCelebrationDialog({
    required this.milestone,
    required this.onDismiss,
  });

  final int milestone;
  final VoidCallback onDismiss;

  @override
  State<_StreakCelebrationDialog> createState() =>
      _StreakCelebrationDialogState();
}

class _StreakCelebrationDialogState extends State<_StreakCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emoji = getCelebrationEmoji(widget.milestone);
    final message = getCelebrationMessage(widget.milestone);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.xl),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -20 * (1 - _bounceAnimation.value)),
                  child: child,
                );
              },
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 72),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Felicitations!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurface,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: widget.onDismiss,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
              child: const Text('Super!'),
            ),
          ],
        ),
      ),
    );
  }
}
