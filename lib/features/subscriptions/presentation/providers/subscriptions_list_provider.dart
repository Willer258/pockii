import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/subscription_repository.dart';
import '../../domain/models/subscription_model.dart';

/// State for the subscriptions list screen.
class SubscriptionsListState {
  const SubscriptionsListState({
    this.showInactive = false,
  });

  /// Whether to show inactive subscriptions.
  final bool showInactive;

  SubscriptionsListState copyWith({
    bool? showInactive,
  }) {
    return SubscriptionsListState(
      showInactive: showInactive ?? this.showInactive,
    );
  }
}

/// Notifier for managing subscriptions list state.
class SubscriptionsListNotifier extends StateNotifier<SubscriptionsListState> {
  SubscriptionsListNotifier() : super(const SubscriptionsListState());

  /// Toggles the visibility of inactive subscriptions.
  void toggleShowInactive() {
    state = state.copyWith(showInactive: !state.showInactive);
  }

  /// Sets whether to show inactive subscriptions.
  void setShowInactive({required bool value}) {
    state = state.copyWith(showInactive: value);
  }
}

/// Provider for the subscriptions list state.
final subscriptionsListStateProvider =
    StateNotifierProvider<SubscriptionsListNotifier, SubscriptionsListState>(
  (ref) => SubscriptionsListNotifier(),
);

/// Provider that streams all subscriptions.
final allSubscriptionsProvider = StreamProvider<List<SubscriptionModel>>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.watchAllSubscriptions();
});

/// Provider that streams active subscriptions only.
final activeSubscriptionsProvider =
    StreamProvider<List<SubscriptionModel>>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.watchActiveSubscriptions();
});

/// Provider for total monthly amount from active subscriptions.
final totalMonthlyAmountProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.getTotalMonthlyAmount();
});

/// Provider for active subscription count.
final activeSubscriptionCountProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.getActiveSubscriptionCount();
});

/// Provider that filters subscriptions based on showInactive setting.
final filteredSubscriptionsProvider =
    Provider<AsyncValue<List<SubscriptionModel>>>((ref) {
  final listState = ref.watch(subscriptionsListStateProvider);

  if (listState.showInactive) {
    return ref.watch(allSubscriptionsProvider);
  } else {
    return ref.watch(activeSubscriptionsProvider);
  }
});
