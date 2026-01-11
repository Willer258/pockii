import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';

/// Bottom navigation bar widget.
///
/// Shows 4 navigation items: Home, History, Patterns, Settings.
/// Active item uses filled icon, inactive use outlined.
class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current route to determine active tab
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getIndexFromLocation(location);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onItemTapped(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Historique',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: 'Patterns',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Parametres',
        ),
      ],
    );
  }

  int _getIndexFromLocation(String location) {
    if (location.startsWith(AppRoutes.history)) return 1;
    if (location.startsWith(AppRoutes.patterns)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0; // Default to home
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.history);
      case 2:
        context.go(AppRoutes.patterns);
      case 3:
        context.go(AppRoutes.settings);
    }
  }
}
