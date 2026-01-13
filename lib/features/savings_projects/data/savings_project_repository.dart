import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pockii/core/database/app_database.dart';
import 'package:pockii/core/database/daos/savings_projects_dao.dart';
import 'package:pockii/core/database/database_provider.dart';

import '../domain/enums/contribution_frequency.dart';
import '../domain/enums/contribution_type.dart';
import '../domain/enums/project_category.dart';
import '../domain/models/project_contribution_model.dart';
import '../domain/models/savings_project_model.dart';

/// Provider for SavingsProjectsDao.
final savingsProjectsDaoProvider = Provider<SavingsProjectsDao>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return SavingsProjectsDao(db);
});

/// Provider for SavingsProjectRepository.
final savingsProjectRepositoryProvider = Provider<SavingsProjectRepository>((ref) {
  final dao = ref.watch(savingsProjectsDaoProvider);
  return SavingsProjectRepository(dao);
});

/// Repository that abstracts SavingsProjectsDao for the presentation layer.
///
/// Handles mapping between domain models and data layer entities.
/// Uses Riverpod provider pattern (ARCH-4).
class SavingsProjectRepository {
  /// Creates a SavingsProjectRepository with the given DAO.
  SavingsProjectRepository(this._dao);

  final SavingsProjectsDao _dao;

  // ============== PROJECT CRUD OPERATIONS ==============

  /// Creates a new savings project and returns its ID.
  Future<int> createProject({
    required String name,
    required ProjectCategory category,
    required int targetAmountFcfa,
    String? emoji,
    Color? color,
    String? imageUrl,
    DateTime? targetDate,
    bool autoContributionEnabled = false,
    int autoContributionAmountFcfa = 0,
    ContributionFrequency? autoContributionFrequency,
  }) async {
    final now = DateTime.now();
    DateTime? nextContributionDate;

    if (autoContributionEnabled && autoContributionFrequency != null) {
      nextContributionDate = autoContributionFrequency.nextDateFrom(now);
    }

    final companion = SavingsProjectsCompanion.insert(
      name: name,
      category: category.value,
      targetAmountFcfa: targetAmountFcfa,
      emoji: Value(emoji ?? category.defaultEmoji),
      color: Value(_colorToHex(color ?? category.defaultColor)),
      imageUrl: Value(imageUrl),
      targetDate: Value(targetDate),
      autoContributionEnabled: Value(autoContributionEnabled),
      autoContributionAmountFcfa: Value(autoContributionAmountFcfa),
      autoContributionFrequency: Value(autoContributionFrequency?.value),
      nextContributionDate: Value(nextContributionDate),
    );

    return _dao.createProject(companion);
  }

  /// Creates a project from a domain model.
  Future<int> createProjectFromModel(SavingsProjectModel project) {
    return _dao.createProject(project.toCompanion());
  }

  /// Gets a specific project by ID.
  Future<SavingsProjectModel?> getProjectById(int id) async {
    final entity = await _dao.getProjectById(id);
    return entity != null ? SavingsProjectModel.fromEntity(entity) : null;
  }

  /// Gets all projects.
  Future<List<SavingsProjectModel>> getAllProjects() async {
    final entities = await _dao.getAllProjects();
    return entities.map(SavingsProjectModel.fromEntity).toList();
  }

  /// Gets all active (non-archived) projects.
  Future<List<SavingsProjectModel>> getActiveProjects() async {
    final entities = await _dao.getActiveProjects();
    return entities.map(SavingsProjectModel.fromEntity).toList();
  }

  /// Gets all archived projects.
  Future<List<SavingsProjectModel>> getArchivedProjects() async {
    final entities = await _dao.getArchivedProjects();
    return entities.map(SavingsProjectModel.fromEntity).toList();
  }

  /// Updates an existing project.
  Future<bool> updateProject(SavingsProjectModel project) async {
    final entity = SavingsProject(
      id: project.id,
      name: project.name,
      category: project.category.value,
      targetAmountFcfa: project.targetAmountFcfa,
      currentAmountFcfa: project.currentAmountFcfa,
      emoji: project.emoji,
      color: _colorToHex(project.color),
      imageUrl: project.imageUrl,
      targetDate: project.targetDate,
      autoContributionEnabled: project.autoContributionEnabled,
      autoContributionAmountFcfa: project.autoContributionAmountFcfa,
      autoContributionFrequency: project.autoContributionFrequency?.value,
      nextContributionDate: project.nextContributionDate,
      isArchived: project.isArchived,
      completedAt: project.completedAt,
      createdAt: project.createdAt,
      updatedAt: DateTime.now(),
    );
    return _dao.updateProject(entity);
  }

