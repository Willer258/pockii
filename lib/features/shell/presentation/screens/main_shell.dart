import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../transactions/presentation/widgets/transaction_bottom_sheet.dart';
import '../widgets/app_bottom_nav.dart';

/// Main shell widget providing bottom navigation structure.
///
/// Uses go_router's ShellRoute pattern for persistent navigation.
/// Wraps all main screens with a consistent bottom navigation bar
/// and centered FAB for adding transactions.
class MainShell extends ConsumerWidget {
  /// Creates a MainShell.
  const MainShell({required this.child, super.key});

  /// The child widget (current route's screen).
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const AppBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => TransactionBottomSheet.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        tooltip: 'Ajouter une transaction',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
