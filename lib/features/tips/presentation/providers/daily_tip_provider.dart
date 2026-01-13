import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/presentation/providers/budget_provider.dart';
import '../../data/tips_data.dart';
import '../../data/tips_repository.dart';
import '../../domain/models/tip.dart';

/// Provider for the daily tip based on current budget percentage.
final dailyTipProvider = FutureProvider<Tip>((ref) async {
  final percentage = ref.watch(budgetPercentageProvider);
  final repositoryAsync = ref.watch(tipsRepositoryProvider);

  return repositoryAsync.when(
    data: (repository) => repository.getDailyTip(percentage),
    loading: () => _getDefaultTip(percentage),
    error: (_, __) => _getDefaultTip(percentage),
  );
});

/// Provider for getting a new tip on demand.
final nextTipProvider = FutureProvider.family<Tip, int>((ref, _) async {
  final percentage = ref.watch(budgetPercentageProvider);
  final repositoryAsync = ref.watch(tipsRepositoryProvider);

  return repositoryAsync.when(
    data: (repository) => repository.getNextTip(percentage),
    loading: () => _getDefaultTip(percentage),
    error: (_, __) => _getDefaultTip(percentage),
  );
});

/// State notifier for managing the current displayed tip.
class CurrentTipNotifier extends StateNotifier<AsyncValue<Tip>> {
  CurrentTipNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadInitialTip();
  }

  final Ref _ref;
  int _refreshCounter = 0;

  Future<void> _loadInitialTip() async {
    try {
      final tip = await _ref.read(dailyTipProvider.future);
      state = AsyncValue.data(tip);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Load the next tip.
  Future<void> nextTip() async {
    final percentage = _ref.read(budgetPercentageProvider);
    final repositoryAsync = _ref.read(tipsRepositoryProvider);

    final repository = repositoryAsync.maybeWhen(
      data: (r) => r,
      orElse: () => null,
    );

    if (repository != null) {
      _refreshCounter++;
      final newTip = repository.getNextTip(percentage);
      state = AsyncValue.data(newTip);
    } else {
      // Fallback: just get a random tip from data
      _refreshCounter++;
      final tips = TipsData.forBudgetPercentage(percentage);
      if (tips.isNotEmpty) {
        final index = _refreshCounter % tips.length;
        state = AsyncValue.data(tips[index]);
      }
    }
  }
}

/// Provider for the current displayed tip with ability to refresh.
final currentTipProvider =
    StateNotifierProvider<CurrentTipNotifier, AsyncValue<Tip>>((ref) {
  return CurrentTipNotifier(ref);
});

/// Helper to get a default tip when repository is not ready.
Tip _getDefaultTip(double percentage) {
  final tips = TipsData.forBudgetPercentage(percentage);
  if (tips.isEmpty) {
    return TipsData.allTips.first;
  }
  // Return first tip of appropriate category
  return tips.first;
}
