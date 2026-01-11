import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/database/database_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/background_task_manager.dart';
import 'core/services/notification_service.dart';
import 'core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize French locale for date formatting
  await initializeDateFormatting('fr_FR', null);

  // Initialize WorkManager for background tasks (ARCH-9)
  final backgroundTaskManager = BackgroundTaskManager();
  await backgroundTaskManager.initialize();

  // Initialize notification service and request permission
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermission();

  // Register periodic background task
  await backgroundTaskManager.registerPeriodicTask();

  runApp(
    const ProviderScope(
      child: AccountApp(),
    ),
  );
}

/// Root widget for the AccountApp application.
class AccountApp extends ConsumerWidget {
  const AccountApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch database initialization
    final dbAsync = ref.watch(databaseProvider);
    final router = ref.watch(routerProvider);

    return dbAsync.when(
      data: (_) => MaterialApp.router(
        title: 'AccountApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        // darkTheme: AppTheme.dark(), // Post-MVP
        routerConfig: router,
      ),
      loading: () => MaterialApp(
        title: 'AccountApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _LoadingScreen(),
      ),
      error: (error, stack) => MaterialApp(
        title: 'AccountApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: _ErrorScreen(error: error),
      ),
    );
  }
}

/// Loading screen shown during database initialization.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Chargement...',
              style: AppTypography.body,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen shown when database initialization fails.
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: BudgetColors.danger,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Erreur d\'initialisation',
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
