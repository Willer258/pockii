import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/savings_project_repository.dart';
import '../../domain/models/project_contribution_model.dart';
import '../../domain/models/savings_project_model.dart';

/// Provider for the list of active savings projects.
final activeProjectsProvider = StreamProvider<List<SavingsProjectModel>>((ref) {
  final repository = ref.watch(savingsProjectRepositoryProvider);
  return repository.watchActiveProjects();
});

/// Provider for archived projects.
final archivedProjectsProvider = FutureProvider<List<SavingsProjectModel>>((ref) {
  final repository = ref.watch(savingsProjectRepositoryProvider);
  return repository.getArchivedProjects();
});

/// Provider for a specific project by ID.
final projectByIdProvider = StreamProvider.family<SavingsProjectModel?, int>((ref, id) {
  final repository = ref.watch(savingsProjectRepositoryProvider);
  return repository.watchProjectById(id);
});

/// Provider for contributions of a specific project.
final projectContributionsProvider =
    StreamProvider.family<List<ProjectContributionModel>, int>((ref, projectId) {
  final repository = ref.watch(savingsProjectRepositoryProvider);
  return repository.watchContributionsForProject(projectId);
});

/// Provider for total saved across all active projects.
final totalSavedProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(savingsProjectRepositoryProvider);
  return repository.getTotalSavedInActiveProjects();
});

/// Provider for the priority project to show on home screen.
/// Returns the project with the highest progress that's not yet complete.
final priorityProjectProvider = Provider<SavingsProjectModel?>((ref) {
  final projectsAsync = ref.watch(activeProjectsProvider);

  return projectsAsync.when(
    data: (projects) {
      if (projects.isEmpty) return null;

      // Filter out completed projects
      final incomplete = projects.where((p) => !p.isGoalReached).toList();
      if (incomplete.isEmpty) return projects.first;

      // Sort by progress descending (closest to goal first)
      incomplete.sort((a, b) => b.progress.compareTo(a.progress));
      return incomplete.first;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for projects count statistics.
final projectsStatsProvider = Provider<ProjectsStats>((ref) {
  final projectsAsync = ref.watch(activeProjectsProvider);

  return projectsAsync.when(
    data: (projects) {
      final totalProjects = projects.length;
      final completedProjects = projects.where((p) => p.isGoalReached).length;
      final totalSaved = projects.fold<int>(0, (sum, p) => sum + p.currentAmountFcfa);
      final totalTarget = projects.fold<int>(0, (sum, p) => sum + p.targetAmountFcfa);

      return ProjectsStats(
        totalProjects: totalProjects,
        completedProjects: completedProjects,
        totalSaved: totalSaved,
        totalTarget: totalTarget,
      );
    },
    loading: () => ProjectsStats.empty,
    error: (_, __) => ProjectsStats.empty,
  );
});

/// Statistics for savings projects.
class ProjectsStats {
  const ProjectsStats({
    required this.totalProjects,
    required this.completedProjects,
    required this.totalSaved,
    required this.totalTarget,
  });

  final int totalProjects;
  final int completedProjects;
  final int totalSaved;
  final int totalTarget;

  double get overallProgress => totalTarget > 0 ? totalSaved / totalTarget : 0;
  int get activeProjects => totalProjects - completedProjects;

  static const empty = ProjectsStats(
    totalProjects: 0,
    completedProjects: 0,
    totalSaved: 0,
    totalTarget: 0,
  );
}
