import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/notification_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Screen for configuring notification preferences.
///
/// Allows users to toggle individual notification types:
/// - Budget warnings (threshold alerts)
/// - Subscription reminders (due date alerts)
/// - Streak celebrations (milestone notifications)
///
/// All toggles default to ON for new users.
///
/// Covers: FR39, Story 4.7
class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  @override
  void initState() {
    super.initState();
    // Load preferences when screen opens
    Future.microtask(() {
      ref.read(notificationPreferencesNotifierProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(notificationPreferencesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // Header
          const _SectionHeader(
            title: 'Préférences',
            description:
                'Choisis les notifications que tu souhaites recevoir.',
          ),
          const SizedBox(height: AppSpacing.lg),

          // Notification toggles
          _NotificationToggle(
            title: 'Alertes budget',
            description:
                'Recevoir des alertes quand le budget descend sous 30% ou 10%.',
            icon: Icons.warning_amber_outlined,
            iconColor: const Color(0xFFFF9800),
            value: preferences.budgetWarningsEnabled,
            onChanged: (value) {
              ref
                  .read(notificationPreferencesNotifierProvider.notifier)
                  .setBudgetWarnings(enabled: value);
            },
          ),
          const SizedBox(height: AppSpacing.md),

          _NotificationToggle(
            title: 'Rappels abonnements',
            description:
                'Recevoir des rappels avant les dates d\'échéance des abonnements.',
            icon: Icons.event_outlined,
            iconColor: const Color(0xFF2196F3),
            value: preferences.subscriptionRemindersEnabled,
            onChanged: (value) {
              ref
                  .read(notificationPreferencesNotifierProvider.notifier)
                  .setSubscriptionReminders(enabled: value);
            },
          ),
          const SizedBox(height: AppSpacing.md),

          _NotificationToggle(
            title: 'Célébrations série',
            description:
                'Recevoir des félicitations pour les jalons de série (7, 14, 30 jours...).',
            icon: Icons.celebration_outlined,
            iconColor: const Color(0xFF4CAF50),
            value: preferences.streakCelebrationsEnabled,
            onChanged: (value) {
              ref
                  .read(notificationPreferencesNotifierProvider.notifier)
                  .setStreakCelebrations(enabled: value);
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // Info card
          const _InfoCard(),
        ],
      ),
    );
  }
}

/// Section header with title and description.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Toggle tile for a notification preference.
class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: iconColor,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Info card explaining notification limits.
class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Limite de notifications',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pour ne pas te déranger, l\'app envoie maximum 2 notifications par jour (sauf alertes critiques).',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
