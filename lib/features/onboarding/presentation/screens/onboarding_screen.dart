import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/onboarding_state.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/budget_setup_page.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/page_indicator.dart';

/// Main onboarding screen with PageView for intro screens and budget setup.
///
/// Screen 1: Welcome - value proposition
/// Screen 2: Features overview
/// Screen 3: Budget setup
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleComplete() async {
    final success =
        await ref.read(onboardingStateProvider.notifier).completeOnboarding();
    if (success && mounted) {
      // Invalidate onboarding cache so router knows we completed
      invalidateOnboardingCache(ref);
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingStateProvider);

    // Sync PageController with state
    ref.listen<OnboardingState>(onboardingStateProvider, (previous, next) {
      if (previous?.currentPage != next.currentPage &&
          _pageController.hasClients) {
        _goToPage(next.currentPage);
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (only on intro pages)
            if (!state.isLastPage)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: TextButton(
                    onPressed: () {
                      ref.read(onboardingStateProvider.notifier).skipToSetup();
                    },
                    child: Text(
                      "Passer l'intro",
                      style: AppTypography.label.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: AppSpacing.xl + AppSpacing.md),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  // Update state when user swipes
                  final currentPage =
                      ref.read(onboardingStateProvider).currentPage;
                  if (currentPage != index) {
                    if (index > currentPage) {
                      ref.read(onboardingStateProvider.notifier).nextPage();
                    } else {
                      ref.read(onboardingStateProvider.notifier).previousPage();
                    }
                  }
                },
                children: const [
                  // Screen 1: Welcome
                  OnboardingPage(
                    icon: Icons.account_balance_wallet,
                    title: 'Ton budget en un coup d\'oeil',
                    description:
                        'Pockii te montre combien tu peux encore dépenser. '
                        'Fini les fins de mois difficiles !',
                  ),
                  // Screen 2: Features
                  OnboardingPage(
                    icon: Icons.insights,
                    title: 'Analyse tes dépenses',
                    description:
                        'Suis tes transactions, découvre tes habitudes de dépenses '
                        'et reçois des alertes pour rester dans ton budget.',
                  ),
                  // Screen 3: Budget setup
                  BudgetSetupPage(),
                ],
              ),
            ),

            // Page indicator
            PageIndicator(
              totalPages: OnboardingState.totalPages,
              currentPage: state.currentPage,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: state.isLastPage
                  ? _buildCompleteButton(theme, state)
                  : _buildNextButton(theme),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.touchTarget,
      child: ElevatedButton(
        onPressed: () {
          ref.read(onboardingStateProvider.notifier).nextPage();
        },
        child: const Text('Suivant'),
      ),
    );
  }

  Widget _buildCompleteButton(ThemeData theme, OnboardingState state) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.touchTarget,
      child: ElevatedButton(
        onPressed: state.isBudgetValid && !state.isCompleting
            ? _handleComplete
            : null,
        child: state.isCompleting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Text('Commencer'),
      ),
    );
  }
}