  /// Deletes a project and all its contributions.
  Future<int> deleteProject(int id) {
    return _dao.deleteProject(id);
  }

  /// Archives a project.
  Future<void> archiveProject(int id) {
    return _dao.archiveProject(id);
  }

  /// Restores an archived project.
  Future<void> restoreProject(int id) {
    return _dao.restoreProject(id);
  }

  // ============== PROJECT STREAMS ==============

  /// Watches all active projects.
  Stream<List<SavingsProjectModel>> watchActiveProjects() {
    return _dao.watchActiveProjects().map(
      (entities) => entities.map(SavingsProjectModel.fromEntity).toList(),
    );
  }

  /// Watches a specific project by ID.
  Stream<SavingsProjectModel?> watchProjectById(int id) {
    return _dao.watchProjectById(id).map(
      (entity) => entity != null ? SavingsProjectModel.fromEntity(entity) : null,
    );
  }

  // ============== CONTRIBUTION OPERATIONS ==============

  /// Adds a manual deposit to a project.
  Future<int> addDeposit({
    required int projectId,
    required int amountFcfa,
    String? note,
  }) {
    return _dao.addContributionAndUpdateProject(
      projectId: projectId,
      amountFcfa: amountFcfa,
      type: ContributionType.deposit.value,
      note: note,
    );
  }

  /// Withdraws from a project (negative amount).
  Future<int> withdraw({
    required int projectId,
    required int amountFcfa,
    String? note,
  }) {
    return _dao.addContributionAndUpdateProject(
      projectId: projectId,
      amountFcfa: -amountFcfa.abs(), // Ensure negative
      type: ContributionType.withdrawal.value,
      note: note,
    );
  }

  /// Records an automatic deposit.
  Future<int> addAutoDeposit({
    required int projectId,
    required int amountFcfa,
  }) {
    return _dao.addContributionAndUpdateProject(
      projectId: projectId,
      amountFcfa: amountFcfa,
      type: ContributionType.autoDeposit.value,
      note: 'Cotisation automatique',
    );
  }

  /// Records a failed automatic contribution.
  Future<int> recordFailedAutoContribution({
    required int projectId,
    required int amountFcfa,
    String? reason,
  }) {
    return _dao.addContributionAndUpdateProject(
      projectId: projectId,
      amountFcfa: 0, // No actual contribution
      type: ContributionType.autoFailed.value,
      note: reason ?? 'Budget insuffisant',
    );
  }

  /// Gets all contributions for a project.
  Future<List<ProjectContributionModel>> getContributionsForProject(
    int projectId,
  ) async {
    final entities = await _dao.getContributionsForProject(projectId);
    return entities.map(ProjectContributionModel.fromEntity).toList();
  }

  /// Watches contributions for a project.
  Stream<List<ProjectContributionModel>> watchContributionsForProject(
    int projectId,
  ) {
    return _dao.watchContributionsForProject(projectId).map(
      (entities) => entities.map(ProjectContributionModel.fromEntity).toList(),
    );
  }

  // ============== AUTO-CONTRIBUTION ==============

  /// Gets projects with auto-contribution due.
  Future<List<SavingsProjectModel>> getProjectsWithDueAutoContribution(
    DateTime now,
  ) async {
    final entities = await _dao.getProjectsWithDueAutoContribution(now);
    return entities.map(SavingsProjectModel.fromEntity).toList();
  }

  /// Updates the next contribution date for a project.
  Future<void> updateNextContributionDate(
    int projectId,
    DateTime nextDate,
  ) {
    return _dao.updateNextContributionDate(projectId, nextDate);
  }

  /// Configures auto-contribution for a project.
  Future<void> configureAutoContribution({
    required int projectId,
    required bool enabled,
    required int amountFcfa,
    required ContributionFrequency frequency,
  }) async {
    final now = DateTime.now();
    final nextDate = enabled ? frequency.nextDateFrom(now) : null;

    await _dao.updateProjectPartial(
      projectId,
      SavingsProjectsCompanion(
        autoContributionEnabled: Value(enabled),
        autoContributionAmountFcfa: Value(amountFcfa),
        autoContributionFrequency: Value(frequency.value),
        nextContributionDate: Value(nextDate),
        updatedAt: Value(now),
      ),
    );
  }

  // ============== STATISTICS ==============

  /// Gets total saved across all active projects.
  Future<int> getTotalSavedInActiveProjects() {
    return _dao.getTotalSavedInActiveProjects();
  }
}

/// Convert Color to hex string (without alpha).
String _colorToHex(Color color) {
  final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
  final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
  final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
  return '$r$g$b'.toUpperCase();
}
