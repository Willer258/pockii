import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/fcfa_formatter.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/savings_projects_provider.dart';
import '../widgets/project_card.dart';

/// Screen displaying the list of savings projects.
class ProjectsListScreen extends ConsumerWidget {
  const ProjectsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(activeProjectsProvider);
    final stats = ref.watch(projectsStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes projets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: () => _showArchivedProjects(context),
            tooltip: 'Projets archivés',
          ),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return Center(
              child: EmptyStateWidget(
                icon: Icons.savings_outlined,
                title: 'Aucun projet',
                subtitle: 'Crée ton premier projet d\'épargne\npour commencer à économiser!',
                actionLabel: 'Créer un projet',
                onAction: () => _createProject(context),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              // Stats summary
              if (stats.totalProjects > 0) ...[
                _StatsSummary(stats: stats),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Projects list
              ...projects.map((project) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ProjectCard(
                      project: project,
                      onTap: () => _openProject(context, project.id),
                    ),
                  )),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text('Erreur: $error'),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(activeProjectsProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createProject(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau projet'),
      ),
    );
  }

  void _createProject(BuildContext context) {
    context.push('/projects/create');
  }

  void _openProject(BuildContext context, int projectId) {
    context.push('/projects/$projectId');
  }

  void _showArchivedProjects(BuildContext context) {
    context.push('/projects/archived');
  }
}

/// Summary statistics card.
class _StatsSummary extends StatelessWidget {
  const _StatsSummary({required this.stats});

  final ProjectsStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primaryContainer.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total épargné',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      FcfaFormatter.format(stats.totalSaved),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${stats.activeProjects}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      ' projet${stats.activeProjects > 1 ? 's' : ''} actif${stats.activeProjects > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Overall progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: stats.overallProgress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.success],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Target
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Objectif total: ${FcfaFormatter.formatCompact(stats.totalTarget)}',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
