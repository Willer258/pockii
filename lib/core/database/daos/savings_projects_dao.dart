import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/project_contributions_table.dart';
import '../tables/savings_projects_table.dart';

part 'savings_projects_dao.g.dart';

/// Data Access Object for savings projects and contributions.
///
/// Provides CRUD operations and filtered queries for savings projects.
/// All monetary values are handled as integers (FCFA, ARCH-7).
@DriftAccessor(tables: [SavingsProjects, ProjectContributions])
class SavingsProjectsDao extends DatabaseAccessor<AppDatabase>
    with _$SavingsProjectsDaoMixin {
  SavingsProjectsDao(super.db);

  // ============== PROJECT CRUD OPERATIONS ==============

  /// Creates a new savings project and returns its ID.
  Future<int> createProject(SavingsProjectsCompanion project) {
    return into(savingsProjects).insert(project);
  }

  /// Gets a specific project by ID.
  Future<SavingsProject?> getProjectById(int id) {
    return (select(savingsProjects)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  /// Gets all projects ordered by creation date (newest first).
  Future<List<SavingsProject>> getAllProjects() {
    return (select(savingsProjects)
          ..orderBy([
            (p) => OrderingTerm(expression: p.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Gets all active (non-archived) projects.
  Future<List<SavingsProject>> getActiveProjects() {
    return (select(savingsProjects)
          ..where((p) => p.isArchived.equals(false))
          ..orderBy([
            (p) => OrderingTerm(expression: p.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Gets all archived projects.
  Future<List<SavingsProject>> getArchivedProjects() {
    return (select(savingsProjects)
          ..where((p) => p.isArchived.equals(true))
          ..orderBy([
            (p) => OrderingTerm(expression: p.completedAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Updates an existing project.
  Future<bool> updateProject(SavingsProject project) {
    return update(savingsProjects).replace(project);
  }

  /// Updates a project using a companion (partial update).
  Future<int> updateProjectPartial(int id, SavingsProjectsCompanion updates) {
    return (update(savingsProjects)..where((p) => p.id.equals(id)))
        .write(updates);
  }

  /// Deletes a project and all its contributions (cascade).
  Future<int> deleteProject(int id) {
    return (delete(savingsProjects)..where((p) => p.id.equals(id))).go();
  }

  // ============== PROJECT QUERIES ==============

  /// Watches all active projects.
  Stream<List<SavingsProject>> watchActiveProjects() {
    return (select(savingsProjects)
          ..where((p) => p.isArchived.equals(false))
          ..orderBy([
            (p) => OrderingTerm(expression: p.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Watches a specific project by ID.
  Stream<SavingsProject?> watchProjectById(int id) {
    return (select(savingsProjects)..where((p) => p.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Gets projects with auto-contribution due today or before.
  Future<List<SavingsProject>> getProjectsWithDueAutoContribution(DateTime now) {
    return (select(savingsProjects)
          ..where((p) =>
              p.isArchived.equals(false) &
              p.autoContributionEnabled.equals(true) &
              p.nextContributionDate.isSmallerOrEqualValue(now)))
        .get();
  }

  /// Gets projects by category.
  Future<List<SavingsProject>> getProjectsByCategory(String category) {
    return (select(savingsProjects)
          ..where((p) => p.category.equals(category) & p.isArchived.equals(false))
          ..orderBy([
            (p) => OrderingTerm(expression: p.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  // ============== CONTRIBUTION CRUD OPERATIONS ==============

  /// Creates a new contribution and returns its ID.
  Future<int> createContribution(ProjectContributionsCompanion contribution) {
    return into(projectContributions).insert(contribution);
  }

  /// Gets all contributions for a project.
  Future<List<ProjectContribution>> getContributionsForProject(int projectId) {
    return (select(projectContributions)
          ..where((c) => c.projectId.equals(projectId))
          ..orderBy([
            (c) => OrderingTerm(expression: c.date, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Watches contributions for a project.
  Stream<List<ProjectContribution>> watchContributionsForProject(int projectId) {
    return (select(projectContributions)
          ..where((c) => c.projectId.equals(projectId))
          ..orderBy([
            (c) => OrderingTerm(expression: c.date, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Deletes a contribution by ID.
  Future<int> deleteContribution(int id) {
    return (delete(projectContributions)..where((c) => c.id.equals(id))).go();
  }

  // ============== COMBINED OPERATIONS ==============

  /// Adds a contribution and updates the project's current amount.
  /// Returns the contribution ID.
  Future<int> addContributionAndUpdateProject({
    required int projectId,
    required int amountFcfa,
    required String type,
    String? note,
    DateTime? date,
  }) async {
    return transaction(() async {
      // Create contribution
      final contributionId = await createContribution(
        ProjectContributionsCompanion.insert(
          projectId: projectId,
          amountFcfa: amountFcfa,
          type: type,
          note: Value(note),
          date: Value(date ?? DateTime.now()),
        ),
      );

      // Update project amount
      final project = await getProjectById(projectId);
      if (project != null) {
        final newAmount = project.currentAmountFcfa + amountFcfa;
        await updateProjectPartial(
          projectId,
          SavingsProjectsCompanion(
            currentAmountFcfa: Value(newAmount),
            updatedAt: Value(DateTime.now()),
            // Mark as completed if goal reached
            completedAt: newAmount >= project.targetAmountFcfa
                ? Value(DateTime.now())
                : const Value.absent(),
          ),
        );
      }

      return contributionId;
    });
  }

  /// Updates the next contribution date for a project.
  Future<void> updateNextContributionDate(int projectId, DateTime nextDate) {
    return updateProjectPartial(
      projectId,
      SavingsProjectsCompanion(
        nextContributionDate: Value(nextDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Archives a project.
  Future<void> archiveProject(int projectId) {
    return updateProjectPartial(
      projectId,
      SavingsProjectsCompanion(
        isArchived: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Restores an archived project.
  Future<void> restoreProject(int projectId) {
    return updateProjectPartial(
      projectId,
      SavingsProjectsCompanion(
        isArchived: const Value(false),
        completedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Gets total saved across all active projects.
  Future<int> getTotalSavedInActiveProjects() async {
    final projects = await getActiveProjects();
    return projects.fold<int>(0, (sum, p) => sum + p.currentAmountFcfa);
  }
}
